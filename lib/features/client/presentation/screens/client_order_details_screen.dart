import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/order_socket_service.dart';
import '../../../../core/secure_storage.dart';
import '../../data/client_orders_service.dart';

class ClientOrderDetailsScreen extends StatefulWidget {
  final int orderId;
  const ClientOrderDetailsScreen({super.key, required this.orderId});

  @override
  State<ClientOrderDetailsScreen> createState() =>
      _ClientOrderDetailsScreenState();
}

class _ClientOrderDetailsScreenState extends State<ClientOrderDetailsScreen> {
  final _service = ClientOrdersService();
  bool _loading = true;
  Map<String, dynamic>? _order;
  List<Map<String, dynamic>> _items = [];
  StreamSubscription<Map<String, dynamic>>? _socketSub;
  int _clientId = 0;
  bool _socketConnected = false;
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
      final eventName = (event['_event'] ?? '').toString();
      final eventOrderId = int.tryParse(
              '${event['id'] ?? event['order_id'] ?? event['orderId']}') ??
          0;

      if (!mounted) return;

      if (eventName == 'orders_changed' && eventOrderId == widget.orderId) {
        _load(silent: true);
        return;
      }

      if ((eventName == 'order_updated' || eventName == 'order_created') &&
          eventOrderId == widget.orderId) {
        _load(silent: true);
      }
    });

    _socketConnected = true;
  }

  Future<void> _load({bool silent = false}) async {
    if (_isLoadingNow) return;
    _isLoadingNow = true;
    if (!silent && mounted) setState(() => _loading = true);
    try {
      final data = await _service.getMyOrder(widget.orderId);
      if (!mounted) return;

      final order = data['order'] as Map<String, dynamic>?;
      final items =
          List<Map<String, dynamic>>.from(data['items'] as List? ?? const []);

      if (_clientId <= 0 && order != null) {
        _clientId = int.tryParse('${order['client_id']}') ?? 0;
      }

      setState(() {
        _order = order;
        _items = items;
      });

      if (_clientId > 0 && !_socketConnected) {
        await _ensureSocketConnected();
      }
    } catch (e) {
      if (!mounted) return;
      _snack('خطأ في تحميل تفاصيل الطلب: $e', error: true);
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

  String _statusText(String status) {
    switch (status) {
      case 'pending':
        return 'معلق';
      case 'accepted':
        return 'مقبول';
      case 'in_progress':
        return 'جاري التنفيذ';
      case 'scheduled':
        return 'تم تحديد موعد';
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

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;

    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل الطلب #${widget.orderId}'),
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
          : order == null
              ? const Center(child: Text('الطلب غير موجود'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _row('الحالة', _statusText(order['status'].toString())),
                    _row('الهاتف', order['phone'].toString()),
                    _row(
                      'الإجمالي',
                      '${_money(order['total_cents'] as int)} جنيه',
                    ),
                    _row(
                      'المدفوع',
                      '${_money(order['paid_cents'] as int)} جنيه',
                    ),
                    _row(
                      'ملاحظات الإدارة',
                      (order['admin_note'] ?? '').toString(),
                    ),
                    _row(
                      'سبب الرفض',
                      (order['reject_reason'] ?? '').toString(),
                    ),
                    _row(
                      'موعد الصيانة',
                      _fmtDate((order['scheduled_at'] ?? '').toString()),
                    ),
                    _row(
                      'وقت الإنهاء',
                      _fmtDate((order['completed_at'] ?? '').toString()),
                    ),
                    _row(
                      'تاريخ الإنشاء',
                      _fmtDate((order['created_at'] ?? '').toString()),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'الخدمات المطلوبة',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ..._items.map(
                      (item) => Card(
                        child: ListTile(
                          leading: Text(
                            item['icon'].toString(),
                            style: const TextStyle(fontSize: 22),
                          ),
                          title: Text(item['machine_name'].toString()),
                          subtitle: Text(
                            'الكمية: ${item['qty']} • السعر: ${_money(item['unit_price_cents'] as int)} جنيه',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
