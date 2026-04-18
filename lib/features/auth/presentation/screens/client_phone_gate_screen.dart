import 'package:flutter/material.dart';

import '../../../../app/router.dart';
import '../../../client/data/client_account_service.dart';
import '../../data/auth_service.dart';
import '../../../../core/secure_storage.dart';

class ClientPhoneGateScreen extends StatefulWidget {
  final String email;

  const ClientPhoneGateScreen({super.key, required this.email});

  @override
  State<ClientPhoneGateScreen> createState() => _ClientPhoneGateScreenState();
}

class _ClientPhoneGateScreenState extends State<ClientPhoneGateScreen> {
  final _phone = TextEditingController();
  final _auth = AuthService();
  final _account = ClientAccountService();

  bool _loading = true;
  bool _saving = false;
  bool _hasPhone = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _boot() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final res = await _auth.getPhoneStatus(widget.email);

    if (!mounted) return;

    if (!res.ok) {
      setState(() {
        _loading = false;
        _error = _mapError(res.message ?? 'SERVER_ERROR');
      });
      return;
    }

    setState(() {
      _hasPhone = res.hasPhone;
      _loading = false;
    });
  }

  String _mapError(String raw) {
    switch (raw) {
      case 'INVALID_EMAIL':
      case 'البريد الإلكتروني غير صحيح':
        return 'البريد الإلكتروني غير صحيح';
      case 'BLOCKED':
      case 'تم إيقاف هذا الحساب مؤقتًا. تواصل مع الإدارة.':
        return 'تم إيقاف هذا الحساب مؤقتًا. تواصل مع الإدارة.';
      case 'NOT_FOUND':
      case 'الحساب غير موجود':
        return 'الحساب غير موجود';
      case 'PHONE_NOT_SET':
      case 'لا يوجد رقم هاتف محفوظ لهذا الحساب':
        return 'لا يوجد رقم هاتف محفوظ لهذا الحساب';
      case 'PHONE_MISMATCH':
      case 'رقم الهاتف غير مطابق للحساب':
        return 'رقم الهاتف غير مطابق للحساب. إذا فقدت الرقم تواصل مع الإدارة.';
      case 'PHONE_ALREADY_USED':
      case 'رقم الهاتف مستخدم بحساب آخر':
        return 'رقم الهاتف مستخدم بحساب آخر';
      case 'INVALID_PHONE':
      case 'رقم الهاتف غير صحيح':
        return 'رقم الهاتف غير صحيح';
      case 'SERVER_ERROR':
      case 'حدث خطأ في السيرفر، حاول مرة أخرى':
        return 'حدث خطأ في السيرفر، حاول مرة أخرى';
      case 'تعذر الاتصال بالسيرفر، حاول مرة أخرى':
        return 'تعذر الاتصال بالسيرفر، حاول مرة أخرى';
      default:
        return 'حدث خطأ، حاول مرة أخرى';
    }
  }

  Future<void> _submit() async {
    final phone = _phone.text.trim();
    if (phone.length < 6) {
      setState(() => _error = 'اكتب رقم موبايل صحيح');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    if (_hasPhone) {
      final res = await _auth.verifyLinkedPhone(
        email: widget.email,
        phone: phone,
      );

      if (!mounted) return;

      setState(() => _saving = false);

      if (res.ok) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRouter.clientHome,
          (route) => false,
        );
      } else {
        setState(() => _error = _mapError(res.message ?? 'PHONE_MISMATCH'));
      }
      return;
    }

    final saveRes = await _account.savePhone(phone);

    if (!mounted) return;

    setState(() => _saving = false);

    if (saveRes['ok'] == true) {
      await AppStorage.I.clearClientPhoneGatePending();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.clientHome,
        (route) => false,
      );
    } else {
      setState(() {
        _error = _mapError((saveRes['error'] ?? 'SERVER_ERROR').toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _hasPhone ? 'تأكيد رقم الهاتف' : 'حفظ رقم الهاتف';
    final description = _hasPhone
        ? 'هذا الحساب مرتبط برقم موبايل. أدخل الرقم المرتبط بالحساب للمتابعة.'
        : 'هذه أول مرة تسجل فيها. أدخل رقم الموبايل لحفظه وربطه بحسابك.';
    final buttonText = _hasPhone ? 'تأكيد الرقم' : 'حفظ الرقم والمتابعة';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          labelText: 'رقم الموبايل',
                          hintText: 'مثال: 01113531330',
                        ),
                        onSubmitted: (_) => _saving ? null : _submit(),
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
                          onPressed: _saving ? null : _submit,
                          child: Text(
                            _saving ? 'جاري المتابعة...' : buttonText,
                          ),
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
