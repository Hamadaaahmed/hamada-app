import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BypassAppsScreen extends StatefulWidget {
  const BypassAppsScreen({super.key});

  @override
  State<BypassAppsScreen> createState() => _BypassAppsScreenState();
}

class _BypassAppsScreenState extends State<BypassAppsScreen> {
  static const MethodChannel _channel = MethodChannel('xray_vpn/device');

  bool loading = true;
  List<Map<String, String>> apps = [];
  Set<String> selected = {};

  @override
  void initState() {
    super.initState();
    loadApps();
  }

  Future<void> loadApps() async {
    final installed = await _channel.invokeListMethod('getInstalledApps') ?? [];
    final saved = await _channel.invokeListMethod<String>('loadBypassApps') ?? [];

    setState(() {
      apps = installed
          .map((e) => Map<String, String>.from(e as Map))
          .toList();
      selected = saved.toSet();
      loading = false;
    });
  }

  Future<void> save() async {
    await _channel.invokeMethod('saveBypassApps', {
      'packages': selected.toList(),
    });

    if (!mounted) return;
    Navigator.pop(context, selected.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080B12),
      appBar: AppBar(
        title: const Text('تطبيقات خارج VPN'),
        backgroundColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: save,
            child: const Text('حفظ'),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: apps.length,
              itemBuilder: (context, index) {
                final app = apps[index];
                final package = app['package'] ?? '';
                final name = app['name'] ?? package;

                return CheckboxListTile(
                  value: selected.contains(package),
                  title: Text(name),
                  subtitle: Text(package),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        selected.add(package);
                      } else {
                        selected.remove(package);
                      }
                    });
                  },
                );
              },
            ),
    );
  }
}
