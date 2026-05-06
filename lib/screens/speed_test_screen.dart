import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import '../services/api_service.dart';
import '../services/device_service.dart';

class SpeedTestScreen extends StatefulWidget {
  const SpeedTestScreen({super.key});

  @override
  State<SpeedTestScreen> createState() => _SpeedTestScreenState();
}

class _SpeedTestScreenState extends State<SpeedTestScreen> {
  final api = ApiService();
  late final FlutterV2ray flutterV2ray;

  bool testing = false;
  int tested = 0;
  String state = 'DISCONNECTED';
  List<Map<String, dynamic>> bestIps = [];

  @override
  void initState() {
    super.initState();
    flutterV2ray = FlutterV2ray(
      onStatusChanged: (status) {
        if (!mounted) return;
        setState(() => state = status.state);
      },
    );
    flutterV2ray.initializeV2Ray();
  }

  String replaceVmessAddress(String vmessUrl, String newAddress) {
    var raw = vmessUrl.substring(8);
    while (raw.length % 4 != 0) {
      raw += '=';
    }

    final data = jsonDecode(utf8.decode(base64Decode(raw)));
    data['add'] = newAddress;

    return 'vmess://${base64Encode(utf8.encode(jsonEncode(data)))}';
  }

  Future<bool> waitConnected() async {
    for (int i = 0; i < 10; i++) {
      if (state == 'CONNECTED') return true;
      await Future.delayed(const Duration(seconds: 1));
    }
    return false;
  }

  Future<void> startTest() async {
    if (testing) return;

    setState(() {
      testing = true;
      tested = 0;
      bestIps = [];
    });

    try {
      final permission = await flutterV2ray.requestPermission();
      if (!permission) throw Exception('لم يتم السماح بصلاحية VPN');

      final device = await DeviceService().getDeviceData();
      final deviceId = device['device_id'] ?? '';

      final config = await api.getVpnConfig();
      final vmess = (config['vmessUrl'] ?? config['config']).toString();
      final ips = await api.getSpeedIps();

      for (final ip in ips) {
        await flutterV2ray.stopV2Ray();
        await Future.delayed(const Duration(seconds: 1));

        final testVmess = replaceVmessAddress(vmess, ip);
        final fullConfig = FlutterV2ray.parseFromURL(testVmess).getFullConfiguration();

        final watch = Stopwatch()..start();

        try {
          await flutterV2ray.startV2Ray(
            remark: 'Speed Test',
            config: fullConfig,
            proxyOnly: false,
            bypassSubnets: const ['0.0.0.0/0'],
            notificationDisconnectButtonName: 'قطع',
          );

          final ok = await waitConnected();
          watch.stop();

          if (ok) {
            final delay = watch.elapsedMilliseconds;

            bestIps.add({'ip': ip, 'delay': delay});
            bestIps.sort((a, b) => a['delay'].compareTo(b['delay']));
            bestIps = bestIps.take(5).toList();

            await api.saveFastIps(
              deviceId: deviceId,
              fastIps: bestIps.map((e) => '${e['ip']} - ${e['delay']}ms').toList(),
            );
          }
        } catch (_) {}

        await flutterV2ray.stopV2Ray();

        tested++;
        if (!mounted) return;
        setState(() {});
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في الاختبار: $e')),
      );
    }

    await flutterV2ray.stopV2Ray();

    if (!mounted) return;
    setState(() => testing = false);
  }

  @override
  void dispose() {
    flutterV2ray.stopV2Ray();
    super.dispose();
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
            const SizedBox(height: 8),
            Text('الحالة: $state'),
            const SizedBox(height: 8),
            Text('أسرع 5 IPs: ${bestIps.length}'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: testing ? null : startTest,
                child: Text(testing ? 'جاري الاتصال بكل IP...' : 'بدء اختبار اتصال حقيقي'),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: bestIps.map((e) {
                  return ListTile(
                    leading: const Icon(Icons.flash_on),
                    title: Text('${e['ip']} - ${e['delay']}ms'),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
