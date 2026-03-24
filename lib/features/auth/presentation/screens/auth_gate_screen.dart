import 'package:flutter/material.dart';

import '../../../../app/router.dart';
import '../../../../core/secure_storage.dart';
import '../../data/auth_service.dart';

class AuthGateScreen extends StatefulWidget {
  const AuthGateScreen({super.key});

  @override
  State<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<AuthGateScreen> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final adminToken = await AppStorage.I.getAdminToken();
    final clientToken = await AppStorage.I.getClientToken();
    final clientEmail = await AppStorage.I.getClientEmail();
    bool clientPhoneGatePending =
        await AppStorage.I.isClientPhoneGatePending();

    final hasAdminToken = adminToken != null && adminToken.isNotEmpty;
    final hasClientToken = clientToken != null && clientToken.isNotEmpty;
    final hasClientEmail = clientEmail != null && clientEmail.trim().isNotEmpty;

    if (hasClientToken && hasClientEmail && clientPhoneGatePending) {
      try {
        final phoneStatus =
            await AuthService().getPhoneStatus(clientEmail.trim().toLowerCase());

        if (phoneStatus.ok && phoneStatus.hasPhone) {
          await AppStorage.I.clearClientPhoneGatePending();
          clientPhoneGatePending = false;
        }
      } catch (_) {}
    }

    if (!mounted) return;

    final nextRoute = hasAdminToken
        ? AppRouter.adminHome
        : (hasClientToken
            ? ((clientPhoneGatePending && hasClientEmail)
                ? AppRouter.clientPhoneGate
                : AppRouter.clientHome)
            : AppRouter.clientEmail);

    Navigator.pushReplacementNamed(
      context,
      nextRoute,
      arguments: nextRoute == AppRouter.clientPhoneGate ? clientEmail : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
