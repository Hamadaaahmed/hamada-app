import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import '../config/app_config.dart';
import 'local_alert_service.dart';
import 'secure_storage.dart';

class ChatSocketService {
  ChatSocketService._();
  static final ChatSocketService I = ChatSocketService._();

  io.Socket? _socket;
  StreamController<Map<String, dynamic>>? _controller;
  int? _conversationId;
  String? _token;
  String? _role;

  Stream<Map<String, dynamic>> connectAndJoin({
    required String token,
    required String role,
    required int conversationId,
  }) {
    final shouldReuse = _socket != null &&
        _socket!.connected &&
        _conversationId == conversationId &&
        _token == token &&
        _role == role &&
        _controller != null &&
        !_controller!.isClosed;

    if (shouldReuse) {
      _emitJoin();
      return _controller!.stream;
    }

    disconnect();

    _conversationId = conversationId;
    _token = token;
    _role = role;
    _controller = StreamController<Map<String, dynamic>>.broadcast();

    _socket = io.io(
      AppConfig.chatBaseUrl,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .setPath('/socket.io/')
          .enableReconnection()
          .setReconnectionAttempts(999999)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .disableAutoConnect()
          .setTimeout(20000)
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .build(),
    );

    _socket!.onConnect((_) => _emitJoin());
    _socket!.onReconnect((_) => _emitJoin());

    _socket!.on('message', (data) {
      if (data is Map) {
        final map = Map<String, dynamic>.from(data);
        map['_event'] = 'message';

        final senderRole =
            (map['sender_role'] ?? '').toString().trim().toLowerCase();

        if (!_isSameSideAsCurrentUser(senderRole)) {
          LocalAlertService.I.show(
            id: DateTime.now().millisecondsSinceEpoch,
            title: 'رسالة جديدة',
            body: 'لديك رسالة جديدة',
          );
        }

        _controller?.add(map);
      }
    });

    _socket!.on('seen', (data) {
      if (data is Map) {
        final map = Map<String, dynamic>.from(data);
        map['_event'] = 'seen';
        _controller?.add(map);
      }
    });

    _socket!.connect();
    return _controller!.stream;
  }

  bool _isSameSideAsCurrentUser(String senderRole) {
    final currentRole = (_role ?? '').trim().toLowerCase();

    final senderIsAdminSide =
        senderRole == 'admin' || senderRole == 'supervisor';
    final senderIsClientSide =
        senderRole == 'client' ||
        senderRole == 'customer' ||
        senderRole == 'user';

    final currentIsAdminSide =
        currentRole == 'admin' || currentRole == 'supervisor';
    final currentIsClientSide = currentRole == 'client';

    return (currentIsAdminSide && senderIsAdminSide) ||
        (currentIsClientSide && senderIsClientSide);
  }

  void _emitJoin() {
    final socket = _socket;
    final conversationId = _conversationId;
    if (socket == null || conversationId == null) return;
    socket.emit('join', {'conversationId': conversationId});
  }

  void sendMessageEvent(Map<String, dynamic> data) {
    final payload = Map<String, dynamic>.from(data);
    final conversationId =
        int.tryParse('${payload['conversationId'] ?? payload['conversation_id']}') ??
            0;

    if (conversationId > 0) {
      payload['conversationId'] = conversationId;
      payload['conversation_id'] = conversationId;
    }

    _socket?.emit('message', payload);
  }

  Future<String?> getTokenForRole(String role) async {
    if (role == 'admin' || role == 'supervisor') {
      return AppStorage.I.getAdminToken();
    }
    return AppStorage.I.getClientToken();
  }

  void disconnect() {
    _socket?.dispose();
    _socket?.disconnect();
    _socket = null;
    _conversationId = null;
    _token = null;
    _role = null;
    _controller?.close();
    _controller = null;
  }
}
