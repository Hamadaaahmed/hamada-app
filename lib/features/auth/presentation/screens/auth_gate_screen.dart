import 'package:flutter/material.dart';
import '../../../../app/router.dart';
import '../../../../core/secure_storage.dart';

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

    final token = await SecureStorage.I.read('token');
    final role = await SecureStorage.I.read('role');

    if (!mounted) return;

    String nextRoute = AppRouter.clientEmail;

    if (token != null && token.isNotEmpty) {
      nextRoute = (role == 'admin')
          ? AppRouter.adminHome
          : AppRouter.clientHome;
    }

    Navigator.pushReplacementNamed(context, nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
