import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/device_service.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String? deviceId;

  @override
  void initState() {
    super.initState();
    loadDeviceId();
  }

  Future<void> loadDeviceId() async {
    final data = await DeviceService().getDeviceData();
    if (!mounted) return;
    setState(() => deviceId = data['device_id']);
  }

  Future<void> openTelegram() async {
    final uri = Uri.parse('https://t.me/Hamada_net');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void copyDeviceId() {
    if (deviceId == null) return;
    Clipboard.setData(ClipboardData(text: deviceId!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم نسخ Device ID')),
    );
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_clock, size: 90, color: Colors.orangeAccent),
                const SizedBox(height: 24),
                const Text('انتهت التجربة', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),
                const Text(
                  'للاشتراك الشهري تواصل معنا على تليجرام لتحديد طريقة الدفع.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 24),
                if (deviceId != null) ...[
                  SelectableText(
                    'Device ID:\n$deviceId',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                  TextButton(
                    onPressed: copyDeviceId,
                    child: const Text('نسخ Device ID'),
                  ),
                  const SizedBox(height: 16),
                ],
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: openTelegram,
                    child: const Text('التواصل عبر تليجرام @Hamada_net'),
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
