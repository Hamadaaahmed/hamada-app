import 'package:flutter/material.dart';
import '../../../../app/router.dart';
import '../../../announcement/data/announcement_service.dart';
import '../../../admin_posts/presentation/screens/admin_posts_screen.dart';
import '../../data/admin_machines_service.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
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
    await AdminMachinesService().logout();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRouter.adminLogin,
      (route) => false,
    );
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
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تعذر تنفيذ العملية، حاول مرة أخرى'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _tile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                child: Icon(icon),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('الرئيسية - الأدمن'),
          actions: [
            IconButton(
              onPressed: _loadAnnouncement,
              icon: const Icon(Icons.refresh),
              tooltip: 'تحديث',
            ),
            IconButton(
              onPressed: () => _changePassword(context),
              icon: const Icon(Icons.lock_outline),
              tooltip: 'تغيير كلمة المرور',
            ),
            IconButton(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
              tooltip: 'تسجيل الخروج',
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _tile(
              context: context,
              icon: Icons.campaign_outlined,
              title: 'تنبيه الإدارة والإعلانات',
              subtitle: _loadingAnnouncement
                  ? 'جاري تحميل...'
                  : (((_announcementMessage ?? '').trim().isNotEmpty)
                      ? (_announcementMessage ?? '').trim()
                      : 'التنبيه العام + صور ورسائل المنتجات'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminPostsScreen()),
              ),
            ),
            _tile(
              context: context,
              icon: Icons.receipt_long,
              title: 'طلبات الصيانة',
              subtitle: 'عرض الطلبات وقبولها ورفضها وتحديد المواعيد',
              onTap: () => Navigator.pushNamed(context, AppRouter.adminOrders),
            ),
            _tile(
              context: context,
              icon: Icons.precision_manufacturing_outlined,
              title: 'المكن والتسعير',
              subtitle: 'إضافة الماكينات وتعديل الأسعار والترتيب',
              onTap: () => Navigator.pushNamed(context, AppRouter.adminMachines),
            ),
            _tile(
              context: context,
              icon: Icons.people_alt_outlined,
              title: 'حسابات العملاء',
              subtitle: 'من داخل أي طلب تقدر تفتح حساب العميل مباشرة',
              onTap: () => Navigator.pushNamed(context, AppRouter.adminClients),
            ),
            _tile(
              context: context,
              icon: Icons.badge_outlined,
              title: 'بيانات العملاء',
              subtitle: 'تعديل البريد الإلكتروني ورقم الهاتف للعميل',
              onTap: () =>
                  Navigator.pushNamed(context, AppRouter.adminClientProfiles),
            ),
            _tile(
              context: context,
              icon: Icons.chat_bubble_outline,
              title: 'الدردشة',
              subtitle: 'محادثات الأدمن مع العملاء داخل التطبيق',
              onTap: () => Navigator.pushNamed(context, AppRouter.adminChats),
            ),
          ],
        ),
      ),
    );
  }
}
