import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/external_vpn_service.dart';
import 'login_screen.dart';
import 'plans_screen.dart';
import 'payment_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool loading = false;
  String statusMessage = 'غير متصل';

  Future<void> logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> openVpnExternally() async {
    setState(() {
      loading = true;
      statusMessage = 'جاري تجهيز ملف VPN...';
    });

    try {
      await ExternalVpnService.openExternalVpnApp();
      setState(() {
        statusMessage = 'تم فتح ملف VPN في التطبيق الخارجي';
      });
    } catch (e) {
      setState(() {
        statusMessage = 'فشل فتح VPN: ${e.toString()}';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonText = loading ? 'جاري التنفيذ...' : 'تشغيل VPN';

    return Scaffold(
      appBar: AppBar(
        title: const Text('VPN العربي'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_open,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            const Text(
              'اتصال آمن وسريع',
              style: TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 10),
            Text(
              statusMessage,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: loading ? null : openVpnExternally,
              child: Text(buttonText),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PlansScreen()),
                );
              },
              child: const Text('عرض الباقات'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PaymentScreen()),
                );
              },
              child: const Text('الدفع'),
            ),
          ],
        ),
      ),
    );
  }
}
