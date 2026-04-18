import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/router.dart';
import '../../../../app/ui.dart';
import '../../../../core/app_states.dart';
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
    _socketSub = OrderSocketService.I.connect(
      token: token,
      role: 'admin',
    ).listen((event) {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تحميل الطلبات: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      _isLoadingNow = false;
      if (!silent && mounted) setState(() => _loading = false);
    }
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

  Future<void> _openCustomerOrders(int clientId) async {
    await Navigator.pushNamed(
      context,
      AppRouter.adminCustomerOrders,
      arguments: {
        'client_id': clientId,
      },
    );
    await _load(silent: true);
  }

  Future<void> _openLatestOrder(int orderId) async {
    if (orderId <= 0) return;
    await Navigator.pushNamed(
      context,
      AppRouter.adminOrderDetails,
      arguments: orderId,
    );
    await _load(silent: true);
  }

  @override
  Widget build(BuildContext context) {
    final customers = _groupedCustomers();
    final totalOpenOrders = customers.fold<int>(
      0,
      (sum, item) => sum + (item['open_count'] as int? ?? 0),
    );

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
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'تحديث',
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: _loading
            ? const AppLoadingView(message: 'جاري تحميل طلبات الصيانة')
            : customers.isEmpty
                ? const AppEmptyState(
                    title: 'لا توجد طلبات صيانة بعد',
                    subtitle: 'عند وصول أول طلب سيظهر هنا مع آخر طلب لكل عميل.',
                    icon: Icons.handyman_outlined,
                  )
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      children: [
                        AppHeroHeader(
                          title: 'طلبات الصيانة مرتبة حسب العميل',
                          subtitle:
                              'يمكنك فتح آخر طلب مباشرة أو مشاهدة كل طلبات العميل بدون تغيير في الربط أو البيانات.',
                          icon: Icons.handyman_outlined,
                        ),
                        const SizedBox(height: 14),
                        AppSurfaceCard(
                          child: Row(
                            children: [
                              Expanded(
                                child: _SummaryMetric(
                                  label: 'العملاء',
                                  value: '${customers.length}',
                                  icon: Icons.people_alt_outlined,
                                  color: AppUiColors.info,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _SummaryMetric(
                                  label: 'المفتوح',
                                  value: '$totalOpenOrders',
                                  icon: Icons.hourglass_top_rounded,
                                  color: AppUiColors.warning,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        ...customers.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _CustomerOrderCard(
                              phone: item['phone'].toString(),
                              clientId: item['client_id'] as int? ?? 0,
                              ordersCount: item['orders_count'] as int? ?? 0,
                              openCount: item['open_count'] as int? ?? 0,
                              latestOrderId: item['latest_order_id'] as int? ?? 0,
                              latestCreatedAt:
                                  _fmtDate(item['latest_created_at'].toString()),
                              onOpenLatest: () => _openLatestOrder(
                                item['latest_order_id'] as int? ?? 0,
                              ),
                              onOpenAll: () => _openCustomerOrders(
                                item['client_id'] as int? ?? 0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha(14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppUiColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerOrderCard extends StatelessWidget {
  const _CustomerOrderCard({
    required this.phone,
    required this.clientId,
    required this.ordersCount,
    required this.openCount,
    required this.latestOrderId,
    required this.latestCreatedAt,
    required this.onOpenLatest,
    required this.onOpenAll,
  });

  final String phone;
  final int clientId;
  final int ordersCount;
  final int openCount;
  final int latestOrderId;
  final String latestCreatedAt;
  final VoidCallback onOpenLatest;
  final VoidCallback onOpenAll;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppUiColors.info.withAlpha(18),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.person_outline_rounded, color: AppUiColors.info),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    phone.trim().isNotEmpty
                        ? ContactNameText(
                            phone: phone,
                            fallbackPrefix: null,
                          )
                        : Text(
                            'عميل #$clientId',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                    const SizedBox(height: 6),
                    Text(
                      'آخر طلب #$latestOrderId • $latestCreatedAt',
                      style: const TextStyle(
                        color: AppUiColors.muted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (openCount > 0)
                AppCountBadge(
                  count: openCount,
                  color: AppUiColors.warning,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppTag(
                icon: Icons.receipt_long_outlined,
                label: 'إجمالي الطلبات: $ordersCount',
                color: AppUiColors.info,
              ),
              AppTag(
                icon: Icons.timelapse_rounded,
                label: 'غير مكتمل: $openCount',
                color: AppUiColors.warning,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onOpenLatest,
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('فتح آخر طلب'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onOpenAll,
                  icon: const Icon(Icons.format_list_bulleted_rounded),
                  label: const Text('كل الطلبات'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
