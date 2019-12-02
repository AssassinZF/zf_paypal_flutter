import 'dart:async';

import 'package:flutter/services.dart';

class ZfPaypalFlutter {
  static const MethodChannel _channel =
      const MethodChannel('zf_paypal_flutter');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String> get platformVersionTest async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  Future<String> paypal() async {
    final String version = await _channel.invokeMethod('paypal');
    return version;
  }
}
