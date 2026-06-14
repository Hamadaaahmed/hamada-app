import 'package:flutter/material.dart';

import '../../../../app/router.dart';
import '../../../../core/contact_name_text.dart';
import '../../data/admin_chat_service.dart';

class AdminChatsScreen extends StatefulWidget {
  const AdminChatsScreen({super.key});

  @override
  State<AdminChatsScreen> createState() => _AdminChatsScreenState();
}

class _AdminChatsScreenState extends State<AdminChatsScreen> {
  final _service = AdminChatService();

  bool _loading = true;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent && mounted) {
      setState(() => _loading = true);
    }

    try {
      final rows = await _service.listConversations();
      if (!mounted) return;
      setState(() => _items = rows);
    } catch (_) {
      if (!mounted) return;
      _snack('تعذر تحميل المحادثات، حاول مرة أخرى', error: true);
    } finally {
      if (!silent && mounted) {
        setState(() => _loading = false);
      }
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

  String _fmtDate(String raw) {
    if (raw.trim().isEmpty) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      final h24 = dt.hour;
      final h12 = h24 == 0 ? 12 : (h24 > 12 ? h24 - 12 : h24);
      final period = h24 >= 12 ? 'م' : 'ص';
      final mm = dt.minute.toString().padLeft(2, '0');
      final dd = dt.day.toString().padLeft(2, '0');
      final mo = dt.month.toString().padLeft(2, '0');
      return '$dd-$mo-${dt.year} | $h12:$mm $period';
    } catch (_) {
      return raw;
    }
  }

  DateTime? _tryParseDate(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  List<Map<String, dynamic>> _visibleItems() {
    final filtered = _items.where((item) {
      final last = (item['last_message'] ?? '').toString().trim();
      return last.isNotEmpty;
    }).toList();

    final buckets = <String, Map<String, dynamic>>{};

    for (final item in filtered) {
      final phone = (item['phone'] ?? '').toString().trim();
      final clientId = '${item['client_id'] ?? ''}'.trim();
      final key = phone.isNotEmpty ? 'phone:$phone' : 'client:$clientId';

      final current = buckets[key];
      if (current == null) {
        buckets[key] = item;
        continue;
      }

      final currentDate = _tryParseDate(
        (current['last_message_at'] ?? '').toString().isNotEmpty
            ? (current['last_message_at'] ?? '').toString()
            : (current['created_at'] ?? '').toString(),
      );

      final nextDate = _tryParseDate(
        (item['last_message_at'] ?? '').toString().isNotEmpty
            ? (item['last_message_at'] ?? '').toString()
            : (item['created_at'] ?? '').toString(),
      );

      if (currentDate == null && nextDate != null) {
        buckets[key] = item;
      } else if (currentDate != null &&
          nextDate != null &&
          nextDate.isAfter(currentDate)) {
        buckets[key] = item;
      }
    }

    final rows = buckets.values.toList();

    rows.sort((a, b) {
      final aDate = _tryParseDate(
        (a['last_message_at'] ?? '').toString().isNotEmpty
            ? (a['last_message_at'] ?? '').toString()
            : (a['created_at'] ?? '').toString(),
      );

      final bDate = _tryParseDate(
        (b['last_message_at'] ?? '').toString().isNotEmpty
            ? (b['last_message_at'] ?? '').toString()
            : (b['created_at'] ?? '').toString(),
      );

      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });

    return rows;
  }

  Future<void> _openConversation(Map<String, dynamic> item) async {
    await Navigator.pushNamed(
      context,
      AppRouter.adminChatDetails,
      arguments: item['id'] as int,
    );

    if (!mounted) return;
    await _load(silent: true);
  }

  Widget _leftSide(int unreadCount) {
    return SizedBox(
      width: 40,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.chevron_left, size: 28),
          const SizedBox(height: 8),
          if (unreadCount > 0)
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFF66BB6A),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            const SizedBox(height: 32),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _visibleItems();

    return Scaffold(
      appBar: AppBar(
        title: const Text('محادثات الأدمن'),
        actions: [
          IconButton(
            onPressed: () => _load(),
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? const Center(child: Text('لا توجد محادثات بعد'))
              : RefreshIndicator(
                  onRefresh: () => _load(),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final item = items[i];
                      final phone = (item['phone'] ?? '').toString();
                      final last = (item['last_message'] ?? '').toString();
                      final orderId = item['order_id'];
                      final unreadCount =
                          int.tryParse('${item['unread_count']}') ?? 0;

                      return ListTile(
                        onTap: () => _openConversation(item),
                        leading: _leftSide(unreadCount),
                        title: phone.trim().isNotEmpty
                            ? ContactNameText(
                                phone: phone,
                                fallbackPrefix: null,
                              )
                            : Text('عميل #${item['client_id'] ?? ''}'),
                        subtitle: Text(
                          '${orderId != null ? "طلب #$orderId\n" : ""}'
                          '${last.trim().isEmpty ? "لا توجد رسائل بعد" : last}\n'
                          '${_fmtDate(item['last_message_at'].toString().isNotEmpty ? item['last_message_at'].toString() : item['created_at'].toString())}',
                        ),
                        isThreeLine: true,
                        trailing: const CircleAvatar(
                          child: Icon(Icons.chat_bubble_outline),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
