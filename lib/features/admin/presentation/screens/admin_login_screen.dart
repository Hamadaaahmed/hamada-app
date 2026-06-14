import 'package:flutter/material.dart';

import '../../../../app/router.dart';
import '../../data/admin_machines_service.dart';

class AdminLoginScreen extends StatefulWidget {
  final String? initialEmail;

  const AdminLoginScreen({super.key, this.initialEmail});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialEmail?.trim();
    if (initial != null && initial.isNotEmpty) {
      _email.text = initial;
    }
  }

  String _mapError(String raw) {
    switch (raw) {
      case 'INVALID_CREDENTIALS':
        return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      case 'INVALID_EMAIL':
        return 'البريد الإلكتروني غير صحيح';
      case 'BLOCKED':
        return 'هذا الحساب موقوف';
      case 'SERVER_ERROR':
        return 'حدث خطأ في السيرفر، حاول مرة أخرى';
      default:
        if (raw.contains('401')) {
          return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
        }
        if (raw.contains('DioException')) {
          return 'تعذر الاتصال بالسيرفر، حاول مرة أخرى';
        }
        return 'فشل تسجيل دخول الأدمن';
    }
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _password.text.trim();

    if (email.isEmpty || !email.contains('@') || password.length < 6) {
      setState(() => _error = 'اكتب البريد وكلمة المرور بشكل صحيح');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await AdminMachinesService().login(
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (data['ok'] == true) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRouter.adminHome,
          (route) => false,
        );
      } else {
        setState(() {
          _error = _mapError(
            (data['error'] ?? 'فشل تسجيل دخول الأدمن').toString(),
          );
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = _mapError(e.toString()));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('دخول الأدمن')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'أدخل كلمة مرور الأدمن للمتابعة',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'كلمة المرور',
                  ),
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
                    onPressed: _loading ? null : _submit,
                    child: Text(_loading ? 'جاري الدخول...' : 'دخول'),
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
