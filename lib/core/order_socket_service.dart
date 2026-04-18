import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import '../config/app_config.dart';
import 'local_alert_service.dart';

class OrderSocketService {
  OrderSocketService._();

  static final OrderSocketService I = OrderSocketService._();

  io.Socket? _socket;
  StreamController<Map<String, dynamic>>? _controller;
  String? _token;
  String? _role;
  int? _clientId;

  void _emitSystemEvent(String name, [Map<String, dynamic>? extra]) {
    final payload = <String, dynamic>{
      '_socket_event': name,
      if (extra != null) ...extra,
    };
    _controller?.add(payload);
  }

  Stream<Map<String, dynamic>> connect({
    required String token,
    required String role,
    int? clientId,
  }) {
    final shouldReuse = _socket != null &&
        _socket!.connected &&
        _token == token &&
        _role == role &&
        _clientId == clientId &&
        _controller != null &&
        !_controller!.isClosed;

    if (shouldReuse) {
      _emitJoinOrders();
      return _controller!.stream;
    }

    disconnect();

    _token = token;
    _role = role;
    _clientId = clientId;
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

    _socket!.onConnect((_) {
      _emitSystemEvent('connected');
      _emitJoinOrders();
    });

    _socket!.onReconnect((_) {
      _emitSystemEvent('reconnected');
      _emitJoinOrders();
    });

    _socket!.onDisconnect((reason) {
      _emitSystemEvent('disconnected', {
        'reason': reason?.toString() ?? '',
      });
    });

    _socket!.onConnectError((error) {
      _emitSystemEvent('connect_error', {
        'error': error?.toString() ?? '',
      });
    });

    _socket!.onError((error) {
      _emitSystemEvent('error', {
        'error': error?.toString() ?? '',
      });
    });

    for (final event in ['order_created', 'order_updated', 'orders_changed']) {
      _socket!.on(event, (data) {
        if (data is Map) {
          final map = Map<String, dynamic>.from(data);
          map['_event'] = event;

          final entityId = (map['id'] ??
                  map['order_id'] ??
                  map['other_request_id'] ??
                  '')
              .toString();

          if (event == 'order_created') {
            LocalAlertService.I.show(
              id: DateTime.now().millisecondsSinceEpoch,
              title: 'طلب جديد',
              body: 'تم استلام طلب صيانة جديد',
              dedupeKey: 'socket|order_created|$entityId',
              payloadData: map,
            );
          } else if (event == 'order_updated') {
            LocalAlertService.I.show(
              id: DateTime.now().millisecondsSinceEpoch,
              title: 'تحديث طلب',
              body: 'تم تحديث حالة أحد الطلبات',
              dedupeKey: 'socket|order_updated|$entityId|${map['status'] ?? ''}',
              payloadData: map,
            );
          }

          _controller?.add(map);
        }
      });
    }

    _socket!.connect();
    return _controller!.stream;
  }

  void _emitJoinOrders() {
    final socket = _socket;
    if (socket == null) return;
    socket.emit('join_orders', {
      'role': _role,
      if ((_clientId ?? 0) > 0) 'clientId': _clientId,
    });
  }

  void disconnect() {
    _socket?.dispose();
    _socket?.disconnect();
    _socket = null;
    _token = null;
    _role = null;
    _clientId = null;
    _controller?.close();
    _controller = null;
  }
}
