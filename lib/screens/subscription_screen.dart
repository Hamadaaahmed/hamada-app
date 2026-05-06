import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  Future<void> openTelegram() async {
    final uri = Uri.parse('https://t.me/Hamada_net');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080B12),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_clock, size: 90, color: Colors.orangeAccent),
              const SizedBox(height: 24),
              const Text(
                'انتهت التجربة',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              const Text(
                'للاشتراك الشهري تواصل معنا على تليجرام لتحديد طريقة الدفع.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 30),
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
    );
  }
}
