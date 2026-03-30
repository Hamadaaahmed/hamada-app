import 'package:flutter/material.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الدفع')),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🇸🇦 الدفع من السعودية:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('بنك البلاد'),
            Text('الاسم: مصطفى سعد مصطفى'),
            Text('IBAN: SA7515000720123396930007'),
            SizedBox(height: 20),
            Text(
              'بعد التحويل أرسل صورة العملية عبر البوت في تيليجرام.',
            ),
            SizedBox(height: 30),
            Divider(),
            SizedBox(height: 20),
            Text(
              '🇦🇪 الدفع من الإمارات:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('يرجى التواصل معنا لتحديد طريقة الدفع'),
            Text('Telegram: @Hamada_net'),
          ],
        ),
      ),
    );
  }
}
