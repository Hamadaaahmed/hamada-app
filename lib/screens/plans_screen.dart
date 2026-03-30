import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  List<dynamic> plans = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadPlans();
  }

  Future<void> loadPlans() async {
    try {
      final result = await ApiService.getPlans();
      setState(() {
        plans = result;
      });
    } catch (_) {
      setState(() {
        plans = [];
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الباقات')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final p = plans[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(p['name'] ?? ''),
                    subtitle: Text(
                      '🇸🇦 ${p['price_sar']} ريال\n🇦🇪 ${p['price_aed']} درهم',
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {},
                      child: const Text('اختيار'),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
