import 'package:flutter/material.dart';

import '../../../../app/router.dart';
import '../../../../app/ui.dart';
import '../../../../core/app_states.dart';
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
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent && mounted) setState(() => _loading = true);
    try {
      final rows = await _service.listConversations();
      if (!mounted) return;
      setState(() => _items = rows);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تحميل المحادثات: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!silent && mounted) setState(() => _loading = false);
    }
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

  List<Map<String, dynamic>> _visibleItems() {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _items;
    return _items.where((item) {
      final haystack = [
        (item['phone'] ?? '').toString(),
        (item['last_message'] ?? '').toString(),
        (item['order_id'] ?? '').toString(),
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  Future<void> _openConversation(Map<String, dynamic> item) async {
    final conversationId = int.tryParse('${item['id']}') ?? 0;
    if (conversationId <= 0) return;

    await Navigator.pushNamed(
      context,
      AppRouter.adminChatDetails,
      arguments: conversationId,
    );
    if (!mounted) return;
    await _load(silent: true);
  }

  Future<void> _openOrder(int orderId) async {
    if (orderId <= 0) return;
    await Navigator.pushNamed(
      context,
      AppRouter.adminOrderDetails,
      arguments: orderId,
    );
    if (!mounted) return;
    await _load(silent: true);
  }

  @override
  Widget build(BuildContext context) {
    final items = _visibleItems();
    final unreadConversations = items.where((item) {
      final unreadCount = int.tryParse('${item['unread_count']}') ?? 0;
      return unreadCount > 0;
    }).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('المحادثات'),
        actions: [
          IconButton(
            onPressed: () => _load(),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'تحديث',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const AppLoadingView(message: 'جاري تحميل المحادثات')
          : items.isEmpty
              ? const AppEmptyState(
                  title: 'لا توجد محادثات بعد',
                  subtitle: 'عند وصول رسالة جديدة من العميل ستظهر هنا تلقائيًا.',
                  icon: Icons.forum_outlined,
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    children: [
                      AppHeroHeader(
                        title: 'المحادثات مرتبطة بالطلبات عند توفرها',
                        subtitle:
                            'يمكنك فتح المحادثة مباشرة أو الانتقال إلى الطلب المرتبط من نفس البطاقة.',
                        icon: Icons.forum_outlined,
                      ),
                      const SizedBox(height: 14),
                      AppSurfaceCard(
                        child: Row(
                          children: [
                            Expanded(
                              child: _ChatsMetric(
                                label: 'إجمالي المحادثات',
                                value: '${items.length}',
                                icon: Icons.chat_bubble_outline_rounded,
                                color: AppUiColors.info,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _ChatsMetric(
                                label: 'غير المقروء',
                                value: '$unreadConversations',
                                icon: Icons.mark_chat_unread_outlined,
                                color: AppUiColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        onChanged: (value) => setState(() => _query = value),
                        decoration: const InputDecoration(
                          hintText: 'ابحث برقم العميل أو نص الرسالة',
                          prefixIcon: Icon(Icons.search_rounded),
                        ),
                      ),
                      const SizedBox(height: 14),
                      ...items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ChatCard(
                            item: item,
                            dateLabel: _fmtDate(
                              item['last_message_at'].toString().isNotEmpty
                                  ? item['last_message_at'].toString()
                                  : item['created_at'].toString(),
                            ),
                            onOpenConversation: () => _openConversation(item),
                            onOpenOrder: () => _openOrder(
                              int.tryParse('${item['order_id']}') ?? 0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _ChatsMetric extends StatelessWidget {
  const _ChatsMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha(14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppUiColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatCard extends StatelessWidget {
  const _ChatCard({
    required this.item,
    required this.dateLabel,
    required this.onOpenConversation,
    required this.onOpenOrder,
  });

  final Map<String, dynamic> item;
  final String dateLabel;
  final VoidCallback onOpenConversation;
  final VoidCallback onOpenOrder;

  @override
  Widget build(BuildContext context) {
    final phone = (item['phone'] ?? '').toString();
    final last = (item['last_message'] ?? '').toString();
    final orderId = int.tryParse('${item['order_id']}') ?? 0;
    final unreadCount = int.tryParse('${item['unread_count']}') ?? 0;

    return AppSurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppUiColors.info.withAlpha(18),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.person_outline_rounded, color: AppUiColors.info),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    phone.trim().isNotEmpty
                        ? ContactNameText(
                            phone: phone,
                            fallbackPrefix: null,
                          )
                        : Text(
                            'عميل #${item['client_id'] ?? ''}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                    const SizedBox(height: 6),
                    Text(
                      last.trim().isEmpty ? 'لا توجد رسائل بعد' : last,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppUiColors.text,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (unreadCount > 0)
                AppCountBadge(
                  count: unreadCount,
                  color: AppUiColors.success,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (orderId > 0)
                AppTag(
                  icon: Icons.handyman_outlined,
                  label: 'طلب #$orderId',
                  color: AppUiColors.info,
                ),
              AppTag(
                icon: Icons.schedule_rounded,
                label: dateLabel,
                color: AppUiColors.success,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onOpenConversation,
                  icon: const Icon(Icons.forum_outlined),
                  label: const Text('فتح المحادثة'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: orderId > 0 ? onOpenOrder : null,
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('فتح الطلب'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
