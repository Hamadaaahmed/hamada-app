import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:openvpn_flutter/openvpn_flutter.dart';
import 'auth_service.dart';

class VpnService {
  static const String baseUrl = 'http://37.60.249.108:3005';
  static final OpenVPN engine = OpenVPN();

  static final ValueNotifier<String> stageNotifier =
      ValueNotifier<String>('غير متصل');
  static final ValueNotifier<dynamic> statusNotifier =
      ValueNotifier<dynamic>(null);

  static Future<void> initialize() async {
    await engine.initialize(
      groupIdentifier: 'group.com.example.flutter_vpn_app',
      providerBundleIdentifier: 'com.example.flutter_vpn_app.VPNExtension',
      localizedDescription: 'VPN العربي',
      lastStage: (stage) {
        stageNotifier.value = stage.name;
      },
      lastStatus: (status) {
        statusNotifier.value = status;
      },
    );
  }

  static Future<Map<String, dynamic>> getVpnConfig() async {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/vpn/config'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<void> connect() async {
    final data = await getVpnConfig();

    if (data['ok'] != true) {
      throw Exception(data['message'] ?? 'فشل جلب بيانات VPN');
    }

    final ovpn = data['ovpn']?.toString() ?? '';
    final username = data['username']?.toString() ?? '';
    final password = data['password']?.toString() ?? '';

    await engine.connect(
      ovpn,
      'VPN العربي',
      username: username,
      password: password,
      certIsRequired: false,
    );
  }

  static Future<void> disconnect() async {
    engine.disconnect();
  }
}
