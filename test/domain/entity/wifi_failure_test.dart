import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_management/wifi_management.dart';

void main() {
  test('every host code maps back to its failure; unknown codes fail safe', () {
    for (final failure in WifiFailure.values) {
      expect(WifiFailure.fromCode(failure.code), failure);
    }
    expect(WifiFailure.fromCode('approval_denied'), WifiFailure.approvalDenied);
    expect(WifiFailure.fromCode('something_new'), WifiFailure.unknown);
    expect(WifiFailure.fromCode(null), WifiFailure.unknown);
  });
}
