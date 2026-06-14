import 'package:flutter/material.dart';
import '../../../../app/router.dart';
import '../../../../core/contact_name_text.dart';
import '../../data/admin_clients_service.dart';

class AdminClientsScreen extends StatefulWidget {
  const AdminClientsScreen({super.key});

  @override
  State<AdminClientsScreen> createState() => _AdminClientsScreenState();
}

class _AdminClientsScreenState extends State<AdminClientsScreen> {
  final _service = AdminClientsService();
  final _search = TextEditingController();

  bool _loading = true;
  List<Map<String, dynamic>> _items = [];
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
    _search.addListener(() {
      if (!mounted) return;
      setState(() => _query = _search.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    try {
      final rows = await _service.listClients();
      if (!mounted) return;
      setState(() => _items = rows);
    } catch (e) {
      if (!mounted) return;
      _snack('خطأ في تحميل العملاء: $e', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
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

  List<Map<String, dynamic>> get _filtered {
    if (_query.isEmpty) return _items;
    return _items.where((e) {
      final email = e['email'].toString().toLowerCase();
      final phone = (e['phone'] ?? '').toString().toLowerCase();
      final id = '${e['id']}';
      return email.contains(_query) || phone.contains(_query) || id.contains(_query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final rows = _filtered;

    return Scaffold(
      appBar: AppBar(
        title: const Text('حسابات العملاء'),
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: TextField(
              controller: _search,
              decoration: const InputDecoration(
                hintText: 'ابحث برقم الهاتف أو رقم العميل',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : rows.isEmpty
                    ? const Center(child: Text('لا توجد حسابات عملاء'))
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: rows.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final item = rows[i];
                            final blocked = item['blocked'] == true;

                            final count = item['items_count'] as int? ?? 1;
                            final blockedCount =
                                item['blocked_count'] as int? ?? 0;

                            return ListTile(
                              leading: CircleAvatar(
                                child: Text('${item['id']}'),
                              ),
                                title: ((item['phone'] ?? '').toString().trim().isNotEmpty)
                                    ? ContactNameText(
                                        phone: (item['phone'] ?? '').toString(),
                                        fallbackPrefix: null,
                                      )
                                    : Text('عميل #${item['id']}'),
                              subtitle: Text(
                                blocked
                                    ? 'عدد الحسابات: $count   •   محظور: $blockedCount'
                                    : 'عدد الحسابات: $count   •   الحالة: نشط',
                                style: TextStyle(
                                  color: blocked ? Colors.red : null,
                                  fontWeight: blocked ? FontWeight.bold : null,
                                ),
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRouter.adminClientAccount,
                                  arguments: item['id'] as int,
                                );
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
