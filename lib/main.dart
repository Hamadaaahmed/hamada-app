import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const XrayVpnApp());
}

class XrayVpnApp extends StatelessWidget {
  const XrayVpnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Xray VPN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const LoginScreen(),
    );
  }
}
