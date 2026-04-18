import 'package:flutter/material.dart';

import '../../data/admin_client_profiles_service.dart';

class AdminClientProfileEditScreen extends StatefulWidget {
  final Map<String, dynamic> item;

  const AdminClientProfileEditScreen({
    super.key,
    required this.item,
  });

  @override
  State<AdminClientProfileEditScreen> createState() =>
      _AdminClientProfileEditScreenState();
}

class _AdminClientProfileEditScreenState
    extends State<AdminClientProfileEditScreen> {
  final _service = AdminClientProfilesService();

  late final TextEditingController _email;
  late final TextEditingController _phone;

  bool _saving = false;
  bool _deleting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController(
      text: (widget.item['email'] ?? '').toString(),
    );
    _phone = TextEditingController(
      text: (widget.item['phone'] ?? '').toString(),
    );
  }

  @override
  void dispose() {
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  String _mapError(String raw) {
    switch (raw) {
      case 'INVALID_CLIENT_ID':
        return 'رقم العميل غير صحيح';
      case 'INVALID_EMAIL':
        return 'البريد الإلكتروني غير صحيح';
      case 'INVALID_PHONE':
        return 'رقم الهاتف غير صحيح';
      case 'EMAIL_ALREADY_USED':
        return 'هذا البريد الإلكتروني مستخدم عند عميل آخر';
      case 'PHONE_ALREADY_USED':
        return 'هذا الرقم مستخدم عند عميل آخر';
      case 'ACCOUNT_NOT_ZERO':
        return 'لا يمكن حذف الحساب إلا إذا كان مصفرًا تمامًا';
      case 'NOT_FOUND':
        return 'العميل غير موجود';
      default:
        return raw.startsWith('خطأ:')
            ? raw
            : 'حدث خطأ أثناء تنفيذ العملية';
    }
  }

  Future<void> _save() async {
    final email = _email.text.trim().toLowerCase();
    final phone = _phone.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'اكتب بريدًا إلكترونيًا صحيحًا');
      return;
    }

    if (phone.length < 6) {
      setState(() => _error = 'اكتب رقم هاتف صحيحًا');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final res = await _service.updateClientProfile(
        clientId: widget.item['id'] as int? ?? 0,
        email: email,
        phone: phone,
      );

      if (!mounted) return;

      setState(() => _saving = false);

      if (res['ok'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ بيانات العميل بنجاح')),
        );
        Navigator.pop(context, true);
      } else {
        setState(() {
          _error = _mapError((res['error'] ?? 'SERVER_ERROR').toString());
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'تعذر تنفيذ العملية، حاول مرة أخرى';
      });
    }
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف الحساب'),
        content: const Text(
          'سيتم حذف الحساب نهائيًا وكل طلباته ومحادثاته. لا يتم الحذف إلا إذا كان الحساب مصفرًا تمامًا. هل أنت متأكد؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف نهائي'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    setState(() {
      _deleting = true;
      _error = null;
    });

    try {
      final res = await _service.deleteClient(
        clientId: widget.item['id'] as int? ?? 0,
      );

      if (!mounted) return;

      setState(() => _deleting = false);

      if (res['ok'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف الحساب بنجاح')),
        );
        Navigator.pop(context, true);
      } else {
        setState(() {
          _error = _mapError((res['error'] ?? 'SERVER_ERROR').toString());
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _deleting = false;
        _error = 'تعذر تنفيذ العملية، حاول مرة أخرى';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientId = widget.item['id'];

    return Scaffold(
      appBar: AppBar(
        title: Text('تعديل بيانات العميل #$clientId'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف',
                  ),
                  onSubmitted: (_) => _saving ? null : _save(),
                ),
                const SizedBox(height: 12),
                if (_error != null)
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: (_saving || _deleting) ? null : _save,
                    child: Text(_saving ? 'جاري الحفظ...' : 'حفظ التعديلات'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: (_saving || _deleting) ? null : _delete,
                    child: Text(_deleting ? 'جاري الحذف...' : 'حذف الحساب'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
