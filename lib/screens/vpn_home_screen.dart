import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import '../services/api_service.dart';
import 'subscription_screen.dart';
import 'bypass_apps_screen.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VpnHomeScreen extends StatefulWidget {
  const VpnHomeScreen({super.key});

  @override
  State<VpnHomeScreen> createState() => _VpnHomeScreenState();
}

class _VpnHomeScreenState extends State<VpnHomeScreen> {
  final api = ApiService();

  late final FlutterV2ray flutterV2ray;

  bool connected = false;
  bool loading = false;
  Map<String, dynamic>? config;
  static const MethodChannel _channel = MethodChannel('xray_vpn/device');
  List<String> bypassApps = [];
  String vpnState = 'DISCONNECTED';
  String appName = 'HAMADA NET vip';
  Timer? subscriptionTimer;
  String configUpdatedAt = '';
  bool autoConnect = false;
  bool backgroundMode = false;

  Future<void> loadConfig() async {
    setState(() => loading = true);

    try {
      final result = await api.getVpnConfig();
      setState(() {
        config = result;
        appName = result['appName']?.toString() ?? 'HAMADA NET vip';
        configUpdatedAt = result['configUpdatedAt']?.toString() ?? '';
      });
    } catch (e) {
      if (!mounted) return;

      final msg = e.toString();

      if (msg.contains('subscription expired') || msg.contains('403')) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في جلب الكونفج: $e')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> toggleVpn() async {
    await startOrStopVpn();
  }

  Future<void> startOrStopVpn() async {
    try {
      if (connected) {
        await flutterV2ray.stopV2Ray();
        setState(() => connected = false);
        return;
      }

      final vmessUrl = config?['vmessUrl'] ?? config?['config'];

      if (vmessUrl == null || vmessUrl.toString().isEmpty) {
        await loadConfig();
    loadBypassApps();
      }

      final finalVmessUrl = config?['vmessUrl'] ?? config?['config'];

      if (finalVmessUrl == null || finalVmessUrl.toString().isEmpty) {
        throw Exception('لا يوجد كونفج VPN');
      }

      final permission = await flutterV2ray.requestPermission();

      if (!permission) {
        throw Exception('لم يتم السماح بصلاحية VPN');
      }

      final v2rayUrl = FlutterV2ray.parseFromURL(finalVmessUrl.toString());
      final fullConfig = v2rayUrl.getFullConfiguration();

      await flutterV2ray.startV2Ray(
        remark: appName,
        config: fullConfig,
        blockedApps: bypassApps,
        proxyOnly: false,
        bypassSubnets: const ['0.0.0.0/0'],
        notificationDisconnectButtonName: 'قطع الاتصال',
      );

      setState(() => connected = true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تشغيل VPN: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    flutterV2ray = FlutterV2ray(
      onStatusChanged: (status) {
        if (!mounted) return;
        setState(() {
          vpnState = status.state;
          connected = status.state == 'CONNECTED';
        });
      },
    );

    flutterV2ray.initializeV2Ray();
    loadSettings();
    loadConfig();
    loadBypassApps();

    subscriptionTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => checkSubscriptionLive(),
    );
  }


  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    autoConnect = prefs.getBool('auto_connect') ?? false;
    backgroundMode = prefs.getBool('background_mode') ?? false;

    if (mounted) setState(() {});

    if (autoConnect) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && !connected) {
          startOrStopVpn();
        }
      });
    }
  }

  Future<void> setAutoConnect(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_connect', value);
    setState(() => autoConnect = value);
  }

  Future<void> setBackgroundMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('background_mode', value);
    setState(() => backgroundMode = value);

    if (value) {
      await _channel.invokeMethod('openBatterySettings');
    }
  }

  
  Future<void> checkSubscriptionLive() async {
    if (!connected) return;

    try {
      final latest = await api.getVpnConfig();

      final latestUpdatedAt =
          latest['configUpdatedAt']?.toString() ?? '';

      final latestConfig =
          latest['vmessUrl'] ?? latest['config'];

      final currentConfig =
          config?['vmessUrl'] ?? config?['config'];

      final changedByTime =
          latestUpdatedAt.isNotEmpty &&
          latestUpdatedAt != configUpdatedAt;

      final changedByConfig =
          latestConfig != null &&
          latestConfig.toString() != currentConfig?.toString();

      if (changedByTime || changedByConfig) {
        await flutterV2ray.stopV2Ray();

        if (!mounted) return;

        setState(() {
          config = latest;
          appName =
              latest['appName']?.toString() ??
              'HAMADA NET vip';

          configUpdatedAt = latestUpdatedAt;

          connected = false;
          vpnState = 'DISCONNECTED';
        });

        await Future.delayed(
          const Duration(seconds: 1),
        );

        await startOrStopVpn();
        return;
      }
    } catch (e) {
      final msg = e.toString();

      if (msg.contains('subscription expired') ||
          msg.contains('403')) {
        await flutterV2ray.stopV2Ray();

        if (!mounted) return;

        setState(() {
          connected = false;
          vpnState = 'DISCONNECTED';
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const SubscriptionScreen(),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    subscriptionTimer?.cancel();
    super.dispose();
  }

  Future<void> loadBypassApps() async {
    final saved = await _channel.invokeListMethod<String>('loadBypassApps') ?? [];
    if (!mounted) return;
    setState(() => bypassApps = saved);
  }

  Future<void> openBypassApps() async {
    final result = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(builder: (_) => const BypassAppsScreen()),
    );

    if (result != null && mounted) {
      setState(() => bypassApps = result);
    }
  }


  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
      backgroundColor: const Color(0xFF080B12),
      appBar: AppBar(
        title: Text(appName),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            Icon(
              connected ? Icons.shield : Icons.shield_outlined,
              size: 110,
              color: connected ? Colors.greenAccent : Colors.white70,
            ),
            const SizedBox(height: 20),
            Text(
              connected ? 'متصل' : 'غير متصل',
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              vpnState,
              style: const TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 20),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: loading ? null : toggleVpn,
                child: Text(connected ? 'قطع الاتصال' : 'اتصال'),
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: autoConnect,
              title: const Text('اتصال تلقائي عند فتح التطبيق'),
              onChanged: setAutoConnect,
            ),
            SwitchListTile(
              value: backgroundMode,
              title: const Text('تشغيل في الخلفية'),
              subtitle: const Text('يفتح إعدادات البطارية للسماح للتطبيق بالعمل بالخلفية'),
              onChanged: setBackgroundMode,
            ),
            TextButton(
              onPressed: openBypassApps,
              child: Text('تطبيقات خارج VPN (${bypassApps.length})'),
            ),
          ],
        ),
      ),
    );
  }
}
