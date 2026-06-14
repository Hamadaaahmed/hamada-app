import 'package:flutter/material.dart';
import 'api_client.dart';

import '../app/router.dart';
import 'secure_storage.dart';

class NotificationNavigationService {
  NotificationNavigationService._();

  static final NotificationNavigationService I =
      NotificationNavigationService._();

  int _intValue(dynamic value) {
    return int.tryParse('${value ?? ''}') ?? 0;
  }

  Future<bool> openFromData({
    required NavigatorState navigator,
    required Map<String, dynamic> data,
    required bool isAdmin,
  }) async {
    final orderId = _intValue(data['order_id']);
    if (orderId > 0) {
      await navigator.pushNamed(
        isAdmin ? AppRouter.adminOrderDetails : AppRouter.clientOrderDetails,
        arguments: orderId,
      );
      return true;
    }

    final otherRequestId = _intValue(data['other_request_id']);
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
        _intValue(data['conversationId'] ?? data['conversation_id']);
    if (conversationId > 0) {
      await navigator.pushNamed(
        isAdmin ? AppRouter.adminChatDetails : AppRouter.clientChat,
        arguments: isAdmin ? conversationId : null,
      );
      return true;
    }

    return false;
  }

  Future<bool> openFromDataGlobal(Map<String, dynamic> data) async {
    final navigator = AppNavigator.key.currentState;
    if (navigator == null) return false;

    final explicitRole = (data['role'] ?? data['target_role'] ?? '')
        .toString()
        .trim()
        .toLowerCase();

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
      data: data,
      isAdmin: isAdmin,
    );
  }
}
