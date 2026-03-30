import 'package:flutter/material.dart';
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
    VpnService.initialize();
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
        setState(() {
          vpnConnected = false;
          statusMessage = 'تم فصل الاتصال';
        });
      } else {
        await VpnService.connect();
        setState(() {
          vpnConnected = true;
          statusMessage = 'تم الاتصال بنجاح';
        });
      }
    } catch (e) {
      setState(() {
        statusMessage = 'فشل الاتصال: ${e.toString()}';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              statusMessage,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: loading ? null : toggleVpn,
              child: Text(
                loading
                    ? 'جاري التنفيذ...'
                    : (vpnConnected ? 'فصل VPN' : 'تشغيل VPN'),
              ),
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
