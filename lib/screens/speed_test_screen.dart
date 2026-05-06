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
  List<Map<String, dynamic>> bestIps = [];

  @override
  void initState() {
    super.initState();
    flutterV2ray = FlutterV2ray(onStatusChanged: (_) {});
    flutterV2ray.initializeV2Ray();
  }

  String replaceVmessAddress(String vmessUrl, String newAddress) {
    var raw = vmessUrl.substring(8);
    while (raw.length % 4 != 0) {
      raw += '=';
    }

    final json = utf8.decode(base64Decode(raw));
    final data = jsonDecode(json);

    data['add'] = newAddress;

    final encoded = base64Encode(utf8.encode(jsonEncode(data)));
    return 'vmess://$encoded';
  }

  Future<void> startTest() async {
    if (testing) return;

    setState(() {
      testing = true;
      tested = 0;
      bestIps = [];
    });

    try {
      final device = await DeviceService().getDeviceData();
      final deviceId = device['device_id'] ?? '';

      final config = await api.getVpnConfig();
      final vmess = (config['vmessUrl'] ?? config['config']).toString();
      final ips = await api.getSpeedIps();

      for (final ip in ips) {
        final testVmess = replaceVmessAddress(vmess, ip);
        final fullConfig = FlutterV2ray.parseFromURL(testVmess).getFullConfiguration();

        int delay = 999999;
        try {
          delay = await flutterV2ray.getServerDelay(
            config: fullConfig,
            url: 'https://www.gstatic.com/generate_204',
          );
        } catch (_) {}

        tested++;

        if (delay > 0 && delay < 1500) {
          bestIps.add({'ip': ip, 'delay': delay});
          bestIps.sort((a, b) => a['delay'].compareTo(b['delay']));
          bestIps = bestIps.take(5).toList();

          await api.saveFastIps(
            deviceId: deviceId,
            fastIps: bestIps.map((e) => '${e['ip']} - ${e['delay']}ms').toList(),
          );
        }

        if (!mounted) return;
        setState(() {});
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في الاختبار: $e')),
      );
    }

    if (!mounted) return;
    setState(() => testing = false);
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
            const SizedBox(height: 12),
            Text('أسرع IPs: ${bestIps.length}'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: testing ? null : startTest,
                child: Text(testing ? 'جاري الاختبار...' : 'بدء اختبار الاتصال الحقيقي'),
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
