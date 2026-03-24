import 'package:flutter/material.dart';
import '../../data/client_account_service.dart';

class ClientAccountScreen extends StatefulWidget {
  const ClientAccountScreen({super.key});

  @override
  State<ClientAccountScreen> createState() => _ClientAccountScreenState();
}

class _ClientAccountScreenState extends State<ClientAccountScreen> {
  final _service = ClientAccountService();
  final _phone = TextEditingController();

  bool _loading = true;
  bool _savingPhone = false;
  int _walletCents = 0;
  int _debtCents = 0;
  int _netCents = 0;
  String? _error;
  List<Map<String, dynamic>> _entries = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final data = await _service.getAccountSummary();

      if (!mounted) return;

      if (data['ok'] == true) {
        setState(() {
          _phone.text = (data['phone'] ?? '').toString();
          _walletCents = data['wallet_cents'] as int;
          _debtCents = data['debt_cents'] as int;
          _netCents = data['net_cents'] as int;
          _entries = List<Map<String, dynamic>>.from(
            data['entries'] as List? ?? const [],
          );
        });
      } else {
        setState(() {
          _error = (data['error'] ?? 'فشل تحميل الحساب').toString();
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'خطأ في تحميل الحساب: $e';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _savePhone() async {
    final phone = _phone.text.trim();

    if (phone.length < 6) {
      _snack('اكتب رقم هاتف صحيح', error: true);
      return;
    }

    if (mounted) setState(() => _savingPhone = true);

    try {
      final res = await _service.savePhone(phone);

      if (!mounted) return;

      if (res['ok'] == true) {
        _snack('تم حفظ رقم الهاتف');
        await _load();
      } else {
        final error = (res['error'] ?? 'فشل حفظ رقم الهاتف').toString();
        _snack(
          error == 'INVALID_PHONE' ? 'رقم الهاتف غير صحيح' : error,
          error: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      _snack('خطأ في حفظ رقم الهاتف: $e', error: true);
    } finally {
      if (mounted) setState(() => _savingPhone = false);
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

  String _money(int cents) {
    final v = cents / 100.0;
    final text =
        v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
    return '$text جنيه';
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

  Color _netColor(BuildContext context) {
    if (_netCents > 0) return Colors.green;
    if (_netCents < 0) return Colors.red;
    return Theme.of(context).colorScheme.onSurface;
  }

  Widget _summaryCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    Color? accent,
    String? subtitle,
  }) {
    final color = accent ?? Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.surface,
        boxShadow: const [
          BoxShadow(blurRadius: 10, color: Colors.black12),
        ],
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withAlpha(30),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if ((subtitle ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final netColor = _netColor(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('حسابي'),
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
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                        ),
                        boxShadow: const [
                          BoxShadow(blurRadius: 12, color: Colors.black12),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ملخص الحساب',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _netCents < 0
                                ? 'لديك رصيد مستحق يحتاج متابعة'
                                : _netCents > 0
                                    ? 'رصيدك جيد ويمكنك المتابعة'
                                    : 'حسابك متوازن حاليًا',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'رقم الهاتف',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _phone,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: 'رقم الهاتف',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 46,
                              child: ElevatedButton(
                                onPressed: _savingPhone ? null : _savePhone,
                                child: Text(
                                  _savingPhone
                                      ? 'جاري الحفظ...'
                                      : 'حفظ رقم الهاتف',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _summaryCard(
                      context: context,
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'الرصيد',
                      value: _money(_walletCents),
                      accent: Colors.green,
                      subtitle: 'الرصيد المتاح في حسابك',
                    ),
                    const SizedBox(height: 12),
                    _summaryCard(
                      context: context,
                      icon: Icons.warning_amber_rounded,
                      title: 'المستحق',
                      value: _money(_debtCents),
                      accent: Colors.orange,
                      subtitle: 'المبالغ المستحقة على طلبات الصيانة',
                    ),
                    const SizedBox(height: 12),
                    _summaryCard(
                      context: context,
                      icon: Icons.calculate_outlined,
                      title: 'الصافي',
                      value: _money(_netCents),
                      accent: netColor,
                      subtitle: _netCents < 0
                          ? 'الصافي بالسالب'
                          : _netCents > 0
                              ? 'الصافي بالموجب'
                              : 'لا يوجد فرق بين الرصيد والمستحق',
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'سجل المعاملات',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_entries.isEmpty)
                      const Card(
                        child: ListTile(
                          title: Text('لا توجد معاملات بعد'),
                        ),
                      )
                    else
                      ..._entries.map(
                        (entry) => Card(
                          child: ListTile(
                            title: Text(_kindText(entry['kind'].toString())),
                            subtitle: Text(
                              '${entry['note']}\n${_fmtDate(entry['created_at'].toString())}',
                            ),
                            isThreeLine: true,
                            trailing: Text(
                              entry['amount_cents'] == 0
                                  ? '-'
                                  : _money(entry['amount_cents'] as int),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }
}
