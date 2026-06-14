import 'dart:convert';

class TokenUtils {
  static Map<String, dynamic>? parsePayload(String? token) {
    if (token == null || token.isEmpty) return null;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final normalized = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final map = jsonDecode(decoded);
      if (map is Map<String, dynamic>) return map;
      if (map is Map) return Map<String, dynamic>.from(map);
      return null;
    } catch (_) {
      return null;
    }
  }

  static int extractUserId(String? token) {
    final payload = parsePayload(token);
    if (payload == null) return 0;
    return int.tryParse(
          '${payload['id'] ?? payload['client_id'] ?? payload['admin_id'] ?? payload['sub']}',
        ) ??
        0;
  }

  static DateTime? extractExpiry(String? token) {
    final payload = parsePayload(token);
    if (payload == null) return null;
    final exp = int.tryParse('${payload['exp']}');
    if (exp == null || exp <= 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
  }

  static bool isExpired(String? token, {Duration skew = const Duration(minutes: 1)}) {
    final expiry = extractExpiry(token);
    if (expiry == null) return false;
    return DateTime.now().toUtc().isAfter(expiry.subtract(skew));
  }
}
