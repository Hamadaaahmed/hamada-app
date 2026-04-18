import 'package:flutter/material.dart';

import '../../../../app/router.dart';
import '../../data/auth_service.dart';

class ClientOtpScreen extends StatefulWidget {
  final String email;

  const ClientOtpScreen({super.key, required this.email});

  @override
  State<ClientOtpScreen> createState() => _ClientOtpScreenState();
}

class _ClientOtpScreenState extends State<ClientOtpScreen> {
  final _code = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    final code = _code.text.trim();
    if (code.isEmpty) {
      setState(() => _error = 'اكتب كود التحقق');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final res = await AuthService().verifyOtp(
      email: widget.email,
      code: code,
    );

    if (!mounted) return;

    setState(() => _loading = false);

    if (res.ok) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.clientPhoneGate,
        (route) => false,
        arguments: widget.email,
      );
    } else {
      setState(() => _error = res.message);
    }
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('كود التحقق')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'أدخل الكود المرسل إلى:\n${widget.email}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _code,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'كود التحقق',
                    hintText: 'مثال: 123456',
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
                    child: Text(_loading ? 'جاري التحقق...' : 'تأكيد'),
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
