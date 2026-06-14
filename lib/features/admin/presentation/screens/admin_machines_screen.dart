import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../app/router.dart';
import '../../data/admin_machines_service.dart';

class AdminMachinesScreen extends StatefulWidget {
  const AdminMachinesScreen({super.key});

  @override
  State<AdminMachinesScreen> createState() => _AdminMachinesScreenState();
}

class _AdminMachinesScreenState extends State<AdminMachinesScreen> {
  final _service = AdminMachinesService();

  bool _loading = true;
  List<Map<String, dynamic>> _machines = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() => _loading = true);
    }

    try {
      final rows = await _service.listMachines();
      if (!mounted) return;
      setState(() => _machines = rows);
    } catch (_) {
      if (!mounted) return;
      _snack('تعذر تحميل المكن، حاول مرة أخرى', error: true);
    } finally {
      if (mounted) {
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

  int _toCents(String input) {
    final value = double.tryParse(input.trim().replaceAll(',', '.')) ?? 0;
    return (value * 100).round();
  }

  String _fromCents(dynamic cents) {
    final v = ((cents as num?)?.toDouble() ?? 0) / 100.0;
    return v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
  }

  Map<String, dynamic> _normalizeMachine(Map raw) {
    return {
      'id': int.tryParse('${raw['id']}') ?? 0,
      'name': (raw['name'] ?? '').toString(),
      'icon': (raw['icon'] ?? '🧵').toString(),
      'price_cents': int.tryParse('${raw['price_cents']}') ?? 0,
      'active':
          raw['active'] == true || '${raw['active']}'.toLowerCase() == 'true',
      'sort_order': int.tryParse('${raw['sort_order']}') ?? 0,
    };
  }

  Future<void> _changePassword() async {
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
      _snack('كلمة المرور الجديدة يجب ألا تقل عن 8 أحرف', error: true);
      return;
    }

    if (newPassword != confirmPassword) {
      _snack('تأكيد كلمة المرور غير مطابق', error: true);
      return;
    }

    try {
      final data = await _service.changeAdminPassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      if (data['ok'] == true) {
        _snack('تم تغيير كلمة المرور بنجاح');
      } else {
        _snack(
          (data['error'] ?? 'فشل تغيير كلمة المرور').toString(),
          error: true,
        );
      }
    } catch (_) {
      _snack('تعذر تنفيذ العملية، حاول مرة أخرى', error: true);
    }
  }

  Future<void> _deleteMachine(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف الماكينة'),
        content: const Text(
          'هل أنت متأكد؟ إذا كانت الماكينة مستخدمة في طلبات قديمة فسيتم تعطيلها بدل حذفها.',
        ),
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

    if (confirm != true) return;

    try {
      final data = await _service.deleteMachine(id);
      if (data['ok'] == true) {
        if (data['deleted'] == true) {
          _snack('تم حذف الماكينة بنجاح');
        } else if (data['deactivated'] == true) {
          _snack('الماكينة مرتبطة بطلبات قديمة، تم تعطيلها بدل حذفها');
        } else {
          _snack('تم تنفيذ العملية بنجاح');
        }
        await _load();
      } else {
        _snack(
          (data['error'] ?? 'فشل حذف الماكينة').toString(),
          error: true,
        );
      }
    } catch (_) {
      _snack('تعذر تنفيذ العملية، حاول مرة أخرى', error: true);
    }
  }

  Future<void> _openForm({Map<String, dynamic>? item}) async {
    final editing = item != null;
    final nameCtrl =
        TextEditingController(text: (item?['name'] ?? '').toString());
    final iconCtrl =
        TextEditingController(text: (item?['icon'] ?? '🧵').toString());
    final priceCtrl =
        TextEditingController(text: _fromCents(item?['price_cents']));
    final sortCtrl =
        TextEditingController(text: (item?['sort_order'] ?? 0).toString());

    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(editing ? 'تعديل ماكينة' : 'إضافة ماكينة'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'اسم الماكينة'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: iconCtrl,
                decoration: const InputDecoration(labelText: 'الأيقونة'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'السعر بالجنيه'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: sortCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'ترتيب الظهور'),
              ),
            ],
          ),
        ),
        actions: [
          if (editing)
            TextButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop(false);
                _deleteMachine(item['id'] as int);
              },
              child: const Text('حذف'),
            ),
          TextButton(
            onPressed: () =>
                Navigator.of(context, rootNavigator: true).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.of(context, rootNavigator: true).pop(true),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final name = nameCtrl.text.trim();
    final icon = iconCtrl.text.trim().isEmpty ? '🧵' : iconCtrl.text.trim();
    final priceCents = _toCents(priceCtrl.text);
    final sortOrder = int.tryParse(sortCtrl.text.trim()) ?? 0;

    if (name.isEmpty) {
      _snack('اكتب اسم الماكينة', error: true);
      return;
    }

    try {
      if (editing) {
        final data = await _service.updateMachine(
          id: item['id'] as int,
          name: name,
          icon: icon,
          priceCents: priceCents,
          sortOrder: sortOrder,
        );
        if (data['ok'] == true) {
          _snack('تم تعديل الماكينة بنجاح');
          await _load();
        } else {
          _snack((data['error'] ?? 'فشل التعديل').toString(), error: true);
        }
      } else {
        final data = await _service.createMachine(
          name: name,
          icon: icon,
          priceCents: priceCents,
          sortOrder: sortOrder,
        );
        if (data['ok'] == true) {
          _snack('تمت إضافة الماكينة بنجاح');
          await _load();
        } else {
          _snack((data['error'] ?? 'فشل الإضافة').toString(), error: true);
        }
      }
    } on DioException catch (e) {
      final body = e.response?.data;
      if (e.response?.statusCode == 409 &&
          body is Map &&
          body['error'] == 'DUPLICATE_MACHINE') {
        _snack('هذه الماكينة موجودة بالفعل أو يوجد اسم مشابه لها', error: true);
      } else {
        _snack('تعذر تنفيذ العملية، حاول مرة أخرى', error: true);
      }
    } catch (_) {
      _snack('تعذر تنفيذ العملية، حاول مرة أخرى', error: true);
    }
  }

  Future<void> _toggle(int id) async {
    try {
      final data = await _service.toggleMachine(id);
      if (data['ok'] == true && data['machine'] is Map) {
        final updated = _normalizeMachine(data['machine'] as Map);

        if (!mounted) return;
        setState(() {
          _machines = _machines.map((m) {
            if ((m['id'] as int) == (updated['id'] as int)) {
              return updated;
            }
            return m;
          }).toList();
        });

        final active = updated['active'] == true;
        _snack(active ? 'تمت إعادة إظهار الماكينة' : 'تم إخفاء الماكينة');
      } else {
        _snack(
          (data['error'] ?? 'فشل تحديث الحالة').toString(),
          error: true,
        );
      }
    } catch (_) {
      _snack('تعذر تنفيذ العملية، حاول مرة أخرى', error: true);
    }
  }

  Future<bool> _handleBack() async {
    if (!mounted) return false;

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return false;
    }

    Navigator.pushReplacementNamed(context, AppRouter.adminHome);
    return false;
  }

  Future<void> _logout() async {
    await AdminMachinesService().logout();
    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRouter.adminLogin,
      (route) => false,
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_machines.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد مكن بعد',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 8, bottom: 100),
        itemCount: _machines.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final item = _machines[i];
          final active = item['active'] == true;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: Text(
                (item['icon'] ?? '🧵').toString(),
                style: const TextStyle(fontSize: 24),
              ),
              title: Text(
                (item['name'] ?? '').toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'السعر: ${_fromCents(item['price_cents'])} جنيه\n'
                  'الترتيب: ${(item['sort_order'] ?? 0)}\n'
                  'الحالة: ${active ? "مفعلة" : "معطلة"}',
                ),
              ),
              isThreeLine: true,
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => _openForm(item: item),
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'تعديل',
                  ),
                  IconButton(
                    onPressed: () => _toggle(item['id'] as int),
                    icon: Icon(
                      active ? Icons.visibility_off : Icons.visibility,
                    ),
                    tooltip: active ? 'إخفاء' : 'إظهار',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBack();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المكن والتسعير'),
          actions: [
            IconButton(
              onPressed: _changePassword,
              icon: const Icon(Icons.lock_outline),
              tooltip: 'تغيير كلمة المرور',
            ),
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRouter.adminOrders);
              },
              icon: const Icon(Icons.receipt_long),
              tooltip: 'طلبات الصيانة',
            ),
            IconButton(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              tooltip: 'تحديث',
            ),
            IconButton(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              tooltip: 'تسجيل خروج',
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _openForm(),
          child: const Icon(Icons.add),
        ),
        body: _buildBody(),
      ),
    );
  }
}
