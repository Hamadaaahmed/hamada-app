import 'token_utils.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppStorage {
  AppStorage._();
  static final AppStorage I = AppStorage._();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String clientTokenKey = 'client_token';
  static const String adminTokenKey = 'admin_token';
  static const String clientEmailKey = 'client_email';
  static const String clientPhoneGatePendingKey = 'client_phone_gate_pending';
  static const String clientRefreshTokenKey = 'client_refresh_token';
  static const String adminRefreshTokenKey = 'admin_refresh_token';

  Future<void> saveClientToken(String token) =>
      _storage.write(key: clientTokenKey, value: token);

  Future<String?> getClientToken() => _storage.read(key: clientTokenKey);

  Future<void> clearClientToken() => _storage.delete(key: clientTokenKey);

  Future<void> saveClientEmail(String email) =>
      _storage.write(key: clientEmailKey, value: email);

  Future<String?> getClientEmail() => _storage.read(key: clientEmailKey);

  Future<void> clearClientEmail() => _storage.delete(key: clientEmailKey);

  Future<void> setClientPhoneGatePending(bool value) =>
      _storage.write(
        key: clientPhoneGatePendingKey,
        value: value ? '1' : '0',
      );

  Future<bool> isClientPhoneGatePending() async =>
      (await _storage.read(key: clientPhoneGatePendingKey)) == '1';

  Future<void> clearClientPhoneGatePending() =>
      _storage.delete(key: clientPhoneGatePendingKey);

  Future<void> saveClientRefreshToken(String token) =>
      _storage.write(key: clientRefreshTokenKey, value: token);

  Future<String?> getClientRefreshToken() =>
      _storage.read(key: clientRefreshTokenKey);

  Future<void> clearClientRefreshToken() =>
      _storage.delete(key: clientRefreshTokenKey);

  Future<void> saveAdminRefreshToken(String token) =>
      _storage.write(key: adminRefreshTokenKey, value: token);

  Future<String?> getAdminRefreshToken() =>
      _storage.read(key: adminRefreshTokenKey);

  Future<void> clearAdminRefreshToken() =>
      _storage.delete(key: adminRefreshTokenKey);

  Future<void> saveAdminToken(String token) =>
      _storage.write(key: adminTokenKey, value: token);

  Future<String?> getAdminToken() => _storage.read(key: adminTokenKey);

  Future<void> clearAdminToken() => _storage.delete(key: adminTokenKey);

  Future<int> getClientIdFromToken() async {
    final token = await getClientToken();
    return TokenUtils.extractUserId(token);
  }

  Future<void> clearAll() async {
    await _storage.delete(key: clientTokenKey);
    await _storage.delete(key: adminTokenKey);
    await _storage.delete(key: clientEmailKey);
    await _storage.delete(key: clientPhoneGatePendingKey);
    await _storage.delete(key: clientRefreshTokenKey);
    await _storage.delete(key: adminRefreshTokenKey);
  }
}
