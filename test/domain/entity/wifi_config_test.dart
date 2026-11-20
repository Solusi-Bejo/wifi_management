import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_management/wifi_management.dart';

void main() {
  const config = WifiConfig(
    ssid: 'SSID001',
    bssid: 'aa:bb:cc:00:00:02',
    security: WifiSecurity.wpa2,
    password: 'secret123',
  );

  test('matches the BSSID case- and space-insensitively', () {
    expect(config.matchesBssid('AA:BB:CC:00:00:02'), isTrue);
    expect(config.matchesBssid(' aa:bb:cc:00:00:02 '), isTrue);
    expect(config.matchesBssid('aa:bb:cc:00:00:01'), isFalse);
    expect(config.matchesBssid(null), isFalse);
  });

  test('never prints the password', () {
    expect(config.toString(), isNot(contains('secret123')));
  });

  test('round-trips through JSON with the security code', () {
    final json = jsonDecode(jsonEncode(config.toJson()));

    expect(json, {
      'ssid': 'SSID001',
      'bssid': 'aa:bb:cc:00:00:02',
      'security': 'wpa2',
      'password': 'secret123',
      'hidden': false,
    });
    expect(WifiConfig.fromJson(json as Map<String, dynamic>), config);
  });

  test('an entry stored before `hidden` existed still reads, as visible', () {
    final old = WifiConfig.fromJson({
      'ssid': 'SSID001',
      'bssid': 'aa:bb:cc:00:00:02',
      'security': 'wpa2',
      'password': 'secret123',
    });
    expect(old.hidden, isFalse);
    expect(old, config);
  });

  test('no BSSID yet: any readable BSSID matches, none is invalid', () {
    const unlocked = WifiConfig(
      ssid: 'Hidden',
      bssid: '',
      security: WifiSecurity.wpa2,
      hidden: true,
    );
    expect(unlocked.isBssidLocked, isFalse);
    expect(unlocked.matchesBssid('aa:bb:cc:00:00:07'), isTrue);
    expect(unlocked.matchesBssid(null), isFalse);
    expect(config.isBssidLocked, isTrue);
  });

  test('isValidBssid accepts colon or dash separators in any case', () {
    expect(WifiConfig.isValidBssid('AA:BB:CC:00:00:07'), isTrue);
    expect(WifiConfig.isValidBssid('aa-bb-cc-00-00-07'), isTrue);
    expect(WifiConfig.normalizeBssid('AA-BB-CC-00-00-07'), 'aa:bb:cc:00:00:07');
    expect(WifiConfig.isValidBssid('aa:bb:cc:00:00'), isFalse);
    expect(WifiConfig.isValidBssid('zz:bb:cc:00:00:07'), isFalse);
    expect(WifiConfig.isValidBssid(''), isFalse);
  });

  test('an unknown security code reads as unsupported', () {
    final read = WifiConfig.fromJson({
      'ssid': 'x',
      'bssid': 'aa:bb:cc:00:00:02',
      'security': 'wpa9',
    });

    expect(read.security, WifiSecurity.unsupported);
    expect(read.password, '');
  });

  test('a missing field throws', () {
    expect(() => WifiConfig.fromJson({'ssid': 'x'}), throwsA(anything));
  });
}
