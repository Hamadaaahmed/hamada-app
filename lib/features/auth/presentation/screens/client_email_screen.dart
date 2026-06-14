import 'package:flutter/material.dart';
import '../../../../app/router.dart';
import '../../data/auth_service.dart';

class ClientEmailScreen extends StatefulWidget {
  const ClientEmailScreen({super.key});

  @override
  State<ClientEmailScreen> createState() => _ClientEmailScreenState();
}

class _ClientEmailScreenState extends State<ClientEmailScreen> {
  static const _adminEmail = 'h2siana@gmail.com';
  final _email = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    final email = _email.text.trim().toLowerCase();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'اكتب بريد إلكتروني صحيح');
      return;
    }

    if (email == _adminEmail) {
      Navigator.pushNamed(context, AppRouter.adminLogin, arguments: email);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final res = await AuthService().requestOtp(email);

    if (!mounted) return;

    setState(() => _loading = false);

    if (res.ok) {
      Navigator.pushNamed(context, AppRouter.clientOtp, arguments: email);
    } else {
      setState(() => _error = res.message);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل العميل')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'ادخل بريدك الإلكتروني عشان نبعتلك كود التحقق',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    hintText: 'example@email.com',
                  ),
                  onSubmitted: (_) => _loading ? null : _submit(),
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
                    child:
                        Text(_loading ? 'جاري الإرسال...' : 'إرسال كود التحقق'),
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
