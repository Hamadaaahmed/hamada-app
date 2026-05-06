import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';

class DeviceService {
  static const MethodChannel _channel = MethodChannel('xray_vpn/device');

  Future<Map<String, String>> getDeviceData() async {
    final data = await _channel.invokeMapMethod<String, String>('getDeviceData');

    final androidId = data?['android_id'] ?? '';
    final brand = data?['brand'] ?? '';
    final model = data?['model'] ?? '';
    final hardware = data?['hardware'] ?? '';

    final rawId = '$androidId|$brand|$model';
    final deviceId = sha256.convert(utf8.encode(rawId)).toString();

    return {
      'device_id': deviceId,
      'device_name': '$brand $model',
      'device_model': model,
      'device_brand': brand,
      'device_android_id': androidId,
      'device_hardware': hardware,
      'platform': 'android',
    };
  }
}
