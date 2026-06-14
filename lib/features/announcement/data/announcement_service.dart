import 'package:drift/drift.dart';

import '../../../core/api_client.dart';
import '../../../core/local_db/app_database.dart';
import '../../../core/local_db/db.dart';

class AnnouncementService {
  Future<Map<String, dynamic>> getAnnouncement() async {
    try {
      final res = await ApiClient.I.dio.get('/announcement');
      final root = Map<String, dynamic>.from(res.data as Map);
      final raw = root['announcement'];

      final result = {
        'ok': root['ok'] == true,
        'announcement': raw is Map
            ? {
                'id': int.tryParse('${raw['id']}') ?? 1,
                'message': (raw['message'] ?? '').toString(),
                'is_active': raw['is_active'] == true ||
                    '${raw['is_active']}'.toLowerCase() == 'true',
                'updated_at': (raw['updated_at'] ?? '').toString(),
              }
            : null,
        'error': root['error'],
      };

      final ann = result['announcement'];
      if (result['ok'] == true && ann is Map<String, dynamic>) {
        await DB.I.database.saveAnnouncement(
          CachedAnnouncementsCompanion(
            id: const Value(1),
            message: Value((ann['message'] ?? '').toString()),
            isActive: Value(ann['is_active'] == true),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }

      return result;
    } catch (_) {
      final cached = await DB.I.database.getAnnouncement();

      if (cached == null) {
        return {
          'ok': false,
          'announcement': null,
          'error': 'CACHE_EMPTY',
        };
      }

      return {
        'ok': true,
        'announcement': {
          'id': cached.id,
          'message': cached.message,
          'is_active': cached.isActive,
          'updated_at': cached.updatedAt.toIso8601String(),
        },
        'error': null,
      };
    }
  }

  Future<Map<String, dynamic>> setAnnouncement(String message) async {
    final res = await ApiClient.I.dio.post(
      '/admin/announcement',
      data: {'message': message},
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> clearAnnouncement() async {
    final res = await ApiClient.I.dio.delete('/admin/announcement');
    return Map<String, dynamic>.from(res.data as Map);
  }
}
