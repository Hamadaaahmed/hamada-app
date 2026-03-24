import 'package:flutter/material.dart';
import '../../../../core/contact_name_text.dart';
import '../../../../app/router.dart';
import '../../data/admin_orders_service.dart';

class AdminCustomerOrdersScreen extends StatefulWidget {
  final int clientId;

  const AdminCustomerOrdersScreen({
    super.key,
    required this.clientId,
  });

  @override
  State<AdminCustomerOrdersScreen> createState() =>
      _AdminCustomerOrdersScreenState();
}

class _AdminCustomerOrdersScreenState extends State<AdminCustomerOrdersScreen> {
  final _service = AdminOrdersService();
  bool _loading = true;
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    try {
      final rows = await _service.listOrders();
      if (!mounted) return;
      final filtered = rows.where((o) {
        final clientId = int.tryParse('${o['client_id']}') ?? 0;
        return clientId == widget.clientId;
      }).toList()
        ..sort((a, b) => (b['id'] as int).compareTo(a['id'] as int));
      setState(() => _orders = filtered);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تحميل الطلبات: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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

  @override
  Widget build(BuildContext context) {
    final phone = _orders.isNotEmpty ? (_orders.first['phone'] ?? '').toString() : '';

    return Scaffold(
      appBar: AppBar(
        title: phone.trim().isNotEmpty
            ? ContactNameText(
                phone: phone,
                fallbackPrefix: null,
              )
            : Text('عميل #${widget.clientId}'),
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
          : _orders.isEmpty
              ? const Center(child: Text('لا توجد طلبات لهذا العميل'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _orders.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final order = _orders[i];
                      return ListTile(
                        title: Text('طلب #${order['id']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if ((order['phone'] ?? '').toString().trim().isNotEmpty)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('الهاتف: '),
                                  Expanded(
                                    child: ContactNameText(
                                      phone: (order['phone'] ?? '').toString(),
                                      fallbackPrefix: null,
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 2),
                            Text(
                              'الحالة: ${_statusText(order['status'].toString())}',
                            ),
                            Text(
                              'الإجمالي: ${_money(order['total_cents'] as int)} جنيه',
                            ),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          await Navigator.pushNamed(
                            context,
                            AppRouter.adminOrderDetails,
                            arguments: order['id'],
                          );
                          _load();
                        },
                      );
                    },
                  ),
                ),
    );
  }
}
