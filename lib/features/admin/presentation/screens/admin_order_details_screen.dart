import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/router.dart';
import '../../../../core/contact_name_text.dart';
import '../../../../core/phone_dialer.dart';
import '../../data/admin_orders_service.dart';

class AdminOrderDetailsScreen extends StatefulWidget {
  final int orderId;

  const AdminOrderDetailsScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<AdminOrderDetailsScreen> createState() =>
      _AdminOrderDetailsScreenState();
}

class _AdminOrderDetailsScreenState extends State<AdminOrderDetailsScreen> {
  final _service = AdminOrdersService();

  bool _loading = true;
  Map<String, dynamic>? _order;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);

    try {
      final data = await _service.getOrder(widget.orderId);
      if (!mounted) return;

      setState(() {
        _order = data['order'] as Map<String, dynamic>?;
        _items = List<Map<String, dynamic>>.from(data['items'] as List);
      });
    } catch (_) {
      if (!mounted) return;
      _snack('تعذر تحميل الطلب، حاول مرة أخرى', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
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

  String _fmtDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
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

  Future<String?> _askText({
    required String title,
    required String label,
    String initial = '',
    bool multiline = false,
  }) async {
    final ctrl = TextEditingController(text: initial);

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: ctrl,
          minLines: multiline ? 3 : 1,
          maxLines: multiline ? 5 : 1,
          decoration: InputDecoration(labelText: label),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    if (ok != true) return null;
    return ctrl.text.trim();
  }

  Future<void> _accept() async {
    try {
      final note = await _askText(
        title: 'قبول الطلب',
        label: 'ملاحظة (اختياري)',
      );

      final data =
          await _service.acceptOrder(widget.orderId, adminNote: note);

      if (data['ok'] == true) {
        _snack('تم قبول الطلب');
        _load();
      } else {
        _snack(
          (data['error'] ?? 'فشل قبول الطلب').toString(),
          error: true,
        );
      }
    } catch (_) {
      _snack('تعذر تنفيذ العملية، حاول مرة أخرى', error: true);
    }
  }

  Future<void> _reject() async {
    final reason = await _askText(
      title: 'رفض الطلب',
      label: 'سبب الرفض',
      multiline: true,
    );
    if (reason == null || reason.isEmpty) return;

    try {
      final data = await _service.rejectOrder(widget.orderId, reason: reason);
      if (data['ok'] == true) {
        _snack('تم رفض الطلب');
        _load();
      } else {
        _snack(
          (data['error'] ?? 'فشل رفض الطلب').toString(),
          error: true,
        );
      }
    } catch (_) {
      _snack('تعذر تنفيذ العملية، حاول مرة أخرى', error: true);
    }
  }

  Future<void> _schedule() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: DateTime.now(),
    );
    if (date == null) return;
    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    final dt = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    try {
      final data = await _service.scheduleOrder(
        widget.orderId,
        scheduledAtIso: dt.toIso8601String(),
      );
      if (!mounted) return;

      if (data['ok'] == true) {
        _snack('تم تحديد موعد الصيانة');
        _load();
      } else {
        _snack(
          (data['error'] ?? 'فشل تحديد الموعد').toString(),
          error: true,
        );
      }
    } catch (_) {
      _snack('تعذر تنفيذ العملية، حاول مرة أخرى', error: true);
    }
  }

  Future<void> _complete() async {
    try {
      final note = await _askText(
        title: 'إنهاء الصيانة',
        label: 'ملاحظة (اختياري)',
      );

      final data =
          await _service.completeOrder(widget.orderId, adminNote: note);

      if (data['ok'] == true) {
        _snack('تم إنهاء الصيانة');
        _load();
      } else {
        _snack(
          (data['error'] ?? 'فشل إنهاء الصيانة').toString(),
          error: true,
        );
      }
    } catch (_) {
      _snack('تعذر تنفيذ العملية، حاول مرة أخرى', error: true);
    }
  }

  Future<void> _openChat() async {
    try {
      final data = await _service.getOrderChat(widget.orderId);
      if (!mounted) return;

      if (data['ok'] == true && data['conversation'] is Map) {
        final conv = Map<String, dynamic>.from(data['conversation'] as Map);
        final conversationId = conv['id'] as int? ?? 0;

        if (conversationId <= 0) {
          _snack('تعذر فتح المحادثة', error: true);
          return;
        }

        await Navigator.pushNamed(
          context,
          AppRouter.adminChatDetails,
          arguments: conversationId,
        );
      } else {
        _snack(
          (data['error'] ?? 'تعذر فتح المحادثة').toString(),
          error: true,
        );
      }
    } catch (_) {
      _snack('تعذر فتح المحادثة، حاول مرة أخرى', error: true);
    }
  }

  Future<void> _openMap() async {
    final order = _order;
    if (order == null) return;

    final lat = order['lat'];
    final lng = order['lng'];
    if (lat == null || lng == null) {
      _snack('لا يوجد موقع محفوظ لهذا العميل', error: true);
      return;
    }

    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _snack('تعذر فتح الخرائط', error: true);
    }
  }

  Widget _infoTile(String label, String value, {Widget? child}) {
    if (value.trim().isEmpty && child == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: child ?? Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;
    final status = order?['status']?.toString() ?? '';

    final canAccept = status == 'pending';
    final canReject = status == 'pending';
    final canSchedule =
        status == 'pending' || status == 'accepted' || status == 'in_progress';
    final canComplete =
        status == 'accepted' || status == 'in_progress' || status == 'scheduled';

    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل الطلب #${widget.orderId}'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : order == null
              ? const Center(child: Text('الطلب غير موجود'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _infoTile(
                      'العميل',
                      order['phone'].toString().trim().isNotEmpty
                          ? order['phone'].toString()
                          : 'عميل #${order['client_id']}',
                      child: order['phone'].toString().trim().isNotEmpty
                          ? InkWell(
                              onTap: () => PhoneDialer.openDialer(
                                order['phone'].toString(),
                              ),
                              child: ContactNameText(
                                phone: order['phone'].toString(),
                                fallbackPrefix: null,
                                style: const TextStyle(
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            )
                          : null,
                    ),
                    _infoTile(
                      'الهاتف',
                      order['phone'].toString(),
                      child: InkWell(
                        onTap: () => PhoneDialer.openDialer(
                          order['phone'].toString(),
                        ),
                        child: ContactNameText(
                          phone: order['phone'].toString(),
                          fallbackPrefix: null,
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    _infoTile('الحالة', _statusText(status)),
                    _infoTile(
                      'الإجمالي',
                      '${_money(order['total_cents'] as int)} جنيه',
                    ),
                    _infoTile(
                      'المدفوع',
                      '${_money(order['paid_cents'] as int)} جنيه',
                    ),
                    _infoTile(
                      'ملاحظات الأدمن',
                      (order['admin_note'] ?? '').toString(),
                    ),
                    _infoTile(
                      'سبب الرفض',
                      (order['reject_reason'] ?? '').toString(),
                    ),
                    _infoTile(
                      'موعد الصيانة',
                      _fmtDate(order['scheduled_at']?.toString()),
                    ),
                    _infoTile(
                      'وقت الإنهاء',
                      _fmtDate(order['completed_at']?.toString()),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'العناصر المطلوبة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (canAccept)
                          ElevatedButton(
                            onPressed: _accept,
                            child: const Text('قبول الطلب'),
                          ),
                        if (canReject)
                          ElevatedButton(
                            onPressed: _reject,
                            child: const Text('رفض الطلب'),
                          ),
                        if (canSchedule)
                          ElevatedButton(
                            onPressed: _schedule,
                            child: const Text('تحديد موعد'),
                          ),
                        if (canComplete)
                          ElevatedButton(
                            onPressed: _complete,
                            child: const Text('إنهاء الصيانة'),
                          ),
                        ElevatedButton(
                          onPressed: _openMap,
                          child: const Text('موقع العميل'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRouter.adminClientAccount,
                              arguments: order['client_id'],
                            );
                          },
                          child: const Text('حساب العميل'),
                        ),
                        ElevatedButton(
                          onPressed: _openChat,
                          child: const Text('محادثة العميل'),
                        ),
                      ],
                    ),
                  ],
                ),
    );
  }
}
