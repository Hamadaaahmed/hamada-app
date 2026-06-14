import 'package:flutter/material.dart';
import '../../data/admin_client_profiles_service.dart';
import 'admin_client_profile_edit_screen.dart';

class AdminClientProfilesScreen extends StatefulWidget {
  const AdminClientProfilesScreen({super.key});

  @override
  State<AdminClientProfilesScreen> createState() =>
      _AdminClientProfilesScreenState();
}

class _AdminClientProfilesScreenState extends State<AdminClientProfilesScreen> {
  final _service = AdminClientProfilesService();
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
      _snack('خطأ في تحميل بيانات العملاء: $e', error: true);
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
      return email.contains(_query) ||
          phone.contains(_query) ||
          id.contains(_query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final rows = _filtered;

    return Scaffold(
      appBar: AppBar(
        title: const Text('بيانات العملاء'),
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
                hintText: 'ابحث بالإيميل أو الهاتف أو رقم العميل',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : rows.isEmpty
                    ? const Center(child: Text('لا توجد بيانات عملاء'))
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: rows.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final item = rows[i];
                            final email = (item['email'] ?? '').toString();
                            final phone = (item['phone'] ?? '').toString();

                            return ListTile(
                              leading: CircleAvatar(
                                child: Text('${item['id']}'),
                              ),
                              title: Text(
                                email.trim().isNotEmpty
                                    ? email
                                    : 'عميل #${item['id']}',
                              ),
                              subtitle: Text(
                                phone.trim().isNotEmpty ? phone : 'لا يوجد رقم هاتف',
                              ),
                              trailing: const Icon(Icons.edit_outlined),
                              onTap: () async {
                                final changed = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        AdminClientProfileEditScreen(item: item),
                                  ),
                                );
                                if (changed == true) {
                                  _load();
                                }
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
