import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../config/app_config.dart';
import 'secure_storage.dart';

class AppNavigator {
  static final key = GlobalKey<NavigatorState>();
}

class ApiClient {
  ApiClient._() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _getTokenForRequest(options);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          } else {
            options.headers.remove('Authorization');
          }

          handler.next(options);
        },
        onError: (error, handler) async {
          final requestOptions = error.requestOptions;
          final alreadyRetried = requestOptions.extra['retried'] == true;

          final shouldRetryNetwork =
              error.type == DioExceptionType.connectionError ||
                  error.type == DioExceptionType.connectionTimeout ||
                  error.type == DioExceptionType.receiveTimeout ||
                  error.error is SocketException;

          final isSafeMethod =
              requestOptions.method.toUpperCase() == 'GET';

          if (shouldRetryNetwork && isSafeMethod && !alreadyRetried) {
            try {
              requestOptions.extra['retried'] = true;
              final response = await dio.fetch(requestOptions);
              return handler.resolve(response);
            } catch (_) {}
          }

          final statusCode = error.response?.statusCode ?? 0;
          final path = requestOptions.path;

          if (statusCode == 401 &&
              !_isAuthPath(path) &&
              requestOptions.extra['refreshRetried'] != true) {
            final refreshed = await _refreshAccessToken(requestOptions);
            if (refreshed) {
              try {
                requestOptions.extra['refreshRetried'] = true;
                final newToken = await _getTokenForRequest(requestOptions);
                if (newToken != null && newToken.isNotEmpty) {
                  requestOptions.headers['Authorization'] = 'Bearer $newToken';
                } else {
                  requestOptions.headers.remove('Authorization');
                }
                final response = await dio.fetch(requestOptions);
                return handler.resolve(response);
              } catch (_) {}
            } else {
              await _clearSessionForRequest(requestOptions);
            }
          }

          handler.next(error);
        },
      ),
    );
  }

  static final ApiClient I = ApiClient._();

  late final Dio dio;
  bool _isRefreshing = false;
  Future<bool>? _refreshFuture;

  bool _isAuthPath(String path) {
    return path.startsWith('/auth/admin/login') ||
        path.startsWith('/auth/client/request-otp') ||
        path.startsWith('/auth/client/verify-otp') ||
        path.startsWith('/auth/client/phone-status') ||
        path.startsWith('/auth/client/verify-phone') ||
        path.startsWith('/auth/social/login') ||
        path.startsWith('/auth/admin/social-password') ||
        path.startsWith('/auth/refresh');
  }

  bool _isAdminRequest(String path) {
    return path.startsWith('/admin/') ||
        path.startsWith('/auth/admin/') ||
        path.startsWith('/notifications');
  }

  String? _deviceRoleFromRequest(RequestOptions options) {
    final raw = options.extra['device_role'];
    final role = (raw ?? '').toString().trim().toLowerCase();
    if (role == 'admin' || role == 'client') return role;
    return null;
  }

  Future<String?> _getTokenForRequest(RequestOptions options) async {
    final path = options.path;
    final deviceRole = _deviceRoleFromRequest(options);

    if (path.startsWith('/devices/register')) {
      if (deviceRole == 'admin') {
        return await AppStorage.I.getAdminToken();
      }
      if (deviceRole == 'client') {
        return await AppStorage.I.getClientToken();
      }

      final adminToken = await AppStorage.I.getAdminToken();
      final clientToken = await AppStorage.I.getClientToken();
      return (adminToken != null && adminToken.isNotEmpty)
          ? adminToken
          : clientToken;
    }

    return _isAdminRequest(path)
        ? await AppStorage.I.getAdminToken()
        : await AppStorage.I.getClientToken();
  }

  Future<void> _clearSessionForRequest(RequestOptions options) async {
    final path = options.path;
    final deviceRole = _deviceRoleFromRequest(options);

    final isAdminRequest =
        deviceRole == 'admin' || (deviceRole == null && _isAdminRequest(path));

    if (isAdminRequest) {
      await AppStorage.I.clearAdminToken();
      await AppStorage.I.clearAdminRefreshToken();
    } else {
      await AppStorage.I.clearClientToken();
      await AppStorage.I.clearClientRefreshToken();
      await AppStorage.I.clearClientEmail();
      await AppStorage.I.clearClientPhoneGatePending();
    }
  }

  Future<bool> _refreshAccessToken(RequestOptions options) async {
    if (_isRefreshing && _refreshFuture != null) {
      return _refreshFuture!;
    }

    _isRefreshing = true;

    final future = () async {
      try {
        final path = options.path;
        final deviceRole = _deviceRoleFromRequest(options);

        final isAdminRequest = deviceRole == 'admin' ||
            (deviceRole == null && _isAdminRequest(path));

        final refreshToken = isAdminRequest
            ? await AppStorage.I.getAdminRefreshToken()
            : await AppStorage.I.getClientRefreshToken();

        if (refreshToken == null || refreshToken.isEmpty) return false;

        final plainDio = Dio(
          BaseOptions(
            baseUrl: AppConfig.apiBaseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 20),
            sendTimeout: const Duration(seconds: 20),
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

        final res = await plainDio.post(
          '/auth/refresh',
          data: {'refresh_token': refreshToken},
        );

        final data = res.data;
        if (data is! Map) return false;

        final token = (data['token'] ?? '').toString();
        final newRefreshToken =
            (data['refresh_token'] ?? data['refreshToken'] ?? '').toString();

        if (token.isEmpty) return false;

        if (isAdminRequest) {
          await AppStorage.I.saveAdminToken(token);
          if (newRefreshToken.isNotEmpty) {
            await AppStorage.I.saveAdminRefreshToken(newRefreshToken);
          }
        } else {
          await AppStorage.I.saveClientToken(token);
          if (newRefreshToken.isNotEmpty) {
            await AppStorage.I.saveClientRefreshToken(newRefreshToken);
          }
        }

        return true;
      } catch (_) {
        return false;
      } finally {
        _isRefreshing = false;
        _refreshFuture = null;
      }
    }();

    _refreshFuture = future;
    return future;
  }

  Future<void> saveClientToken(String token) => AppStorage.I.saveClientToken(token);

  Future<String?> getClientToken() => AppStorage.I.getClientToken();

  Future<void> clearClientToken() => AppStorage.I.clearClientToken();

  Future<void> saveAdminToken(String token) => AppStorage.I.saveAdminToken(token);

  Future<String?> getAdminToken() => AppStorage.I.getAdminToken();

  Future<void> clearAdminToken() => AppStorage.I.clearAdminToken();

  Future<void> clearAllTokens() => AppStorage.I.clearAll();
}
