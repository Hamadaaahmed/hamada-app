import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://37.60.249.108:3010';

  static String? _token;

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
    _token = data['token'] ?? data['accessToken'];

    return data;
  }

  Future<Map<String, dynamic>> getVpnConfig() async {
    if (_token == null) {
      throw Exception('Not logged in');
    }

    final url = Uri.parse('$baseUrl/vpn/config');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load VPN config: ${response.body}');
    }

    return Map<String, dynamic>.from(jsonDecode(response.body));
  }
}
