import 'dart:io';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/device_service.dart';

class SpeedTestScreen extends StatefulWidget {
  const SpeedTestScreen({super.key});

  @override
  State<SpeedTestScreen> createState() => _SpeedTestScreenState();
}

class _SpeedTestScreenState extends State<SpeedTestScreen> {
  final api = ApiService();
  final device = DeviceService();

  bool testing = false;
  int tested = 0;
  List<String> fastIps = [];

  Future<int?> testIp(String ip) async {
    final start = DateTime.now();

    try {
      final socket = await Socket.connect(
        ip,
        443,
        timeout: const Duration(milliseconds: 900),
      );
      socket.destroy();

      return DateTime.now().difference(start).inMilliseconds;
    } catch (_) {
      return null;
    }
  }

  Future<void> startTest() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('اختبار السرعة'),
        content: const Text(
          'سيتم اختبار مجموعة IPs مختلفة. قد يستغرق الاختبار وقتاً، وأي IP سريع سيتم حفظه على السيرفر.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ابدأ'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    setState(() {
      testing = true;
      tested = 0;
      fastIps = [];
    });

    try {
      final deviceData = await device.getDeviceData();
      final ips = await api.getSpeedIps();

      for (final ip in ips) {
        if (!mounted) return;

        final ping = await testIp(ip);
        tested++;

        if (ping != null && ping <= 350) {
          final value = '$ip - ${ping}ms';

          if (!fastIps.contains(value)) {
            fastIps.add(value);
            await api.saveFastIps(
              deviceId: deviceData['device_id']!,
              fastIps: fastIps,
            );
          }
        }

        setState(() {});
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في الاختبار: $e')),
      );
    } finally {
      if (mounted) setState(() => testing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080B12),
      appBar: AppBar(
        title: const Text('اختبار السرعة'),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('تم اختبار: $tested IP'),
            const SizedBox(height: 10),
            Text('IPs سريعة: ${fastIps.length}'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: testing ? null : startTest,
                child: Text(testing ? 'جاري الاختبار...' : 'بدء اختبار السرعة'),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: fastIps.map((ip) => ListTile(
                  leading: const Icon(Icons.flash_on),
                  title: Text(ip),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
