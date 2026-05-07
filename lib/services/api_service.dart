import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';

class ApiService {
  static const String baseUrl = 'http://37.60.249.108:3010';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static String? _token;
  static const MethodChannel _channel = MethodChannel('xray_vpn/device');

  Future<Map<String, String>> _secureHeaders({bool auth = false}) async {
    final signature = await _channel.invokeMethod<String>('getAppSignatureSha256') ?? '';
    final token = auth ? await _loadToken() : null;

    return {
      'Content-Type': 'application/json',
      'X-App-Signature': signature,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> _saveToken(String token) async {
    _token = token;
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<String?> _loadToken() async {
    _token ??= await _storage.read(key: 'auth_token');
    return _token;
  }

  Future<Map<String, dynamic>> deviceLogin(Map<String, String> deviceData) async {
    final url = Uri.parse('$baseUrl/auth/device-login');

    final response = await http.post(
      url,
      headers: await _secureHeaders(),
      body: jsonEncode(deviceData),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Login failed: ${response.body}');
    }

    final data = Map<String, dynamic>.from(jsonDecode(response.body));
    final token = data['token'] ?? data['accessToken'];

    if (token != null) {
      await _saveToken(token.toString());
    }

    return data;
  }

  Future<void> sendClientStatus({
    required String deviceId,
    required String state,
    required int upload,
    required int download,
    required int uploadSpeed,
    required int downloadSpeed,
  }) async {
    final url = Uri.parse('$baseUrl/client/status');

    await http.post(
      url,
      headers: await _secureHeaders(),
      body: jsonEncode({
        'device_id': deviceId,
        'state': state,
        'upload': upload,
        'download': download,
        'upload_speed': uploadSpeed,
        'download_speed': downloadSpeed,
      }),
    );
  }

  Future<Map<String, dynamic>> getVpnConfig() async {
    final token = await _loadToken();

    if (token == null) {
      throw Exception('Not logged in');
    }

    final url = Uri.parse('$baseUrl/vpn/config');

    final response = await http.get(
      url,
      headers: await _secureHeaders(auth: true),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load VPN config: ${response.body}');
    }

    return Map<String, dynamic>.from(jsonDecode(response.body));
  }
}
