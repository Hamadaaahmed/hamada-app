import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool isLogin = true;
  String message = '';

  Future<void> submit() async {
    setState(() {
      loading = true;
      message = '';
    });

    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      final result = isLogin
          ? await ApiService.login(email: email, password: password)
          : await ApiService.register(
              email: email,
              password: password,
              deviceId: 'flutter-app-device',
            );

      if (!mounted) return;

      if (result['ok'] == true) {
        final token = result['token'];
        if (token != null && token.toString().isNotEmpty) {
          await AuthService.saveToken(token.toString());
        }

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        setState(() {
          message = result['message'] ?? 'حدث خطأ';
        });
      }
    } catch (e) {
      setState(() {
        message = 'حدث خطأ';
      });
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLogin ? 'تسجيل الدخول' : 'إنشاء حساب'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'البريد الإلكتروني',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : submit,
              child: Text(loading ? 'جاري التحميل...' : (isLogin ? 'دخول' : 'تسجيل')),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  isLogin = !isLogin;
                  message = '';
                });
              },
              child: Text(isLogin ? 'إنشاء حساب جديد' : 'عندي حساب بالفعل'),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
