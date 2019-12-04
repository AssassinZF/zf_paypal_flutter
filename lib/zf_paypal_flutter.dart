import 'dart:async';

import 'package:flutter/services.dart';

class ZfPaypalFlutter {
  static const MethodChannel _channel =
      const MethodChannel('zf_paypal_flutter');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

//支付金额（美元）订单id 手续费
  Future<String> paypal(Map<String, dynamic> payParam) async {
    final String version = await _channel.invokeMethod('paypal', payParam);
    return version;
  }
}
