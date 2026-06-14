import 'package:dio/dio.dart';
import '../../../core/api_client.dart';
import '../../../core/secure_storage.dart';
import '../../../core/firebase_messaging_service.dart';

class AuthResult {
  final bool ok;
  final String? message;

  AuthResult({required this.ok, this.message});
}

class AuthService {

  Future<AuthResult> login({
    required String phone,
    required String password,
  }) async {
    try {
      final res = await ApiClient.I.dio.post(
        '/core/login',
        data: {
          'phone': phone.trim(),
          'password': password.trim(),
        },
      );

      final data = res.data;

      if (data is Map && data['token'] != null) {

        final token = data['token'].toString();
        final user = data['user'] ?? {};

        final role = (user['role'] ?? '').toString();
        final userId = user['_id']?.toString() ?? user['id']?.toString();

        await SecureStorage.I.write(key: 'token', value: token);
        await SecureStorage.I.write(key: 'role', value: role);
        await SecureStorage.I.write(key: 'user_id', value: userId ?? '');

        try {
          await FirebaseMessagingService.I.syncTokenToServer(role: role);
        } catch (_) {}

        return AuthResult(ok: true);
      }

      return AuthResult(ok: false, message: 'فشل تسجيل الدخول');

    } catch (e) {
      return AuthResult(ok: false, message: 'خطأ في الاتصال');
    }
  }

  Future<void> logout() async {
    await SecureStorage.I.deleteAll();
  }
}
