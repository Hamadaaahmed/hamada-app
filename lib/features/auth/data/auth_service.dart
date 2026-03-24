import 'package:dio/dio.dart';

import '../../../core/api_client.dart';
import '../../../core/firebase_messaging_service.dart';
import '../../../core/secure_storage.dart';

class AuthResult {
  final bool ok;
  final String? message;

  AuthResult({required this.ok, this.message});
}

class PhoneStatusResult {
  final bool ok;
  final bool hasPhone;
  final String? message;

  PhoneStatusResult({
    required this.ok,
    required this.hasPhone,
    this.message,
  });
}

class AuthService {
  String _mapDioError(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      final code = error.response?.statusCode;

      String? apiError;
      if (data is Map) {
        apiError = (data['error'] ?? '').toString();
      }

      switch (apiError) {
        case 'INVALID_EMAIL':
          return 'البريد الإلكتروني غير صحيح';
        case 'MAIL_NOT_CONFIGURED':
          return 'خدمة البريد غير مهيأة حاليًا';
        case 'MAIL_SEND_FAILED':
          return 'تعذر إرسال كود التحقق الآن';
        case 'INVALID_OTP':
          return 'كود التحقق غير صحيح';
        case 'OTP_EXPIRED':
          return 'انتهت صلاحية كود التحقق';
        case 'BLOCKED':
          return 'تم إيقاف هذا الحساب مؤقتًا. تواصل مع الإدارة.';
        case 'NOT_FOUND':
          return 'الحساب غير موجود';
        case 'PHONE_NOT_SET':
          return 'لا يوجد رقم هاتف محفوظ لهذا الحساب';
        case 'PHONE_MISMATCH':
          return 'رقم الهاتف غير مطابق للحساب';
        case 'INVALID_PHONE':
          return 'رقم الهاتف غير صحيح';
        case 'PHONE_ALREADY_USED':
          return 'رقم الهاتف مستخدم بحساب آخر';
        case 'SERVER_ERROR':
          return 'حدث خطأ في السيرفر، حاول مرة أخرى';
      }

      if (code == 400) return 'البيانات المدخلة غير صحيحة';
      if (code == 401) return 'بيانات الدخول غير صحيحة';
      if (code == 403) return 'غير مسموح بهذا الإجراء';
      if (code == 404) return 'الطلب غير موجود';
      if (code == 409) return 'هذه البيانات مستخدمة بالفعل';
      if (code == 500) return 'حدث خطأ في السيرفر، حاول مرة أخرى';
    }

    return 'تعذر الاتصال بالسيرفر، حاول مرة أخرى';
  }

  Future<AuthResult> requestOtp(String email) async {
    try {
      final res = await ApiClient.I.dio.post(
        '/auth/client/request-otp',
        data: {'email': email.trim().toLowerCase()},
      );

      final data = res.data;
      if (data is Map && data['ok'] == true) {
        return AuthResult(ok: true);
      }

      return AuthResult(
        ok: false,
        message:
            (data is Map ? data['error'] : null)?.toString() ?? 'فشل إرسال الكود',
      );
    } catch (e) {
      return AuthResult(ok: false, message: _mapDioError(e));
    }
  }

  Future<AuthResult> verifyOtp({
    required String email,
    required String code,
  }) async {
    try {
      final res = await ApiClient.I.dio.post(
        '/auth/client/verify-otp',
        data: {
          'email': email.trim().toLowerCase(),
          'otp': code.trim(),
        },
      );

      final data = res.data;
      if (data is Map && data['ok'] == true) {
        final token = (data['token'] ?? '').toString();

        if (token.isNotEmpty) {
          await ApiClient.I.saveClientToken(token);
          final refreshToken =
              (data['refresh_token'] ?? data['refreshToken'] ?? '').toString();
          if (refreshToken.isNotEmpty) {
            await AppStorage.I.saveClientRefreshToken(refreshToken);
          }
          await AppStorage.I.saveClientEmail(email.trim().toLowerCase());

          try {
            final phoneStatus = await getPhoneStatus(email.trim().toLowerCase());
            if (phoneStatus.ok && phoneStatus.hasPhone) {
              await AppStorage.I.clearClientPhoneGatePending();
            } else {
              await AppStorage.I.setClientPhoneGatePending(true);
            }
          } catch (_) {
            await AppStorage.I.clearClientPhoneGatePending();
          }

          await FirebaseMessagingService.I.syncTokenToServer();
        }

        return AuthResult(ok: true);
      }

      return AuthResult(
        ok: false,
        message:
            (data is Map ? data['error'] : null)?.toString() ?? 'الكود غير صحيح',
      );
    } catch (e) {
      return AuthResult(ok: false, message: _mapDioError(e));
    }
  }

  Future<PhoneStatusResult> getPhoneStatus(String email) async {
    try {
      final res = await ApiClient.I.dio.post(
        '/auth/client/phone-status',
        data: {'email': email.trim().toLowerCase()},
      );

      final data = res.data;
      if (data is Map && data['ok'] == true) {
        return PhoneStatusResult(
          ok: true,
          hasPhone: data['has_phone'] == true,
        );
      }

      return PhoneStatusResult(
        ok: false,
        hasPhone: false,
        message:
            (data is Map ? data['error'] : null)?.toString() ?? 'تعذر فحص رقم الهاتف',
      );
    } catch (e) {
      return PhoneStatusResult(
        ok: false,
        hasPhone: false,
        message: _mapDioError(e),
      );
    }
  }

  Future<AuthResult> verifyLinkedPhone({
    required String email,
    required String phone,
  }) async {
    try {
      final res = await ApiClient.I.dio.post(
        '/auth/client/verify-phone',
        data: {
          'email': email.trim().toLowerCase(),
          'phone': phone.trim(),
        },
      );

      final data = res.data;
      if (data is Map && data['ok'] == true) {
        return AuthResult(ok: true);
      }

      return AuthResult(
        ok: false,
        message: (data is Map ? data['error'] : null)?.toString() ??
            'رقم الهاتف غير مطابق',
      );
    } catch (e) {
      return AuthResult(ok: false, message: _mapDioError(e));
    }
  }

  Future<bool> hasToken() async {
    final token = await ApiClient.I.getClientToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    await ApiClient.I.clearClientToken();
    await AppStorage.I.clearClientRefreshToken();
    await AppStorage.I.clearClientEmail();
    await AppStorage.I.clearClientPhoneGatePending();
  }
}
