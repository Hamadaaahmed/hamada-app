import 'package:flutter/material.dart';

import '../../../../app/router.dart';
import '../../../../app/ui.dart';
import '../../../../core/notification_navigation_service.dart';
import '../../../admin_posts/presentation/screens/admin_posts_screen.dart';
import '../../../announcement/data/announcement_service.dart';
import '../../../notifications/data/notifications_service.dart';
import '../../data/admin_machines_service.dart';
import '../../data/admin_orders_service.dart';
import '../../data/admin_other_requests_service.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  String? _announcementMessage;
  bool _loadingAnnouncement = false;
  int _ordersCount = 0;
  int _machineRequestsCount = 0;
  int _sparePartRequestsCount = 0;
  int _notificationsCount = 0;

  @override
  void initState() {
    super.initState();
    _refreshDashboard();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationNavigationService.I.processPending();
    });
  }

  Future<void> _refreshDashboard() async {
    await Future.wait([
      _loadAnnouncement(),
      _loadCounts(),
    ]);
  }

  Future<void> _loadCounts() async {
    try {
      final results = await Future.wait([
        AdminOrdersService().listOrders(),
        AdminOtherRequestsService().listRequests('machine_request'),
        AdminOtherRequestsService().listRequests('spare_part_request'),
        NotificationsService().unreadCount(),
      ]);

      if (!mounted) return;
      setState(() {
        _ordersCount = (results[0] as List).length;
        _machineRequestsCount = (results[1] as List).length;
        _sparePartRequestsCount = (results[2] as List).length;
        _notificationsCount = results[3] as int;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _ordersCount = 0;
        _machineRequestsCount = 0;
        _sparePartRequestsCount = 0;
        _notificationsCount = 0;
      });
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
    await AdminMachinesService().logout();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRouter.adminLogin,
      (route) => false,
    );
  }

  Future<void> _openNotifications() async {
    await Navigator.pushNamed(context, AppRouter.notifications);
    await _loadCounts();
  }

  Future<void> _changePassword(BuildContext context) async {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('تغيير كلمة المرور'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور الحالية',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: newCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور الجديدة',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: confirmCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'تأكيد كلمة المرور الجديدة',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final oldPassword = oldCtrl.text.trim();
    final newPassword = newCtrl.text.trim();
    final confirmPassword = confirmCtrl.text.trim();

    if (oldPassword.isEmpty || newPassword.length < 8) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('كلمة المرور الجديدة يجب ألا تقل عن 8 أحرف'),
          ),
        );
      }
      return;
    }

    if (newPassword != confirmPassword) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تأكيد كلمة المرور غير مطابق')),
        );
      }
      return;
    }

    try {
      final data = await AdminMachinesService().changeAdminPassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            data['ok'] == true
                ? 'تم تغيير كلمة المرور بنجاح'
                : (data['error'] ?? 'فشل تغيير كلمة المرور').toString(),
          ),
          backgroundColor: data['ok'] == true ? null : Colors.red,
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر تنفيذ العملية، حاول مرة أخرى'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<_AdminActionItem> _actions() {
    return [
      _AdminActionItem(
        title: 'إشعارات الإدارة',
        subtitle: _notificationsCount > 0
            ? 'لديك $_notificationsCount إشعار غير مقروء'
            : 'آخر الطلبات والتنبيهات والرسائل.',
        icon: Icons.notifications_active_outlined,
        accent: AppUiColors.success,
        badgeCount: _notificationsCount,
        onTap: _openNotifications,
      ),
      _AdminActionItem(
        title: 'طلبات الصيانة',
        subtitle: 'فتح الطلبات وقبولها وتحديد المواعيد بسهولة.',
        icon: Icons.handyman_outlined,
        accent: AppUiColors.info,
        badgeCount: _ordersCount,
        onTap: () async {
          await Navigator.pushNamed(context, AppRouter.adminOrders);
          await _loadCounts();
        },
      ),
      _AdminActionItem(
        title: 'طلبات المكن',
        subtitle: 'متابعة الطلبات غير المتاحة في الكتالوج.',
        icon: Icons.precision_manufacturing_outlined,
        accent: AppUiColors.purple,
        badgeCount: _machineRequestsCount,
        onTap: () async {
          await Navigator.pushNamed(context, AppRouter.adminMachineRequests);
          await _loadCounts();
        },
      ),
      _AdminActionItem(
        title: 'طلبات قطع الغيار',
        subtitle: 'تسعير الطلب أو تحديد عدم التوفر والموعد.',
        icon: Icons.extension_outlined,
        accent: AppUiColors.warning,
        badgeCount: _sparePartRequestsCount,
        onTap: () async {
          await Navigator.pushNamed(context, AppRouter.adminSparePartRequests);
          await _loadCounts();
        },
      ),
      _AdminActionItem(
        title: 'المحادثات',
        subtitle: 'افتح المحادثة أو الطلب المرتبط مباشرة.',
        icon: Icons.forum_outlined,
        accent: const Color(0xFF0284C7),
        onTap: () async {
          await Navigator.pushNamed(context, AppRouter.adminChats);
          await _loadCounts();
        },
      ),
      _AdminActionItem(
        title: 'المكن والتسعير',
        subtitle: 'إضافة وتعديل الأسعار والترتيب.',
        icon: Icons.inventory_2_outlined,
        accent: const Color(0xFF0F766E),
        onTap: () async {
          await Navigator.pushNamed(context, AppRouter.adminMachines);
          await _loadCounts();
        },
      ),
      _AdminActionItem(
        title: 'حسابات العملاء',
        subtitle: 'فتح حساب العميل بسرعة من القائمة أو الطلب.',
        icon: Icons.account_balance_wallet_outlined,
        accent: const Color(0xFFEA580C),
        onTap: () async {
          await Navigator.pushNamed(context, AppRouter.adminClients);
          await _loadCounts();
        },
      ),
      _AdminActionItem(
        title: 'بيانات العملاء',
        subtitle: 'تعديل البريد الإلكتروني ورقم الهاتف.',
        icon: Icons.people_alt_outlined,
        accent: const Color(0xFFDB2777),
        onTap: () async {
          await Navigator.pushNamed(context, AppRouter.adminClientProfiles);
          await _loadCounts();
        },
      ),
      _AdminActionItem(
        title: 'الإعلانات والتنبيهات',
        subtitle: 'إدارة التنبيه العام والمنشورات والصور.',
        icon: Icons.campaign_outlined,
        accent: const Color(0xFF7C3AED),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminPostsScreen()),
          );
          await _refreshDashboard();
        },
      ),
    ];
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
            child: const Icon(Icons.campaign_outlined, color: AppUiColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'تنبيه عام',
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
    final actions = _actions();

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('لوحة التحكم'),
          actions: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  onPressed: _openNotifications,
                  icon: const Icon(Icons.notifications_none_rounded),
                  tooltip: 'إشعارات الإدارة',
                ),
                if (_notificationsCount > 0)
                  PositionedDirectional(
                    top: 2,
                    start: 2,
                    child: AppCountBadge(
                      count: _notificationsCount,
                      compact: true,
                      color: AppUiColors.success,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _refreshDashboard,
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'تحديث',
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _changePassword(context),
              icon: const Icon(Icons.lock_outline_rounded),
              tooltip: 'تغيير كلمة المرور',
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'تسجيل الخروج',
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _refreshDashboard,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              AppHeroHeader(
                title: 'تنقل أسرع للإدارة بدون تغيير في الشغل',
                subtitle:
                    'تم الحفاظ على الوظائف الحالية والربط، مع ترتيب أوضح للطلبات والإشعارات والمحادثات.',
                icon: Icons.admin_panel_settings_outlined,
                action: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pushNamed(context, AppRouter.adminOrders),
                        icon: const Icon(Icons.handyman_outlined),
                        label: const Text('طلبات الصيانة'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _openNotifications,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54),
                        ),
                        icon: const Icon(Icons.notifications_active_outlined),
                        label: const Text('الإشعارات'),
                      ),
                    ),
                  ],
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
                title: 'اختصارات الإدارة',
                subtitle: 'كل الأقسام الأساسية بنفس الأسماء والوظائف الحالية.',
              ),
              const SizedBox(height: 12),
              GridView.builder(
                itemCount: actions.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.92,
                ),
                itemBuilder: (_, index) => _AdminActionCard(item: actions[index]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminActionItem {
  const _AdminActionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
    this.badgeCount = 0,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;
  final int badgeCount;
}

class _AdminActionCard extends StatelessWidget {
  const _AdminActionCard({required this.item});

  final _AdminActionItem item;

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
