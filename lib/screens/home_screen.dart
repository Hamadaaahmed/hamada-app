import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/auth_service.dart';
import '../services/vpn_service.dart';
import 'login_screen.dart';
import 'plans_screen.dart';
import 'payment_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool vpnConnected = false;
  bool loading = false;
  String statusMessage = 'غير متصل';

  @override
  void initState() {
    super.initState();
    setupVpn();

    VpnService.stageNotifier.addListener(_handleVpnStageChange);
  }

  void _handleVpnStageChange() {
    if (!mounted) return;

    final stage = VpnService.stageNotifier.value;
    final lower = stage.toLowerCase().trim();

    setState(() {
      statusMessage = stage;

      if (lower == 'connected' ||
          lower == 'authenticated' ||
          lower == 'connected_success') {
        vpnConnected = true;
        loading = false;
      } else if (lower == 'disconnected' ||
          lower == 'disconnect' ||
          lower == 'noprocess' ||
          lower == 'nonetwork' ||
          lower == 'wait_connection') {
        vpnConnected = false;
        loading = false;
      } else if (lower.contains('connect')) {
        loading = true;
      } else if (lower.contains('disconnect')) {
        loading = true;
      }
    });
  }

  Future<void> setupVpn() async {
    await Permission.notification.request();
    await VpnService.initialize();
  }

  Future<void> logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> toggleVpn() async {
    setState(() {
      loading = true;
      statusMessage = vpnConnected ? 'جاري فصل الاتصال...' : 'جاري الاتصال...';
    });

    try {
      if (vpnConnected) {
        await VpnService.disconnect();
      } else {
        await VpnService.connect();
      }
    } catch (e) {
      setState(() {
        loading = false;
        vpnConnected = false;
        statusMessage = 'فشل الاتصال: ${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    VpnService.stageNotifier.removeListener(_handleVpnStageChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonText = loading
        ? 'جاري التنفيذ...'
        : (vpnConnected ? 'فصل VPN' : 'تشغيل VPN');

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
            Icon(
              vpnConnected ? Icons.lock : Icons.lock_open,
              size: 80,
              color: vpnConnected ? Colors.green : Colors.grey,
            ),
            const SizedBox(height: 20),
            const Text(
              'اتصال آمن وسريع',
              style: TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 10),
            Text(
              statusMessage == 'disconnected' ? 'غير متصل' : statusMessage,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: loading ? null : toggleVpn,
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
