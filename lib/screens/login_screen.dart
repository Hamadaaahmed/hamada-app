import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../services/device_service.dart';
import 'vpn_home_screen.dart';
import 'subscription_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final api = ApiService();
  final device = DeviceService();

  bool loading = false;
  String? deviceId;

  Future<void> login() async {
    setState(() => loading = true);

    try {
      final deviceData = await device.getDeviceData();
      final loginResult = await api.deviceLogin(deviceData);

      if (loginResult['is_active'] == false) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
        );
        return;
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const VpnHomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تسجيل الجهاز: $e')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080B12),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Icon(Icons.vpn_lock, size: 90, color: Colors.greenAccent),
                const SizedBox(height: 22),
                const Text(
                  'XRAY VPN',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),
                const Text(
                  'اضغط تسجيل الدخول لتفعيل تجربة 3 أيام على هذا الجهاز',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 30),
                if (deviceId != null) ...[
                  SelectableText(
                    'Device ID:\n$deviceId',
                    textAlign: TextAlign.center,
                  ),
                  TextButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: deviceId!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم نسخ Device ID')),
                      );
                    },
                    child: const Text('نسخ Device ID'),
                  ),
                  const SizedBox(height: 16),
                ],
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: loading ? null : login,
                    child: loading
                        ? const CircularProgressIndicator()
                        : const Text('تسجيل الدخول', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
