import '../../../../core/contact_name_text.dart';
import '../../../../core/phone_dialer.dart';
import 'package:flutter/material.dart';
import '../../data/admin_client_account_service.dart';

class AdminClientAccountScreen extends StatefulWidget {
  final int clientId;
  const AdminClientAccountScreen({super.key, required this.clientId});

  @override
  State<AdminClientAccountScreen> createState() =>
      _AdminClientAccountScreenState();
}

class _AdminClientAccountScreenState extends State<AdminClientAccountScreen> {
  final _service = AdminClientAccountService();
  bool _loading = true;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    try {
      final data = await _service.getAccount(widget.clientId);
      if (!mounted) return;
      setState(() => _data = data);
    } catch (e) {
      if (!mounted) return;
      _snack('خطأ في تحميل الحساب: $e', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: error ? Colors.red : null),
    );
  }

  String _money(int cents) {
    final v = cents / 100.0;
    return v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
  }

  String _kindText(String kind) {
    switch (kind) {
      case 'credit':
        return 'إضافة رصيد';
      case 'debt':
        return 'إضافة مستحق';
      case 'note':
        return 'ملاحظة';
      default:
        return kind;
    }
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

  int _toCents(String input) {
    final value = double.tryParse(input.trim().replaceAll(',', '.')) ?? 0;
    return (value * 100).round();
  }

  Future<void> _toggleBlock(bool blocked) async {
    try {
      final res = blocked
          ? await _service.unblockClient(widget.clientId)
          : await _service.blockClient(widget.clientId);

      if (res['ok'] == true) {
        if (mounted) {
          setState(() {
            final current = _data?['client'];
            if (current is Map<String, dynamic>) {
              _data = {
                ...?_data,
                'client': {
                  ...current,
                  'blocked': !blocked,
                },
              };
            }
          });
        }
        _snack(blocked ? 'تم فك حظر العميل' : 'تم حظر العميل');
        _load();
      } else {
        _snack((res['error'] ?? 'فشل العملية').toString(), error: true);
      }
    } catch (e) {
      _snack('تعذر تنفيذ العملية، حاول مرة أخرى', error: true);
    }
  }

  Future<void> _askMoneyAction({
    required String title,
    required Future<Map<String, dynamic>> Function(int amountCents, String note)
        action,
  }) async {
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'المبلغ بالجنيه'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: noteCtrl,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'ملاحظة'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('حفظ')),
        ],
      ),
    );

    if (ok != true) return;

    final amount = _toCents(amountCtrl.text);
    final note = noteCtrl.text.trim();

    if (amount <= 0 || note.isEmpty) {
      _snack('اكتب مبلغ صحيح وملاحظة', error: true);
      return;
    }

    try {
      final res = await action(amount, note);
      if (res['ok'] == true) {
        _snack('تم الحفظ بنجاح');
        _load();
      } else {
        _snack((res['error'] ?? 'فشل العملية').toString(), error: true);
      }
    } catch (e) {
      _snack('تعذر تنفيذ العملية، حاول مرة أخرى', error: true);
    }
  }

  Future<void> _addNote() async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('إضافة ملاحظة'),
        content: TextField(
          controller: ctrl,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(labelText: 'الملاحظة'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('حفظ')),
        ],
      ),
    );

    if (ok != true) return;
    final note = ctrl.text.trim();
    if (note.isEmpty) {
      _snack('اكتب الملاحظة', error: true);
      return;
    }

    try {
      final res = await _service.addNote(clientId: widget.clientId, note: note);
      if (res['ok'] == true) {
        _snack('تمت إضافة الملاحظة');
        _load();
      } else {
        _snack((res['error'] ?? 'فشل العملية').toString(), error: true);
      }
    } catch (e) {
      _snack('تعذر تنفيذ العملية، حاول مرة أخرى', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    final client = data?['client'] as Map<String, dynamic>?;
    final blocked = client?['blocked'] == true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('حساب العميل'),
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
          : data == null || data['ok'] != true
              ? const Center(child: Text('تعذر تحميل الحساب'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ((client?['phone'] ?? '').toString().trim().isNotEmpty)
                        ? ContactNameText(
                            phone: (client?['phone'] ?? '').toString(),
                            fallbackPrefix: null,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Text(
                            'عميل #${client?['id'] ?? widget.clientId}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    const SizedBox(height: 8),
                    if (((client?['phone'] ?? '').toString().trim().isNotEmpty))
                      InkWell(
                        onTap: () => PhoneDialer.openDialer(
                            (client?['phone'] ?? '').toString()),
                        child: ContactNameText(
                          phone: (client?['phone'] ?? '').toString(),
                          fallbackPrefix: null,
                          style: const TextStyle(
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    if (((client?['phone'] ?? '').toString().trim().isNotEmpty))
                      const SizedBox(height: 8),
                    Text(
                      blocked ? 'حالة العميل: محظور' : 'حالة العميل: نشط',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: blocked ? Colors.red : Colors.green,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _row('رصيد العميل',
                                '${_money(data['wallet_cents'] as int)} جنيه'),
                            const SizedBox(height: 8),
                            _row('المبلغ المستحق',
                                '${_money(data['debt_cents'] as int)} جنيه'),
                            const SizedBox(height: 8),
                            _row('الصافي',
                                '${_money(data['net_cents'] as int)} جنيه'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed: () => _askMoneyAction(
                            title: 'إضافة رصيد',
                            action: (amount, note) => _service.addCredit(
                              clientId: widget.clientId,
                              amountCents: amount,
                              note: note,
                            ),
                          ),
                          child: const Text('إضافة رصيد'),
                        ),
                        ElevatedButton(
                          onPressed: () => _askMoneyAction(
                            title: 'إضافة مستحق',
                            action: (amount, note) => _service.addDebt(
                              clientId: widget.clientId,
                              amountCents: amount,
                              note: note,
                            ),
                          ),
                          child: const Text('إضافة مستحق'),
                        ),
                        ElevatedButton(
                          onPressed: _addNote,
                          child: const Text('إضافة ملاحظة'),
                        ),
                        ElevatedButton(
                          onPressed: () => _toggleBlock(blocked),
                          child: Text(blocked ? 'فك حظر العميل' : 'حظر العميل'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'سجل الحساب',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...List<Map<String, dynamic>>.from(data['entries'] as List)
                        .map(
                      (entry) => Card(
                        child: ListTile(
                          title: Text(_kindText(entry['kind'].toString())),
                          subtitle: Text(
                              '${entry['note']}\n${_fmtDate(entry['created_at'].toString())}'),
                          isThreeLine: true,
                          trailing: Text(
                            entry['amount_cents'] == 0
                                ? '-'
                                : '${_money(entry['amount_cents'] as int)} ج',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      children: [
        Expanded(
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.bold))),
        Text(value),
      ],
    );
  }
}
