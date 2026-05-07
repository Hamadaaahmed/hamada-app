import 'package:flutter/material.dart';
import 'services/security_service.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SecurityService.enableScreenProtection();

  final unsafe = await SecurityService.isDeviceUnsafe();

  runApp(XrayVpnApp(blocked: unsafe));
}

class XrayVpnApp extends StatelessWidget {
  const XrayVpnApp({super.key, this.blocked = false});

  final bool blocked;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Xray VPN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: blocked
          ? const Scaffold(
              backgroundColor: Color(0xFF080B12),
              body: Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'تم إيقاف التطبيق لأسباب أمنية',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22),
                  ),
                ),
              ),
            )
          : const LoginScreen(),
    );
  }
}
