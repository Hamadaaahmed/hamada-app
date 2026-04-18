import 'package:flutter/material.dart';

import '../../../../app/ui.dart';
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

  String _targetLabel(Map<String, dynamic> data) {
    final orderId = int.tryParse('${data['order_id'] ?? ''}') ?? 0;
    if (orderId > 0) return 'يفتح طلب الصيانة رقم #$orderId';

    final otherRequestId = int.tryParse('${data['other_request_id'] ?? ''}') ?? 0;
    if (otherRequestId > 0) return 'يفتح الطلب رقم #$otherRequestId';

    final conversationId =
        int.tryParse('${data['conversationId'] ?? data['conversation_id'] ?? ''}') ??
            0;
    if (conversationId > 0) return 'يفتح الشات مباشرة';

    final type = (data['type'] ?? '').toString();
    if (type.contains('account')) return 'يفتح صفحة الحساب';
    if (type.contains('announcement') || type.contains('post')) {
      return 'يفتح الصفحة الرئيسية';
    }

    return 'يعرض تفاصيل الإشعار';
  }

  Color _accentForItem(NotificationItemModel item) {
    final data = item.dataJson;
    if ((int.tryParse('${data['order_id'] ?? ''}') ?? 0) > 0) {
      return AppUiColors.info;
    }
    if ((int.tryParse('${data['other_request_id'] ?? ''}') ?? 0) > 0) {
      return AppUiColors.purple;
    }
    if ((int.tryParse('${data['conversationId'] ?? data['conversation_id'] ?? ''}') ??
                0) >
        0) {
      return AppUiColors.success;
    }
    if ((data['type'] ?? '').toString().contains('account')) {
      return const Color(0xFF0F766E);
    }
    return AppUiColors.primary;
  }

  IconData _iconForItem(NotificationItemModel item) {
    final data = item.dataJson;
    if ((int.tryParse('${data['order_id'] ?? ''}') ?? 0) > 0) {
      return Icons.handyman_outlined;
    }
    if ((int.tryParse('${data['other_request_id'] ?? ''}') ?? 0) > 0) {
      return Icons.extension_outlined;
    }
    if ((int.tryParse('${data['conversationId'] ?? data['conversation_id'] ?? ''}') ??
                0) >
        0) {
      return Icons.forum_outlined;
    }
    return item.isRead
        ? Icons.notifications_none_outlined
        : Icons.notifications_active_outlined;
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
            icon: const Icon(Icons.done_all_rounded),
            tooltip: 'تعليم الكل كمقروء',
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'تحديث',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const AppLoadingView(message: 'جاري تحميل الإشعارات')
          : _items.isEmpty
              ? const AppEmptyState(
                  title: 'لا توجد إشعارات بعد',
                  subtitle: 'ستظهر هنا كل التنبيهات المهمة الخاصة بحسابك وطلباتك.',
                  icon: Icons.notifications_none_outlined,
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    children: [
                      AppHeroHeader(
                        title: unreadCount > 0
                            ? 'عندك $unreadCount إشعار غير مقروء'
                            : 'كل إشعاراتك في مكان واحد',
                        subtitle:
                            'عند الضغط على الإشعار يتم فتح الصفحة المرتبطة مباشرة كلما كانت البيانات متاحة.',
                        icon: Icons.notifications_active_outlined,
                      ),
                      const SizedBox(height: 14),
                      ..._items.map((item) {
                        final accent = _accentForItem(item);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AppSurfaceCard(
                            padding: const EdgeInsets.all(16),
                            child: InkWell(
                              onTap: () => _openItem(item),
                              borderRadius: BorderRadius.circular(22),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: accent.withAlpha(18),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        alignment: Alignment.center,
                                        child: Icon(
                                          _iconForItem(item),
                                          color: accent,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.title,
                                              style: TextStyle(
                                                fontWeight: item.isRead
                                                    ? FontWeight.w700
                                                    : FontWeight.w900,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _fmtDate(item.createdAt),
                                              style: const TextStyle(
                                                color: AppUiColors.muted,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (!item.isRead)
                                        const AppCountBadge(count: 1, compact: true),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    item.body,
                                    style: const TextStyle(
                                      color: AppUiColors.text,
                                      height: 1.6,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      AppTag(
                                        icon: Icons.arrow_outward_rounded,
                                        label: _targetLabel(item.dataJson),
                                        color: accent,
                                      ),
                                      const Spacer(),
                                      const Icon(
                                        Icons.chevron_left_rounded,
                                        color: AppUiColors.muted,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
    );
  }
}
