import 'package:flutter/material.dart';

class AppFeedback {
  AppFeedback._();

  static SnackBar success(String message) {
    return SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF166534),
    );
  }

  static SnackBar error(String message) {
    return SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFFB91C1C),
    );
  }

  static SnackBar info(String message) {
    return SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
    );
  }

  static void show(
    BuildContext context, {
    required String message,
    bool error = false,
    bool success = false,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    if (error) {
      messenger.showSnackBar(AppFeedback.error(message));
      return;
    }

    if (success) {
      messenger.showSnackBar(AppFeedback.success(message));
      return;
    }

    messenger.showSnackBar(AppFeedback.info(message));
  }
}
