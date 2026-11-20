import 'wifi_access_point.dart';
import 'wifi_failure.dart';

/// Outcome of a scan: the access points, or why there are none.
typedef WifiScanResult = ({
  List<WifiAccessPoint> accessPoints,
  WifiFailure? failure,
});
