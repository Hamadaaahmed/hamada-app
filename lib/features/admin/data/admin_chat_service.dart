import '../../../core/api_client.dart';

class AdminChatService {
  Future<List<Map<String, dynamic>>> listConversations() async {
    final res = await ApiClient.I.dio.get('/admin/chats');
    final data = res.data;
    if (data is! Map) return <Map<String, dynamic>>[];

    final root = Map<String, dynamic>.from(data);
    final raw = (root['conversations'] as List?) ?? const [];

    return raw.whereType<Map>().map((e) {
      final map = Map<String, dynamic>.from(e);
      return {
        'id': int.tryParse('${map['id']}') ?? 0,
        'order_id':
            map['order_id'] == null ? null : int.tryParse('${map['order_id']}'),
        'client_id': map['client_id'] == null
            ? null
            : int.tryParse('${map['client_id']}'),
        'email': (map['email'] ?? '').toString(),
        'phone': (map['phone'] ?? '').toString(),
        'unread_count': int.tryParse('${map['unread_count']}') ?? 0,
        'last_message': (map['last_message'] ?? '').toString(),
        'last_message_at': (map['last_message_at'] ?? '').toString(),
        'created_at': (map['created_at'] ?? '').toString(),
      };
    }).toList();
  }

  Future<Map<String, dynamic>> getMessages(int conversationId) async {
    final res = await ApiClient.I.dio.get('/admin/chats/$conversationId/messages');
    final data = res.data;

    if (data is! Map) {
      return {
        'ok': false,
        'error': 'BAD_RESPONSE',
        'messages': <Map<String, dynamic>>[],
      };
    }

    final root = Map<String, dynamic>.from(data);
    final conv = root['conversation'];
    final raw = (root['messages'] as List?) ?? const [];

    return {
      'ok': root['ok'] == true,
      'conversation': conv is Map
          ? {
              'id': int.tryParse('${conv['id']}') ?? 0,
              'order_id': conv['order_id'] == null
                  ? null
                  : int.tryParse('${conv['order_id']}'),
              'client_id': conv['client_id'] == null
                  ? null
                  : int.tryParse('${conv['client_id']}'),
              'email': (conv['email'] ?? '').toString(),
              'phone': (conv['phone'] ?? '').toString(),
              'created_at': (conv['created_at'] ?? '').toString(),
            }
          : null,
      'messages': raw.whereType<Map>().map((e) {
        final map = Map<String, dynamic>.from(e);
        return {
          'id': int.tryParse('${map['id']}') ?? 0,
          'conversation_id': int.tryParse('${map['conversation_id']}') ?? 0,
          'sender_role': (map['sender_role'] ?? '').toString(),
          'sender_id': map['sender_id'] == null
              ? null
              : int.tryParse('${map['sender_id']}'),
          'text': (map['text'] ?? '').toString(),
          'created_at': (map['created_at'] ?? '').toString(),
          'read_at': (map['read_at'] ?? '').toString(),
          'seen_at': (map['seen_at'] ?? '').toString(),
          'is_read': map['is_read'] == true ||
              '${map['is_read']}'.toLowerCase() == 'true',
        };
      }).toList(),
      'error': root['error'],
    };
  }

  Future<Map<String, dynamic>> sendMessage({
    required int conversationId,
    required String text,
  }) async {
    final res = await ApiClient.I.dio.post(
      '/admin/chats/$conversationId/messages',
      data: {'text': text},
    );

    if (res.data is! Map) {
      return {'ok': false, 'error': 'BAD_RESPONSE'};
    }
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> markSeen(int conversationId) async {
    final res = await ApiClient.I.dio.post('/admin/chats/$conversationId/seen');
    if (res.data is! Map) {
      return {'ok': false, 'error': 'BAD_RESPONSE'};
    }
    return Map<String, dynamic>.from(res.data as Map);
  }
}
