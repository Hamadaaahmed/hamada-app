import 'package:flutter/material.dart';

import '../../../../core/app_feedback.dart';
import '../../../../core/app_states.dart';
import '../../../../core/notification_navigation_service.dart';
import '../../../notifications/data/client_notifications_service.dart';
import '../../../notifications/models/notification_item_model.dart';

class ClientNotificationsScreen extends StatefulWidget {
  const ClientNotificationsScreen({super.key});

  @override
  State<ClientNotificationsScreen> createState() =>
      _ClientNotificationsScreenState();
}

class _ClientNotificationsScreenState extends State<ClientNotificationsScreen> {
  final _service = ClientNotificationsService();
  bool _loading = true;
  List<NotificationItemModel> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    try {
      final rows = await _service.listNotifications();
      if (!mounted) return;
      setState(() => _items = rows);
    } catch (e) {
      if (!mounted) return;
      _snack('خطأ في تحميل الإشعارات: $e', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String msg, {bool error = false, bool success = false}) {
    AppFeedback.show(context, message: msg, error: error, success: success);
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

  Future<void> _markAllRead() async {
    try {
      final res = await _service.markRead(all: true);
      if (res['ok'] == true) {
        _snack('تم تعليم الكل كمقروء', success: true);
        await _load();
      } else {
        _snack((res['error'] ?? 'فشل العملية').toString(), error: true);
      }
    } catch (_) {
      _snack('تعذر تحميل الإشعارات، حاول مرة أخرى', error: true);
    }
  }

  Future<void> _openFallbackDialog(NotificationItemModel item) async {
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item.title),
        content: Text(item.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Future<void> _openItem(NotificationItemModel item) async {
    if (!item.isRead) {
      try {
        await _service.markRead(id: item.id);
      } catch (_) {}
    }

    if (!mounted) return;

    final opened = await NotificationNavigationService.I.openFromData(
      navigator: Navigator.of(context),
      data: item.dataJson,
      isAdmin: false,
    );

    if (!opened && mounted) {
      await _openFallbackDialog(item);
    }

    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _items.where((e) => !e.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          unreadCount > 0 ? 'إشعاراتي ($unreadCount)' : 'إشعاراتي',
        ),
        actions: [
          IconButton(
            onPressed: _markAllRead,
            icon: const Icon(Icons.done_all),
            tooltip: 'تعليم الكل كمقروء',
          ),
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: _loading
          ? const AppLoadingView(message: 'جاري تحميل الإشعارات')
          : _items.isEmpty
              ? AppEmptyState(
                  title: 'لا توجد إشعارات بعد',
                  subtitle: 'ستظهر هنا آخر التحديثات والتنبيهات المهمة.',
                  icon: Icons.notifications_none_outlined,
                  actionLabel: 'تحديث',
                  onAction: _load,
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final item = _items[i];

                      return ListTile(
                        onTap: () => _openItem(item),
                        leading: Icon(
                          item.isRead
                              ? Icons.notifications_none
                              : Icons.notifications_active,
                        ),
                        title: Text(
                          item.title,
                          style: TextStyle(
                            fontWeight:
                                item.isRead ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${item.body}\n${_fmtDate(item.createdAt)}',
                        ),
                        isThreeLine: true,
                        trailing: item.isRead
                            ? const Icon(Icons.done, size: 18)
                            : const Icon(Icons.fiber_manual_record, size: 12),
                      );
                    },
                  ),
                ),
    );
  }
}
