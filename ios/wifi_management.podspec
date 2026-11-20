#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint wifi_management.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'wifi_management'
  s.version          = '0.3.2'
  s.summary          = 'Pin a device to one exact Wi-Fi router (SSID + BSSID).'
  s.description      = <<-DESC
Joins a Wi-Fi network by SSID and verifies the BSSID it joined (best effort on iOS).
                       DESC
  s.homepage         = 'https://github.com/Solusi-Bejo/wifi_management'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Solusi Bejo' => 'https://github.com/Solusi-Bejo' }
  s.source           = { :path => '.' }
  s.source_files = 'wifi_management/Sources/wifi_management/**/*'
  s.dependency 'Flutter'
  s.frameworks = 'NetworkExtension', 'CoreLocation', 'Network'
  s.platform = :ios, '15.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'wifi_management_privacy' => ['wifi_management/Sources/wifi_management/PrivacyInfo.xcprivacy']}
end
