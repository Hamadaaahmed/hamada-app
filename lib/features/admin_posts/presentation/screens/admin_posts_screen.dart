import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../config/app_config.dart';
import '../../../announcement/data/announcement_service.dart';
import '../../data/admin_posts_service.dart';

class AdminPostsScreen extends StatefulWidget {
  const AdminPostsScreen({super.key});

  @override
  State<AdminPostsScreen> createState() => _AdminPostsScreenState();
}

class _AdminPostsScreenState extends State<AdminPostsScreen> {
  final _postsService = AdminPostsService();
  final _announcementService = AnnouncementService();

  bool _loading = true;
  String? _announcementMessage;
  List<Map<String, dynamic>> _posts = const [];

  String _absoluteUrl(String? raw) {
    final value = (raw ?? '').trim();
    if (value.isEmpty) return '';
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    var baseUrl = AppConfig.apiBaseUrl;
    if (baseUrl.endsWith('/api')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 4);
    }
    return '$baseUrl$value';
  }

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);

    try {
      final ann = await _announcementService.getAnnouncement();
      final posts = await _postsService.listAdminPosts();
      if (!mounted) return;

      final raw = ann['announcement'];
      setState(() {
        _announcementMessage =
            raw is Map ? (raw['message'] ?? '').toString() : null;
        _posts = posts;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _editAnnouncement() async {
    final ctrl = TextEditingController(text: _announcementMessage ?? '');

    final action = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تنبيه الإدارة'),
        content: TextField(
          controller: ctrl,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'اكتب آخر تنبيه فقط',
          ),
        ),
        actions: [
          if ((_announcementMessage ?? '').trim().isNotEmpty)
            TextButton(
              onPressed: () => Navigator.pop(context, 'clear'),
              child: const Text('مسح'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'cancel'),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 'save'),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    if (!mounted || action == null || action == 'cancel') return;

    try {
      if (action == 'clear') {
        final res = await _announcementService.clearAnnouncement();
        if (!mounted) return;

        if (res['ok'] == true) {
          setState(() => _announcementMessage = null);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم مسح تنبيه الإدارة')),
          );
        }
        return;
      }

      final text = ctrl.text.trim();
      if (text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('اكتب التنبيه أولًا')),
        );
        return;
      }

      final res = await _announcementService.setAnnouncement(text);
      if (!mounted) return;

      if (res['ok'] == true) {
        setState(() => _announcementMessage = text);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ تنبيه الإدارة')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر تنفيذ العملية، حاول مرة أخرى')),
      );
    }
  }

  Future<void> _addPost() async {
    final picker = ImagePicker();
    final msgCtrl = TextEditingController();
    XFile? picked;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setLocal) {
          return AlertDialog(
            title: const Text('إعلان جديد'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: msgCtrl,
                    maxLines: 3,
                    onChanged: (_) => setLocal(() {}),
                    decoration: const InputDecoration(
                      labelText: 'الرسالة',
                      hintText: 'مثال: بسم الله الرحمن الرحيم',
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final file = await picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 82,
                      );
                      if (file == null) return;
                      setLocal(() => picked = file);
                    },
                    icon: const Icon(Icons.image_outlined),
                    label: Text(
                      picked == null ? 'اختيار صورة' : 'تم اختيار صورة',
                    ),
                  ),
                  if (picked != null) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        height: 190,
                        width: double.infinity,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              File(picked!.path),
                              fit: BoxFit.cover,
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.transparent,
                                    Color(0x66000000),
                                    Color(0xCC000000),
                                  ],
                                ),
                              ),
                            ),
                            if (msgCtrl.text.trim().isNotEmpty)
                              Positioned(
                                right: 12,
                                left: 12,
                                bottom: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withAlpha(145),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    msgCtrl.text.trim(),
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('إلغاء'),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.add),
                label: const Text('رفع'),
              ),
            ],
          );
        },
      ),
    );

    if (ok != true) return;

    final message = msgCtrl.text.trim();
    final imagePath = picked?.path;

    if (message.isEmpty && (imagePath ?? '').isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اكتب رسالة أو اختر صورة')),
      );
      return;
    }

    try {
      final res = await _postsService.createPost(
        message: message,
        imagePath: imagePath,
      );
      if (!mounted) return;

      if (res['ok'] == true) {
        await _refresh();
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم رفع الإعلان')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text((res['error'] ?? 'فشل رفع الإعلان').toString()),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر تنفيذ العملية، حاول مرة أخرى')),
      );
    }
  }

  Future<void> _deletePost(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف الإعلان'),
        content: const Text('سيتم حذف الصورة من السيرفر نهائيًا.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      final res = await _postsService.deletePost(id);
      if (!mounted) return;

      if (res['ok'] == true) {
        await _refresh();
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف الإعلان والصورة من السيرفر')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text((res['error'] ?? 'فشل الحذف').toString()),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر تنفيذ العملية، حاول مرة أخرى')),
      );
    }
  }

  Widget _announcementCard() {
    final text = (_announcementMessage ?? '').trim();

    return Card(
      child: ListTile(
        leading: const Icon(Icons.campaign_outlined),
        title: const Text('تنبيه الإدارة'),
        subtitle: Text(text.isEmpty ? 'لا يوجد تنبيه حاليًا' : text),
        trailing: const Icon(Icons.edit_outlined),
        onTap: _editAnnouncement,
      ),
    );
  }

  Widget _postCard(Map<String, dynamic> post) {
    final imageUrl = _absoluteUrl(post['image_url']?.toString());
    final message = (post['message'] ?? '').toString().trim();

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (imageUrl.isNotEmpty)
            AspectRatio(
              aspectRatio: 1.5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(Icons.broken_image_outlined, size: 42),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          Color(0x55000000),
                          Color(0xCC000000),
                        ],
                      ),
                    ),
                  ),
                  if (message.isNotEmpty)
                    Positioned(
                      right: 12,
                      left: 12,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(145),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          message,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(message),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => _deletePost(post['id'] as int),
                icon: const Icon(Icons.delete_outline),
                label: const Text('حذف'),
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
        title: const Text('تنبيه الإدارة والإعلانات'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPost,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _announcementCard(),
                const SizedBox(height: 12),
                const Text(
                  'إعلانات الإدارة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (_posts.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('لا توجد إعلانات حالية'),
                    ),
                  )
                else
                  ..._posts.map(_postCard),
              ],
            ),
    );
  }
}
