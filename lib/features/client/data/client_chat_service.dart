import '../../../core/api_client.dart';

class ClientChatService {
  Future<Map<String, dynamic>> getConversation() async {
    final res = await ApiClient.I.dio.get('/client/chat');
    final data = res.data;

    if (data is! Map) {
      return {'ok': false, 'error': 'BAD_RESPONSE'};
    }

    final root = Map<String, dynamic>.from(data);
    final conv = root['conversation'];

    return {
      'ok': root['ok'] == true,
      'conversation': conv is Map
          ? {
              'id': int.tryParse('${conv['id']}') ?? 0,
              'order_id': conv['order_id'],
              'client_id': int.tryParse('${conv['client_id']}') ?? 0,
              'created_at': (conv['created_at'] ?? '').toString(),
            }
          : null,
      'error': root['error'],
    };
  }

  Future<Map<String, dynamic>> getMessages() async {
    final res = await ApiClient.I.dio.get('/client/chat/messages');
    final data = res.data;

    if (data is! Map) {
      return {
        'ok': false,
        'error': 'BAD_RESPONSE',
        'messages': <Map<String, dynamic>>[]
      };
    }

    final root = Map<String, dynamic>.from(data);
    final raw = (root['messages'] as List?) ?? const [];

    return {
      'ok': root['ok'] == true,
      'conversation_id': int.tryParse('${root['conversation_id']}') ?? 0,
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

  Future<Map<String, dynamic>> sendMessage(String text) async {
    final res = await ApiClient.I.dio.post(
      '/client/chat/messages',
      data: {'text': text},
    );

    if (res.data is! Map) {
      return {'ok': false, 'error': 'BAD_RESPONSE'};
    }

    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> markSeen() async {
    final res = await ApiClient.I.dio.post('/client/chat/seen');
    if (res.data is! Map) {
      return {'ok': false, 'error': 'BAD_RESPONSE'};
    }
    return Map<String, dynamic>.from(res.data as Map);
  }
}
