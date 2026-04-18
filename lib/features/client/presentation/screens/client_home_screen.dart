import 'package:flutter/material.dart';

import '../../../../app/client_bottom_nav.dart';
import '../../../../app/router.dart';
import '../../../../app/ui.dart';
import '../../../../core/notification_navigation_service.dart';
import '../../../../features/admin_posts/presentation/screens/client_admin_posts_screen.dart';
import '../../../../features/announcement/data/announcement_service.dart';
import '../../../../features/auth/data/auth_service.dart';
import '../../../../features/notifications/data/client_notifications_service.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  String? _announcementMessage;
  bool _loadingAnnouncement = false;
  int _unreadNotifications = 0;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _refreshHome();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationNavigationService.I.processPending();
    });
  }

  Future<void> _refreshHome() async {
    await Future.wait([
      _loadAnnouncement(),
      _loadUnreadNotifications(),
    ]);
  }

  Future<void> _loadUnreadNotifications() async {
    try {
      final count = await ClientNotificationsService().unreadCount();
      if (!mounted) return;
      setState(() => _unreadNotifications = count);
    } catch (_) {
      if (!mounted) return;
      setState(() => _unreadNotifications = 0);
    }
  }

  Future<void> _loadAnnouncement() async {
    if (_loadingAnnouncement) return;
    setState(() => _loadingAnnouncement = true);

    try {
      final data = await AnnouncementService().getAnnouncement();
      if (!mounted) return;
      final raw = data['announcement'];
      setState(() {
        _announcementMessage = raw is Map
            ? ((raw['message'] ?? '').toString().trim().isEmpty
                ? null
                : (raw['message'] ?? '').toString())
            : null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _announcementMessage = null);
    } finally {
      if (mounted) {
        setState(() => _loadingAnnouncement = false);
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    await AuthService().logout();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRouter.clientEmail,
      (route) => false,
    );
  }

  Future<void> _openRoute(String routeName) async {
    final changed = await Navigator.pushNamed(context, routeName);
    if (!mounted) return;

    if (changed == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تنفيذ العملية بنجاح')),
      );
    }
    await _loadUnreadNotifications();
  }

  Future<void> _openAdminPosts() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ClientAdminPostsScreen()),
    );
    await _loadUnreadNotifications();
  }

  List<_HomeActionItem> _items() {
    return [
      _HomeActionItem(
        title: 'طلب صيانة',
        subtitle: 'إنشاء طلب صيانة جديد بنفس الوظائف الحالية.',
        icon: Icons.handyman_outlined,
        accent: AppUiColors.primary,
        searchTokens: const ['صيانة', 'طلب', 'خدمة'],
        onTap: () => _openRoute(AppRouter.clientCreateOrder),
      ),
      _HomeActionItem(
        title: 'طلب مكن',
        subtitle: 'إرسال طلب ماكينة غير موجودة مع الصور والموقع.',
        icon: Icons.precision_manufacturing_outlined,
        accent: AppUiColors.purple,
        searchTokens: const ['مكن', 'ماكينة', 'طلب'],
        onTap: () => _openRoute(AppRouter.clientCreateMachineRequest),
      ),
      _HomeActionItem(
        title: 'طلب قطع غيار',
        subtitle: 'إرسال طلب قطعة غيار غير متوفرة حاليًا.',
        icon: Icons.extension_outlined,
        accent: AppUiColors.warning,
        searchTokens: const ['غيار', 'قطع', 'طلب'],
        onTap: () => _openRoute(AppRouter.clientCreateSparePartRequest),
      ),
      _HomeActionItem(
        title: 'طلباتي',
        subtitle: 'متابعة كل الطلبات والحالات والمواعيد.',
        icon: Icons.receipt_long_outlined,
        accent: AppUiColors.info,
        searchTokens: const ['طلباتي', 'طلبات', 'حالات'],
        onTap: () => _openRoute(AppRouter.clientOrders),
      ),
      _HomeActionItem(
        title: 'إشعاراتي',
        subtitle: _unreadNotifications > 0
            ? 'لديك $_unreadNotifications إشعار غير مقروء.'
            : 'كل التحديثات والتنبيهات في مكان واحد.',
        icon: Icons.notifications_active_outlined,
        accent: AppUiColors.success,
        badgeCount: _unreadNotifications,
        searchTokens: const ['إشعارات', 'تنبيهات'],
        onTap: () => _openRoute(AppRouter.clientNotifications),
      ),
      _HomeActionItem(
        title: 'الشات',
        subtitle: 'التواصل مع الإدارة بدون تغيير الوظائف الحالية.',
        icon: Icons.forum_outlined,
        accent: AppUiColors.info,
        searchTokens: const ['شات', 'محادثة', 'رسائل'],
        onTap: () => _openRoute(AppRouter.clientChat),
      ),
      _HomeActionItem(
        title: 'حسابي',
        subtitle: 'الرصيد والمستحقات وسجل المعاملات.',
        icon: Icons.account_balance_wallet_outlined,
        accent: const Color(0xFF0F766E),
        searchTokens: const ['حساب', 'رصيد', 'مستحق'],
        onTap: () => _openRoute(AppRouter.clientAccount),
      ),
      _HomeActionItem(
        title: 'إعلانات الإدارة',
        subtitle: 'آخر الصور والتنبيهات والمنشورات.',
        icon: Icons.campaign_outlined,
        accent: const Color(0xFFDB2777),
        searchTokens: const ['إعلانات', 'منشورات', 'تنبيه'],
        onTap: _openAdminPosts,
      ),
    ];
  }

  List<_HomeActionItem> _filteredItems() {
    final items = _items();
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return items;

    return items.where((item) {
      final haystack = [item.title, item.subtitle, ...item.searchTokens]
          .join(' ')
          .toLowerCase();
      return haystack.contains(q);
    }).toList();
  }

  Widget _announcementBanner() {
    final announcement = (_announcementMessage ?? '').trim();
    if (announcement.isEmpty) return const SizedBox.shrink();

    return AppSurfaceCard(
      margin: const EdgeInsets.only(top: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppUiColors.primary.withAlpha(18),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.campaign_outlined,
              color: AppUiColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'تنبيه من الإدارة',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  announcement,
                  style: const TextStyle(
                    color: AppUiColors.muted,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredItems();

    return Scaffold(
      appBar: AppBar(
        title: const Text('حمادة صيانة'),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () => _openRoute(AppRouter.clientNotifications),
                icon: const Icon(Icons.notifications_none_rounded),
                tooltip: 'الإشعارات',
              ),
              if (_unreadNotifications > 0)
                PositionedDirectional(
                  top: 2,
                  start: 2,
                  child: AppCountBadge(
                    count: _unreadNotifications,
                    compact: true,
                    color: AppUiColors.success,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _refreshHome,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'تحديث',
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: const ClientBottomNav(currentIndex: 0),
      body: RefreshIndicator(
        onRefresh: _refreshHome,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            AppHeroHeader(
              title: 'نفس البرنامج، لكن بتنقل أوضح وراحة أكثر',
              subtitle:
                  'كل الوظائف الحالية محفوظة كما هي، مع واجهة أنظف واختصارات أسرع للعميل.',
              icon: Icons.home_repair_service_outlined,
              action: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _openRoute(AppRouter.clientCreateOrder),
                      icon: const Icon(Icons.add_task_outlined),
                      label: const Text('طلب صيانة'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openRoute(AppRouter.clientOrders),
                      icon: const Icon(Icons.receipt_long_outlined),
                      label: const Text('طلباتي'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                hintText: 'بدور على إيه ؟',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            if (_loadingAnnouncement)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: LinearProgressIndicator(minHeight: 3),
              ),
            _announcementBanner(),
            const SizedBox(height: 18),
            const AppSectionHeader(
              title: 'الخدمات الرئيسية',
              subtitle: 'نفس أسماء الصفحات ووظائفها الحالية مع ترتيب أسهل.',
            ),
            const SizedBox(height: 12),
            GridView.builder(
              itemCount: items.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.93,
              ),
              itemBuilder: (_, index) => _ClientActionCard(item: items[index]),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('تسجيل خروج'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeActionItem {
  const _HomeActionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
    required this.searchTokens,
    this.badgeCount = 0,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;
  final List<String> searchTokens;
  final int badgeCount;
}

class _ClientActionCard extends StatelessWidget {
  const _ClientActionCard({required this.item});

  final _HomeActionItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(26),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppUiColors.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: item.accent.withAlpha(18),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Icon(item.icon, color: item.accent),
                    ),
                    const Spacer(),
                    if (item.badgeCount > 0)
                      AppCountBadge(
                        count: item.badgeCount,
                        color: item.accent,
                      ),
                  ],
                ),
                const Spacer(),
                Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.subtitle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppUiColors.muted,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
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
