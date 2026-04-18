import 'package:flutter/material.dart';

import '../app/router.dart';
import 'api_client.dart';
import 'secure_storage.dart';

class NotificationNavigationService {
  NotificationNavigationService._();

  static final NotificationNavigationService I =
      NotificationNavigationService._();

  Map<String, dynamic>? _pendingData;
  bool _isProcessingPending = false;

  int _intValue(dynamic value) {
    return int.tryParse('${value ?? ''}') ?? 0;
  }

  String _textValue(dynamic value) {
    return (value ?? '').toString().trim().toLowerCase();
  }

  bool _isOrderType(String type) {
    return type.contains('order') && !type.contains('other_request');
  }

  bool _isOtherRequestType(String type) {
    return type.contains('other_request') ||
        type.contains('machine_request') ||
        type.contains('spare_part_request');
  }

  bool _isAccountType(String type) {
    return type.contains('account_credit') || type.contains('account_debt');
  }

  bool _isAnnouncementType(String type) {
    return type.contains('announcement') || type.contains('post');
  }

  Map<String, dynamic> _normalizeData(Map<String, dynamic> data) {
    final normalized = Map<String, dynamic>.from(data);
    final type = _textValue(normalized['type']);
    final id = _intValue(normalized['id']);

    if (_intValue(normalized['order_id']) <= 0 && id > 0 && _isOrderType(type)) {
      normalized['order_id'] = id;
    }

    if (_intValue(normalized['other_request_id']) <= 0 &&
        id > 0 &&
        _isOtherRequestType(type)) {
      normalized['other_request_id'] = id;
    }

    if (_intValue(normalized['conversation_id']) <= 0 &&
        _intValue(normalized['conversationId']) > 0) {
      normalized['conversation_id'] = _intValue(normalized['conversationId']);
    }

    if (_intValue(normalized['conversationId']) <= 0 &&
        _intValue(normalized['conversation_id']) > 0) {
      normalized['conversationId'] = _intValue(normalized['conversation_id']);
    }

    return normalized;
  }

  void queuePending(Map<String, dynamic> data) {
    _pendingData = _normalizeData(data);
  }

  Future<bool> openFromData({
    required NavigatorState navigator,
    required Map<String, dynamic> data,
    required bool isAdmin,
  }) async {
    final normalized = _normalizeData(data);

    final orderId = _intValue(normalized['order_id']);
    if (orderId > 0) {
      await navigator.pushNamed(
        isAdmin ? AppRouter.adminOrderDetails : AppRouter.clientOrderDetails,
        arguments: orderId,
      );
      return true;
    }

    final otherRequestId = _intValue(normalized['other_request_id']);
    if (otherRequestId > 0) {
      await navigator.pushNamed(
        isAdmin
            ? AppRouter.adminOtherRequestDetails
            : AppRouter.clientOtherRequestDetails,
        arguments: otherRequestId,
      );
      return true;
    }

    final conversationId =
        _intValue(normalized['conversationId'] ?? normalized['conversation_id']);
    if (conversationId > 0) {
      await navigator.pushNamed(
        isAdmin ? AppRouter.adminChatDetails : AppRouter.clientChat,
        arguments: isAdmin ? conversationId : null,
      );
      return true;
    }

    final type = _textValue(normalized['type']);
    if (!isAdmin && _isAccountType(type)) {
      await navigator.pushNamed(AppRouter.clientAccount);
      return true;
    }

    if (!isAdmin && _isAnnouncementType(type)) {
      await navigator.pushNamed(AppRouter.clientHome);
      return true;
    }

    return false;
  }

  Future<bool> openFromDataGlobal(Map<String, dynamic> data) async {
    final navigator = AppNavigator.key.currentState;
    if (navigator == null) {
      return false;
    }

    final normalized = _normalizeData(data);
    final explicitRole =
        _textValue(normalized['role'] ?? normalized['target_role']);

    bool isAdmin;
    if (explicitRole == 'admin' || explicitRole == 'supervisor') {
      isAdmin = true;
    } else if (explicitRole == 'client') {
      isAdmin = false;
    } else {
      final adminToken = await AppStorage.I.getAdminToken();
      final clientToken = await AppStorage.I.getClientToken();
      isAdmin = (adminToken ?? '').isNotEmpty && (clientToken ?? '').isEmpty;
    }

    return openFromData(
      navigator: navigator,
      data: normalized,
      isAdmin: isAdmin,
    );
  }

  Future<bool> openOrQueueGlobal(Map<String, dynamic> data) async {
    final opened = await openFromDataGlobal(data);
    if (!opened && AppNavigator.key.currentState == null) {
      queuePending(data);
    }
    return opened;
  }

  Future<void> processPending() async {
    if (_isProcessingPending) return;

    final navigator = AppNavigator.key.currentState;
    final pending = _pendingData;

    if (navigator == null || pending == null || pending.isEmpty) {
      return;
    }

    _isProcessingPending = true;
    _pendingData = null;

    try {
      await openFromDataGlobal(pending);
    } finally {
      _isProcessingPending = false;
    }
  }
}
