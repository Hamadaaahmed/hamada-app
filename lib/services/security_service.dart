import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:safe_device/safe_device.dart';

class SecurityService {
  static const MethodChannel _channel = MethodChannel('xray_vpn/device');

  static Future<void> enableScreenProtection() async {
    if (Platform.isAndroid) {
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    }
  }

  static Future<bool> isDeviceUnsafe() async {
    try {
      final isRooted = await SafeDevice.isJailBroken;
      final isRealDevice = await SafeDevice.isRealDevice;
      final isMockLocation = await SafeDevice.isMockLocation;
      final isDevelopmentMode = await SafeDevice.isDevelopmentModeEnable;

      final nativeUnsafe = await _channel.invokeMethod<bool>('securityCheck') ?? false;

      return isRooted ||
          !isRealDevice ||
          isMockLocation ||
          isDevelopmentMode ||
          nativeUnsafe;
    } catch (_) {
      return true;
    }
  }
}
