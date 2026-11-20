import CoreLocation
import Flutter
import Network
import NetworkExtension
import UIKit

/// iOS side of `wifi_management`: best effort.
///
/// iOS cannot scan, cannot restrict a join to one BSSID, and cannot bind app
/// traffic to a network. What it can do: join by SSID + password through
/// `NEHotspotConfiguration`, then read the BSSID it actually joined through
/// `NEHotspotNetwork.fetchCurrent` and report a mismatch (removing the
/// configuration). Needs the "Hotspot Configuration" and "Access Wi-Fi
/// Information" entitlements plus location permission.
public class WifiManagementPlugin: NSObject, FlutterPlugin, WifiManagementHostApi,
  CLLocationManagerDelegate
{
  private struct ActiveRequest {
    let requestId: Int64
    let ssid: String
    /// Empty until the first join locks one.
    var bssid: String
    var verified = false
  }

  private let events = NetworkEvents()
  private let locationManager = CLLocationManager()
  private var permissionCompletions: [(Result<Bool, Error>) -> Void] = []
  private var active: ActiveRequest?
  private var pathMonitor: NWPathMonitor?
  private var pollTimer: Timer?

  private static let verifyAttempts = 10
  private static let verifyInterval: TimeInterval = 0.5
  private static let pollInterval: TimeInterval = 10

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = WifiManagementPlugin()
    instance.locationManager.delegate = instance
    WifiManagementHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: instance)
    NetworkEventsStreamHandler.register(
      with: registrar.messenger(), streamHandler: instance.events)
  }

  // MARK: - Capabilities, readiness, permissions

  func capabilities() throws -> PlatformCapabilities {
    PlatformCapabilities(supported: true, canScan: false, canLockBssid: false, canBindProcess: false)
  }

  private var isAuthorized: Bool {
    switch locationManager.authorizationStatus {
    case .authorizedAlways, .authorizedWhenInUse: return true
    default: return false
    }
  }

  func checkReadiness() throws -> PlatformReadiness {
    PlatformReadiness(
      supported: true,
      permissionsGranted: isAuthorized,
      locationEnabled: CLLocationManager.locationServicesEnabled())
  }

  func requestPermissions(completion: @escaping (Result<Bool, Error>) -> Void) {
    guard locationManager.authorizationStatus == .notDetermined else {
      completion(.success(isAuthorized))
      return
    }
    permissionCompletions.append(completion)
    locationManager.requestWhenInUseAuthorization()
  }

  public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    guard manager.authorizationStatus != .notDetermined else { return }
    let granted = isAuthorized
    let completions = permissionCompletions
    permissionCompletions.removeAll()
    completions.forEach { $0(.success(granted)) }
  }

  func openLocationSettings() throws { openSettings() }

  func openAppSettings() throws { openSettings() }

  /// iOS has no public way to open the Wi-Fi screen; the app's settings page
  /// is the closest allowed one.
  func openWifiSettings() throws { openSettings() }

  /// The device's current Wi-Fi as `NEHotspotNetwork` reports it (needs the
  /// Access Wi-Fi Information entitlement and location permission).
  func currentNetwork(completion: @escaping (Result<PlatformAccessPoint?, Error>) -> Void) {
    NEHotspotNetwork.fetchCurrent { network in
      guard let network, !network.ssid.isEmpty, !network.bssid.isEmpty else {
        completion(.success(nil))
        return
      }
      completion(.success(PlatformAccessPoint(
        ssid: network.ssid,
        bssid: network.bssid.lowercased(),
        rssi: 0,
        security: "unsupported"
      )))
    }
  }

  private func openSettings() {
    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
    UIApplication.shared.open(url)
  }

  // MARK: - Scan

  func scan(completion: @escaping (Result<PlatformScanResult, Error>) -> Void) {
    // iOS has no public Wi-Fi scan API.
    completion(.success(PlatformScanResult(accessPoints: [], failure: "unsupported")))
  }

  // MARK: - Connect + verify

  func connect(request: PlatformConnectRequest) throws {
    release()
    let bssid = request.bssid.lowercased()

    if !isAuthorized {
      emit(request.requestId, "error", failure: "permission_denied")
      return
    }

    let configuration: NEHotspotConfiguration
    switch request.security {
    case "open":
      configuration = NEHotspotConfiguration(ssid: request.ssid)
    case "wpa2", "wpa3":
      configuration = NEHotspotConfiguration(
        ssid: request.ssid, passphrase: request.password, isWEP: false)
    default:
      emit(request.requestId, "error", failure: "invalid_config")
      return
    }
    configuration.joinOnce = false
    configuration.hidden = request.hidden

    active = ActiveRequest(requestId: request.requestId, ssid: request.ssid, bssid: bssid)
    emit(request.requestId, "connecting", ssid: request.ssid, bssid: bssid)

    NEHotspotConfigurationManager.shared.apply(configuration) { [weak self] error in
      DispatchQueue.main.async {
        guard let self = self, self.active?.requestId == request.requestId else { return }
        if let error = error as NSError?,
          error.domain == NEHotspotConfigurationErrorDomain,
          error.code != NEHotspotConfigurationError.alreadyAssociated.rawValue
        {
          let invalid: Set<Int> = [
            NEHotspotConfigurationError.invalid.rawValue,
            NEHotspotConfigurationError.invalidSSID.rawValue,
            NEHotspotConfigurationError.invalidWPAPassphrase.rawValue,
            NEHotspotConfigurationError.invalidWEPPassphrase.rawValue,
          ]
          self.active = nil
          if invalid.contains(error.code) {
            self.emit(request.requestId, "error", ssid: request.ssid, failure: "invalid_config")
          } else {
            // Includes the user declining the system join prompt.
            self.emit(request.requestId, "unavailable", ssid: request.ssid, bssid: bssid)
          }
          return
        }
        self.verify(requestId: request.requestId, attempt: 0)
      }
    }
  }

  /// The joined network can lag the apply callback, so re-read it a few
  /// times before calling it a mismatch or unavailable.
  private func verify(requestId: Int64, attempt: Int) {
    NEHotspotNetwork.fetchCurrent { [weak self] network in
      DispatchQueue.main.async {
        guard let self = self, let request = self.active, request.requestId == requestId
        else { return }
        let actual = network.flatMap { $0.ssid == request.ssid ? $0.bssid.lowercased() : nil }
        // An empty BSSID (none locked yet) accepts the one joined and keeps it.
        if let actual, request.bssid.isEmpty || actual == request.bssid {
          self.active?.bssid = actual
          self.active?.verified = true
          self.emit(requestId, "connected", ssid: request.ssid, bssid: actual)
          self.startMonitoring()
          return
        }
        if attempt + 1 < Self.verifyAttempts {
          DispatchQueue.main.asyncAfter(deadline: .now() + Self.verifyInterval) {
            self.verify(requestId: requestId, attempt: attempt + 1)
          }
          return
        }
        self.release()
        if let actual = actual {
          self.emit(requestId, "error", ssid: request.ssid, bssid: actual, failure: "bssid_mismatch")
        } else {
          self.emit(requestId, "unavailable", ssid: request.ssid, bssid: request.bssid)
        }
      }
    }
  }

  // MARK: - Link monitoring

  private func startMonitoring() {
    stopMonitoring()
    let monitor = NWPathMonitor(requiredInterfaceType: .wifi)
    monitor.pathUpdateHandler = { [weak self] _ in
      DispatchQueue.main.async { self?.checkLink() }
    }
    monitor.start(queue: DispatchQueue.global(qos: .utility))
    pathMonitor = monitor
    pollTimer = Timer.scheduledTimer(withTimeInterval: Self.pollInterval, repeats: true) {
      [weak self] _ in self?.checkLink()
    }
  }

  private func stopMonitoring() {
    pathMonitor?.cancel()
    pathMonitor = nil
    pollTimer?.invalidate()
    pollTimer = nil
  }

  private func checkLink() {
    guard let request = active, request.verified else { return }
    NEHotspotNetwork.fetchCurrent { [weak self] network in
      DispatchQueue.main.async {
        guard let self = self, let current = self.active,
          current.requestId == request.requestId, current.verified
        else { return }
        let onPinned =
          network?.ssid == current.ssid && network?.bssid.lowercased() == current.bssid
        if !onPinned {
          self.active?.verified = false
          self.stopMonitoring()
          self.emit(current.requestId, "lost", ssid: current.ssid, bssid: current.bssid)
        }
      }
    }
  }

  // MARK: - Release

  func disconnect() throws { release() }

  /// iOS lets an app remove only the configurations it applied itself
  /// (`release` already does that); networks the user saved are out of reach.
  func forgetSystemNetwork(ssid: String) throws -> String { "unsupported" }

  /// Forgets the configuration this plugin applied. Idempotent.
  private func release() {
    stopMonitoring()
    if let request = active {
      NEHotspotConfigurationManager.shared.removeConfiguration(forSSID: request.ssid)
    }
    active = nil
  }

  // MARK: - Events

  private class NetworkEvents: NetworkEventsStreamHandler {
    var sink: PigeonEventSink<PlatformNetworkEvent>?

    override func onListen(withArguments arguments: Any?, sink: PigeonEventSink<PlatformNetworkEvent>) {
      self.sink = sink
    }

    override func onCancel(withArguments arguments: Any?) {
      sink = nil
    }
  }

  private func emit(
    _ requestId: Int64, _ type: String, ssid: String? = nil, bssid: String? = nil,
    failure: String? = nil
  ) {
    let event = PlatformNetworkEvent(
      requestId: requestId, type: type, ssid: ssid, bssid: bssid, failure: failure)
    if Thread.isMainThread {
      events.sink?.success(event)
    } else {
      DispatchQueue.main.async { self.events.sink?.success(event) }
    }
  }
}
