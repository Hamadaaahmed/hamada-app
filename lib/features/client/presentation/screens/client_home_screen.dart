import 'package:flutter/material.dart';

import '../../../../app/router.dart';
import '../../../../features/admin_posts/presentation/screens/client_admin_posts_screen.dart';
import '../../../../features/announcement/data/announcement_service.dart';
import '../../../../features/auth/data/auth_service.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  String? _announcementMessage;
  bool _loadingAnnouncement = false;

  @override
  void initState() {
    super.initState();
    _loadAnnouncement();
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

  Future<void> _openOrderCreate() async {
    final changed =
        await Navigator.pushNamed(context, AppRouter.clientCreateOrder);
    if (changed == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال طلب الصيانة')),
      );
    }
  }

  Future<void> _openOrders() async {
    await Navigator.pushNamed(context, AppRouter.clientOrders);
  }

  Future<void> _openAccount() async {
    await Navigator.pushNamed(context, AppRouter.clientAccount);
  }

  Future<void> _openChat() async {
    await Navigator.pushNamed(context, AppRouter.clientChat);
  }

  Future<void> _openAdminPosts() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ClientAdminPostsScreen()),
    );
  }

  Widget _announcementBanner() {
    final announcement = (_announcementMessage ?? '').trim();
    if (announcement.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
        ),
        boxShadow: const [
          BoxShadow(blurRadius: 12, color: Colors.black12),
        ],
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.campaign_outlined, color: Colors.white70),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              announcement,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الصفحة الرئيسية'),
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRouter.clientNotifications),
            icon: const Icon(Icons.notifications_none),
            tooltip: 'الإشعارات',
          ),
          IconButton(
            onPressed: _loadAnnouncement,
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_loadingAnnouncement)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(minHeight: 3),
            ),
          _announcementBanner(),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              ),
              boxShadow: const [
                BoxShadow(blurRadius: 12, color: Colors.black12),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'مرحبًا بك',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'كل خدماتك في مكان واحد',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'اطلب الصيانة، تابع الطلبات، راجع الحساب، وتابع الإشعارات بسهولة.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.08,
            children: [
              _MenuCard(
                icon: Icons.build_circle_outlined,
                title: 'طلب صيانة',
                subtitle: 'إنشاء طلب جديد',
                onTap: _openOrderCreate,
              ),
              _MenuCard(
                icon: Icons.receipt_long_outlined,
                title: 'طلباتي',
                subtitle: 'متابعة الحالة والتفاصيل',
                onTap: _openOrders,
              ),
              _MenuCard(
                icon: Icons.account_balance_wallet_outlined,
                title: 'حسابي',
                subtitle: 'الرصيد والمستحق',
                onTap: _openAccount,
              ),
              _MenuCard(
                icon: Icons.chat_bubble_outline,
                title: 'الشات',
                subtitle: 'تواصل مباشرة مع الإدارة',
                onTap: _openChat,
              ),
              _MenuCard(
                icon: Icons.campaign_outlined,
                title: 'إعلانات الإدارة',
                subtitle: 'عرض الصور والرسائل',
                onTap: _openAdminPosts,
              ),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            label: const Text('تسجيل خروج'),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: Theme.of(context).colorScheme.surface,
            boxShadow: const [
              BoxShadow(blurRadius: 10, color: Colors.black12),
            ],
            border: Border.all(color: color.withAlpha(45)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: color.withAlpha(28),
                  child: Icon(icon, color: color),
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodySmall?.color,
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
