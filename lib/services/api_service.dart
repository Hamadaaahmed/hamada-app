import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://37.60.249.108:3005';

  // جلب الباقات
  static Future<List<dynamic>> getPlans() async {
    final response = await http.get(Uri.parse('$baseUrl/plans'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['plans'];
    } else {
      throw Exception('فشل تحميل الباقات');
    }
  }

  // تسجيل مستخدم
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? deviceId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'deviceId': deviceId,
      }),
    );

    return jsonDecode(response.body);
  }

  // تسجيل دخول
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    return jsonDecode(response.body);
  }
}
