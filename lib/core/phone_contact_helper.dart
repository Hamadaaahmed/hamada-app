import 'dart:convert';

import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PhoneContactHelper {
  static const _storage = FlutterSecureStorage();
  static const _cacheKey = 'phone_contact_name_cache_v1';

  static Map<String, String>? _memoryCache;

  static String _toEnglishDigits(String input) {
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    var out = input;
    for (var i = 0; i < arabic.length; i++) {
      out = out.replaceAll(arabic[i], '$i');
    }
    return out;
  }

  static String normalizePhone(String input) {
    var s = _toEnglishDigits(input).trim();
    s = s.replaceAll(RegExp(r'[^0-9+]'), '');

    if (s.startsWith('002')) {
      s = s.substring(2);
    }

    if (s.startsWith('+20')) {
      s = '0${s.substring(3)}';
    } else if (s.startsWith('20') && s.length > 10) {
      s = '0${s.substring(2)}';
    } else if (s.startsWith('+2')) {
      s = s.substring(2);
    } else if (s.startsWith('2') && s.length > 10) {
      s = s.substring(1);
    }

    return s;
  }

  static Future<Map<String, String>> _readCache() async {
    if (_memoryCache != null) return _memoryCache!;
    try {
      final raw = await _storage.read(key: _cacheKey);
      if (raw == null || raw.trim().isEmpty) {
        _memoryCache = <String, String>{};
        return _memoryCache!;
      }

      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        _memoryCache = decoded.map(
          (k, v) => MapEntry(k.toString(), (v ?? '').toString()),
        );
        return _memoryCache!;
      }
    } catch (_) {}

    _memoryCache = <String, String>{};
    return _memoryCache!;
  }

  static Future<void> _writeCache(Map<String, String> cache) async {
    _memoryCache = cache;
    try {
      await _storage.write(key: _cacheKey, value: jsonEncode(cache));
    } catch (_) {}
  }

  static Future<bool> ensurePermission() async {
    try {
      final granted = await FlutterContacts.requestPermission(readonly: true);
      return granted;
    } catch (_) {
      return false;
    }
  }

  static Future<Map<String, String>> preloadAllContacts({
    bool forceRefresh = false,
  }) async {
    final cache = forceRefresh ? <String, String>{} : await _readCache();

    final ok = await ensurePermission();
    if (!ok) return cache;

    try {
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      final next = <String, String>{...cache};

      for (final c in contacts) {
        final name = c.displayName.trim();
        if (name.isEmpty) continue;

        for (final p in c.phones) {
          final normalized = normalizePhone(p.number);
          if (normalized.isEmpty) continue;
          next[normalized] = name;
        }
      }

      await _writeCache(next);
      return next;
    } catch (_) {
      return cache;
    }
  }

  static Future<String?> findNameByPhone(String phone) async {
    final target = normalizePhone(phone);
    if (target.isEmpty) return null;

    var cache = await _readCache();
    final cached = cache[target]?.trim() ?? '';
    if (cached.isNotEmpty) return cached;

    cache = await preloadAllContacts(forceRefresh: true);

    final direct = cache[target]?.trim() ?? '';
    if (direct.isNotEmpty) return direct;

    for (final entry in cache.entries) {
      final normalized = entry.key.trim();
      final name = entry.value.trim();
      if (normalized.isEmpty || name.isEmpty) continue;

      if (normalized == target ||
          normalized.endsWith(target) ||
          target.endsWith(normalized)) {
        return name;
      }
    }

    return null;
  }

  static Future<void> clearCache() async {
    _memoryCache = <String, String>{};
    try {
      await _storage.delete(key: _cacheKey);
    } catch (_) {}
  }
}
