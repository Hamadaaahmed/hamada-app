import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../app/router.dart';
import '../../../../core/contact_name_text.dart';
import '../../../../core/order_socket_service.dart';
import '../../../../core/secure_storage.dart';
import '../../data/admin_orders_service.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final _service = AdminOrdersService();
  bool _loading = true;
  List<Map<String, dynamic>> _orders = [];
  StreamSubscription<Map<String, dynamic>>? _socketSub;
  bool _isLoadingNow = false;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  @override
  void dispose() {
    _socketSub?.cancel();
    OrderSocketService.I.disconnect();
    super.dispose();
  }

  Future<void> _boot() async {
    await _connectOrdersSocket();
    await _load();
  }

  Future<void> _connectOrdersSocket() async {
    final token = await AppStorage.I.getAdminToken();
    if (token == null || token.isEmpty) return;

    await _socketSub?.cancel();
    _socketSub = OrderSocketService.I
        .connect(
      token: token,
      role: 'admin',
    )
        .listen((event) {
      if (!mounted) return;
      final eventName = (event['_event'] ?? '').toString();
      if (eventName == 'order_created' ||
          eventName == 'order_updated' ||
          eventName == 'orders_changed') {
        _load(silent: true);
      }
    });
  }

  Future<void> _load({bool silent = false}) async {
    if (_isLoadingNow) return;
    _isLoadingNow = true;
    if (!silent && mounted) setState(() => _loading = true);
    try {
      final rows = await _service.listOrders();
      if (!mounted) return;
      setState(() => _orders = rows);
    } catch (e) {
      if (!mounted) return;
      _snack('خطأ في تحميل الطلبات: $e', error: true);
    } finally {
      _isLoadingNow = false;
      if (!silent && mounted) setState(() => _loading = false);
    }
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: error ? Colors.red : null),
    );
  }

  bool _isOpenStatus(String status) {
    return status != 'completed' &&
        status != 'rejected' &&
        status != 'cancelled';
  }

  DateTime? _tryParseDate(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  String _fmtDate(String raw) {
    if (raw.trim().isEmpty) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      final h24 = dt.hour;
      final h12 = h24 == 0 ? 12 : (h24 > 12 ? h24 - 12 : h24);
      final period = h24 >= 12 ? 'م' : 'ص';
      final mm = dt.minute.toString().padLeft(2, '0');
      final dd = dt.day.toString().padLeft(2, '0');
      final mo = dt.month.toString().padLeft(2, '0');
      return '$dd-$mo-${dt.year} | $h12:$mm $period';
    } catch (_) {
      return raw;
    }
  }

  List<Map<String, dynamic>> _groupedCustomers() {
    final buckets = <String, List<Map<String, dynamic>>>{};

    for (final order in _orders) {
      final email = (order['email'] ?? '').toString().trim();
      final key = email.isEmpty ? 'بدون بريد' : email;
      buckets.putIfAbsent(key, () => <Map<String, dynamic>>[]).add(order);
    }

    final groups = buckets.entries.map((entry) {
      final orders = [...entry.value];
      orders.sort((a, b) => (b['id'] as int).compareTo(a['id'] as int));
      final latest = orders.first;

      final openCount = orders
          .where((o) => _isOpenStatus((o['status'] ?? '').toString()))
          .length;

      return <String, dynamic>{
        'phone': (latest['phone'] ?? '').toString(),
        'client_id': latest['client_id'] as int? ?? 0,
        'orders_count': orders.length,
        'open_count': openCount,
        'latest_created_at': (latest['created_at'] ?? '').toString(),
        'latest_order_id': latest['id'] as int? ?? 0,
      };
    }).toList();

    groups.sort((a, b) {
      final aDate = _tryParseDate((a['latest_created_at'] ?? '').toString());
      final bDate = _tryParseDate((b['latest_created_at'] ?? '').toString());

      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });

    return groups;
  }

  Widget _countCircle(int count) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Colors.green,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customers = _groupedCustomers();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || !mounted) return;
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
          return;
        }
        Navigator.pushReplacementNamed(context, AppRouter.adminHome);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('طلبات الصيانة'),
          actions: [
            IconButton(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              tooltip: 'تحديث',
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : customers.isEmpty
                ? const Center(child: Text('لا توجد طلبات صيانة بعد'))
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: customers.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final item = customers[i];
                        final phone = item['phone'].toString();
                        final clientId = item['client_id'] as int? ?? 0;
                        final ordersCount = item['orders_count'] as int? ?? 0;
                        final openCount = item['open_count'] as int? ?? 0;
                        final latestCreatedAt =
                            item['latest_created_at'].toString();
                        final latestOrderId =
                            item['latest_order_id'] as int? ?? 0;

                        return ListTile(
                          title: phone.trim().isNotEmpty
                              ? ContactNameText(
                                  phone: phone,
                                  fallbackPrefix: null,
                                )
                              : Text('عميل #$clientId'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'آخر طلب #$latestOrderId   •   ${_fmtDate(latestCreatedAt)}',
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'عدد الطلبات: $ordersCount   •   غير مكتمل: $openCount',
                              ),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.chevron_right),
                              const SizedBox(height: 6),
                              if (openCount > 0) _countCircle(openCount),
                            ],
                          ),
                          onTap: () async {
                            await Navigator.pushNamed(
                              context,
                              AppRouter.adminCustomerOrders,
                              arguments: {
                                'client_id': clientId,
                              },
                            );
                            _load(silent: true);
                          },
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
