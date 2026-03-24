import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../app/router.dart';
import '../../../../core/order_socket_service.dart';
import '../../../../core/secure_storage.dart';
import '../../data/client_orders_service.dart';

class ClientOrdersScreen extends StatefulWidget {
  const ClientOrdersScreen({super.key});

  @override
  State<ClientOrdersScreen> createState() => _ClientOrdersScreenState();
}

class _ClientOrdersScreenState extends State<ClientOrdersScreen> {
  final _service = ClientOrdersService();
  bool _loading = true;
  List<Map<String, dynamic>> _orders = [];
  Timer? _timer;
  StreamSubscription<Map<String, dynamic>>? _socketSub;
  int _clientId = 0;
  bool _socketConnected = false;
  bool _isLoadingNow = false;

  @override
  void initState() {
    super.initState();
    _boot();
    _timer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (_socketConnected || _isLoadingNow) return;
      _load(silent: true);
    });
  }

  @override
  void dispose() {
    _socketSub?.cancel();
    OrderSocketService.I.disconnect();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _boot() async {
    await _resolveClientId();
    await _load();
    await _ensureSocketConnected();
  }

  Future<void> _resolveClientId() async {
    _clientId = await AppStorage.I.getClientIdFromToken();
  }

  Future<void> _ensureSocketConnected() async {
    final token = await AppStorage.I.getClientToken();
    if (token == null || token.isEmpty || _clientId <= 0) return;

    if (_socketConnected) return;

    await _socketSub?.cancel();
    _socketSub = OrderSocketService.I
        .connect(
      token: token,
      role: 'client',
      clientId: _clientId,
    )
        .listen((event) {
      if (!mounted) return;
      _load(silent: true);
    });

    _socketConnected = true;
  }

  Future<void> _load({bool silent = false}) async {
    if (_isLoadingNow) return;
    _isLoadingNow = true;
    if (!silent && mounted) setState(() => _loading = true);
    try {
      final rows = await _service.listMyOrders();
      if (!mounted) return;

      if (_clientId <= 0 && rows.isNotEmpty) {
        _clientId = int.tryParse('${rows.first['client_id']}') ?? 0;
      }

      setState(() => _orders = rows);

      if (_clientId > 0 && !_socketConnected) {
        await _ensureSocketConnected();
      }
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
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red : null,
      ),
    );
  }

  String _statusText(String status) {
    switch (status) {
      case 'pending':
        return 'معلق';
      case 'accepted':
        return 'مقبول';
      case 'in_progress':
        return 'جاري التنفيذ';
      case 'completed':
        return 'مكتمل';
      case 'rejected':
        return 'مرفوض';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.amber;
      case 'accepted':
        return Colors.blue;
      case 'in_progress':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  String _money(int cents) {
    final v = cents / 100.0;
    return v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
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

  Widget _statusBadge(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(40),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha(140)),
      ),
      child: Text(
        _statusText(status),
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلباتي'),
        actions: [
          IconButton(
            onPressed: () => _load(),
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text('لا توجد طلبات بعد'))
              : RefreshIndicator(
                  onRefresh: () => _load(),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    padding: const EdgeInsets.all(12),
                    itemBuilder: (_, i) {
                      final item = _orders[i];
                      final status = item['status'].toString();
                      final scheduled = item['scheduled_at'].toString();
                      final rejectReason = item['reject_reason'].toString();

                      return Card(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRouter.clientOrderDetails,
                            arguments: item['id'] as int,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'طلب رقم #${item['id']}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    _statusBadge(status),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'الإجمالي: ${_money(item['total_cents'] as int)} جنيه',
                                ),
                                Text(
                                  'المدفوع: ${_money(item['paid_cents'] as int)} جنيه',
                                ),
                                Text(
                                  'تاريخ الإنشاء: ${_fmtDate(item['created_at'].toString())}',
                                ),
                                if (scheduled.trim().isNotEmpty)
                                  Text('موعد الصيانة: ${_fmtDate(scheduled)}'),
                                if (status == 'rejected' &&
                                    rejectReason.trim().isNotEmpty)
                                  Text(
                                    'سبب الرفض: $rejectReason',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
