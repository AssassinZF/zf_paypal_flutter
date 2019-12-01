import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zf_paypal_flutter/zf_paypal_flutter.dart';

void main() {
  const MethodChannel channel = MethodChannel('zf_paypal_flutter');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await ZfPaypalFlutter.platformVersion, '42');
  });
}
