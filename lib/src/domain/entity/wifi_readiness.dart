/// What stands between the device and a scan or a join.
enum WifiReadiness { ready, unsupported, permissionDenied, locationDisabled }

/// System screens that fix a [WifiReadiness] problem.
enum WifiSettingsTarget { location, app }
