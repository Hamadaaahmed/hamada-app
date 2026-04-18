import 'package:dio/dio.dart';
import 'package:drift/drift.dart';

import '../../../core/api_client.dart';
import '../../../core/local_db/app_database.dart';
import '../../../core/local_db/db.dart';

class AdminPostsService {
  Map<String, dynamic> _normalize(dynamic raw) {
    if (raw is! Map) return <String, dynamic>{};
    return {
      'id': int.tryParse('${raw['id']}') ?? 0,
      'message': (raw['message'] ?? '').toString(),
      'image_url': raw['image_url']?.toString(),
      'version': int.tryParse('${raw['version']}') ?? 1,
      'is_active': raw['is_active'] == true ||
          '${raw['is_active']}'.toLowerCase() == 'true',
      'created_at': (raw['created_at'] ?? '').toString(),
      'updated_at': (raw['updated_at'] ?? '').toString(),
    };
  }

  Future<List<Map<String, dynamic>>> listPublicPosts() async {
    try {
      final res = await ApiClient.I.dio.get('/posts');
      final root = Map<String, dynamic>.from(res.data as Map);
      final raw = (root['posts'] as List?) ?? const [];
      final list =
          raw.map(_normalize).where((e) => e.isNotEmpty).toList();

      final rows = list.map((post) {
        return CachedAdminPostsCompanion(
          id: Value(post['id'] as int),
          message: Value((post['message'] ?? '').toString()),
          imageUrl: Value((post['image_url'] ?? '').toString()),
          version: Value(int.tryParse('${post['version']}') ?? 1),
          isActive: Value(post['is_active'] == true),
          createdAt: Value((post['created_at'] ?? '').toString()),
          updatedAt: Value((post['updated_at'] ?? '').toString()),
          cachedAt: Value(DateTime.now()),
        );
      }).toList();

      await DB.I.database.replaceAdminPosts(rows);
      return list;
    } catch (_) {
      final cached = await DB.I.database.getAdminPosts();
      return cached
          .map((p) => {
                'id': p.id,
                'message': p.message,
                'image_url': p.imageUrl.isEmpty ? null : p.imageUrl,
                'version': p.version,
                'is_active': p.isActive,
                'created_at': p.createdAt,
                'updated_at': p.updatedAt,
              })
          .toList();
    }
  }

  Future<List<Map<String, dynamic>>> listAdminPosts() async {
    try {
      final res = await ApiClient.I.dio.get('/admin/posts');
      final root = Map<String, dynamic>.from(res.data as Map);
      final raw = (root['posts'] as List?) ?? const [];
      final list =
          raw.map(_normalize).where((e) => e.isNotEmpty).toList();

      final rows = list.map((post) {
        return CachedAdminPostsCompanion(
          id: Value(post['id'] as int),
          message: Value((post['message'] ?? '').toString()),
          imageUrl: Value((post['image_url'] ?? '').toString()),
          version: Value(int.tryParse('${post['version']}') ?? 1),
          isActive: Value(post['is_active'] == true),
          createdAt: Value((post['created_at'] ?? '').toString()),
          updatedAt: Value((post['updated_at'] ?? '').toString()),
          cachedAt: Value(DateTime.now()),
        );
      }).toList();

      await DB.I.database.replaceAdminPosts(rows);
      return list;
    } catch (_) {
      final cached = await DB.I.database.getAdminPosts();
      return cached
          .map((p) => {
                'id': p.id,
                'message': p.message,
                'image_url': p.imageUrl.isEmpty ? null : p.imageUrl,
                'version': p.version,
                'is_active': p.isActive,
                'created_at': p.createdAt,
                'updated_at': p.updatedAt,
              })
          .toList();
    }
  }

  Future<Map<String, dynamic>> createPost({
    required String message,
    String? imagePath,
  }) async {
    final form = FormData.fromMap({
      'message': message,
      if ((imagePath ?? '').trim().isNotEmpty)
        'image': await MultipartFile.fromFile(imagePath!),
    });

    final res = await ApiClient.I.dio.post(
      '/admin/posts',
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );

    final root = Map<String, dynamic>.from(res.data as Map);
    return {
      'ok': root['ok'] == true,
      'post': _normalize(root['post']),
      'error': root['error'],
    };
  }

  Future<Map<String, dynamic>> deletePost(int id) async {
    final res = await ApiClient.I.dio.delete('/admin/posts/$id');
    return Map<String, dynamic>.from(res.data as Map);
  }
}
