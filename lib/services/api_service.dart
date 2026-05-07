import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'http://37.60.249.108:3010';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static String? _token;

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
      headers: {'Content-Type': 'application/json'},
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

  Future<Map<String, dynamic>> getVpnConfig() async {
    final token = await _loadToken();

    if (token == null) {
      throw Exception('Not logged in');
    }

    final url = Uri.parse('$baseUrl/vpn/config');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load VPN config: ${response.body}');
    }

    return Map<String, dynamic>.from(jsonDecode(response.body));
  }
}
