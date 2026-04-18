import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../app/client_bottom_nav.dart';
import '../../../../app/ui.dart';
import '../../data/client_account_service.dart';
import '../../data/client_orders_service.dart';

class ClientOrderCreateScreen extends StatefulWidget {
  const ClientOrderCreateScreen({super.key});

  @override
  State<ClientOrderCreateScreen> createState() =>
      _ClientOrderCreateScreenState();
}

class _ClientOrderCreateScreenState extends State<ClientOrderCreateScreen> {
  final _service = ClientOrdersService();
  final _accountService = ClientAccountService();
  final _phone = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  bool _locating = false;
  bool _phoneLocked = false;

  List<Map<String, dynamic>> _machines = [];
  final Map<int, int> _qty = {};

  double? _lat;
  double? _lng;
  double? _accuracyM;
  String? _locationError;
  bool _locationReady = false;

  @override
  void initState() {
    super.initState();
    _load();
    _startAutoLocation();
  }

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    try {
      final rows = await _service.listMachines();
      final account = await _accountService.getAccountSummary();
      if (!mounted) return;

      setState(() {
        _machines = rows;
        final savedPhone = (account['phone'] ?? '').toString().trim();
        if (savedPhone.isNotEmpty) {
          _phone.text = savedPhone;
          _phoneLocked = true;
        } else {
          _phone.clear();
          _phoneLocked = false;
        }
      });
    } catch (e) {
      if (!mounted) return;
      _snack('تعذر تحميل الخدمات، حاول مرة أخرى', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
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

  String _money(int cents) {
    final v = cents / 100.0;
    return v == v.roundToDouble()
        ? v.toStringAsFixed(0)
        : v.toStringAsFixed(2);
  }

  int _totalCents() {
    int total = 0;
    for (final m in _machines) {
      final id = m['id'] as int;
      final q = _qty[id] ?? 0;
      if (q > 0) {
        total += (m['price_cents'] as int) * q;
      }
    }
    return total;
  }



  Future<void> _startAutoLocation() async {
    if (_locating) return;

    const targetAccuracyM = 50.0;
    const maxAttempts = 10;

    if (mounted) {
      setState(() {
        _locating = true;
        _locationReady = false;
        _locationError = null;
      });
    }

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() {
          _locationReady = false;
          _locationError = 'خدمة الموقع متوقفة. فعّل GPS ثم اضغط إعادة تحديد الموقع.';
        });
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        setState(() {
          _locationReady = false;
          _locationError = 'تم رفض إذن الموقع. اسمح بالوصول للموقع ثم اضغط إعادة تحديد الموقع.';
        });
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _locationReady = false;
          _locationError =
              'تم رفض إذن الموقع نهائيًا. افتح إعدادات التطبيق ثم اسمح بالوصول للموقع.';
        });
        return;
      }

      for (var attempt = 1; mounted && attempt <= maxAttempts; attempt++) {
        try {
          final pos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.best,
            ),
          );

          if (!mounted) return;
          final ready = pos.accuracy <= targetAccuracyM;

          setState(() {
            _lat = pos.latitude;
            _lng = pos.longitude;
            _accuracyM = pos.accuracy;
            _locationReady = ready;
            _locationError = ready
                ? null
                : 'دقة الموقع الحالية ${pos.accuracy.toStringAsFixed(0)} متر. '
                    'انتظر حتى تصبح ${targetAccuracyM.toStringAsFixed(0)} متر أو أقل.';
          });

          if (ready) {
            break;
          }
        } catch (_) {
          if (!mounted) return;
          setState(() {
            _locationReady = false;
            _locationError =
                'تعذر تحديد الموقع الآن. تأكد من تشغيل GPS وحاول مرة أخرى.';
          });
        }

        if (attempt < maxAttempts) {
          await Future.delayed(const Duration(seconds: 2));
        }
      }

      if (mounted && !_locationReady) {
        setState(() {
          _locationError ??=
              'لم نصل إلى دقة كافية بعد. تحرك لمكان مفتوح ثم اضغط إعادة تحديد الموقع.';
        });
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<bool> _confirmSubmit() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تأكيد إرسال الطلب'),
        content: const Text(
          'هل أنت متواجد الآن في مكان الصيانة المطلوب؟\nسيتم إرسال طلب الصيانة اعتمادًا على موقعك الحالي.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('نعم، إرسال الطلب'),
          ),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _submit() async {
    final locationReady = _locationReady &&
        _lat != null &&
        _lng != null &&
        _accuracyM != null &&
        (_accuracyM ?? 9999) <= 50;
    final phone = _phone.text.trim();
    final items = _qty.entries
        .where((e) => e.value > 0)
        .map((e) => {'machine_id': e.key, 'qty': e.value})
        .toList();

    if (phone.length < 6) {
      _snack('اكتب رقم هاتف صحيح', error: true);
      return;
    }

    if (items.isEmpty) {
      _snack('اختر خدمة واحدة على الأقل', error: true);
      return;
    }

    if (!locationReady) {
      _snack(_locationError ?? 'انتظر تحديد الموقع بدقة للإرسال');
      return;
    }

    if (mounted) setState(() => _saving = true);
    try {
      final res = await _service.createOrder(
        phone: phone,
        lat: _lat,
        lng: _lng,
        accuracyM: _accuracyM,
        items: items,
      );

      if (!mounted) return;

      if (res['ok'] == true) {
        _snack('تم إرسال طلب الصيانة بنجاح');
        Navigator.pop(context, true);
      } else {
        final error = (res['error'] ?? 'فشل إرسال الطلب').toString();
        if (error == 'LOCATION_ACCURACY_TOO_HIGH') {
          _snack(
            'دقة الموقع أعلى من المسموح. المطلوب 50 متر أو أقل.',
            error: true,
          );
        } else if (error == 'CLIENT_BLOCKED') {
          _snack(
            'تم إيقاف حسابك مؤقتًا ولا يمكنك إنشاء طلب جديد. تواصل مع الإدارة.',
            error: true,
          );
        } else {
          _snack('تعذر إرسال الطلب، حاول مرة أخرى', error: true);
        }
      }
    } catch (e) {
      _snack('تعذر إرسال الطلب، حاول مرة أخرى', error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _totalCents();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final locationReady = _locationReady &&
        _lat != null &&
        _lng != null &&
        _accuracyM != null &&
        (_accuracyM ?? 9999) <= 50;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('طلب صيانة'),
        actions: const [],
      ),
      bottomNavigationBar: const ClientBottomNav(currentIndex: 2),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      160 + MediaQuery.of(context).viewPadding.bottom + 24,
                    ),
                    children: [
                      const AppHeroHeader(
                        title: 'طلب صيانة بنفس الخدمة الحالية',
                        subtitle: 'تم تحسين الشكل فقط مع الحفاظ على الاتصال بالسيرفر وكل خطوات الإرسال كما هي.',
                        icon: Icons.handyman_outlined,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        enabled: !_phoneLocked,
                        decoration: InputDecoration(
                          labelText: 'رقم الهاتف',
                          border: const OutlineInputBorder(),
                          enabledBorder: const OutlineInputBorder(),
                          disabledBorder: const OutlineInputBorder(),
                          filled: _phoneLocked,
                          suffixIcon: _phoneLocked
                              ? const Icon(Icons.lock_outline)
                              : null,
                          helperText: _phoneLocked
                              ? 'هذا الرقم محفوظ للحساب ولا يمكن تعديله'
                              : null,
                        ),
                        style: TextStyle(
                          color: _phoneLocked ? AppUiColors.muted : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_locating || !locationReady) ...[
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                            _locationError ?? 'انتظر تحديد الموقع بدقة للإرسال',
                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                              ],
                              const Text(
                                'الموقع',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (_locating)
                                const Text('جاري تحديد الموقع...')
                              else if (_locationError != null)
                                Text(
                                  _locationError!,
                                  style: const TextStyle(color: Colors.orange),
                                )
                              else
                                Text(
                                  'تم تحديد الموقع بدقة ${(_accuracyM ?? 0).toStringAsFixed(1)} متر',
                                  style: const TextStyle(color: Colors.green),
                                ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: _locating ? null : _startAutoLocation,
                                    icon: const Icon(Icons.my_location),
                                    label: const Text('إعادة تحديد الموقع'),
                                  ),
                                  if (_locationError != null)
                                    OutlinedButton.icon(
                                      onPressed: Geolocator.openAppSettings,
                                      icon: const Icon(Icons.settings_outlined),
                                      label: const Text('إعدادات التطبيق'),
                                    ),
                                  if (_locationError != null)
                                    OutlinedButton.icon(
                                      onPressed: Geolocator.openLocationSettings,
                                      icon: const Icon(Icons.gps_fixed),
                                      label: const Text('إعدادات الموقع'),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'اختر الخدمات المطلوبة',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ..._machines.map((m) {
                        final id = m['id'] as int;
                        final q = _qty[id] ?? 0;
                        return Card(
                          child: ListTile(
                            leading: Text(
                              m['icon'].toString(),
                              style: const TextStyle(fontSize: 24),
                            ),
                            title: Text(m['name'].toString()),
                            subtitle: Text(
                              'السعر: ${_money(m['price_cents'] as int)} جنيه',
                            ),
                            trailing: SizedBox(
                              width: 120,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    onPressed: () =>
                                        setState(() => _qty[id] = q + 1),
                                    icon: const Icon(Icons.add_circle_outline),
                                  ),
                                  Text('$q'),
                                  IconButton(
                                    onPressed: q <= 0
                                        ? null
                                        : () =>
                                            setState(() => _qty[id] = q - 1),
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
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
                SafeArea(
                  top: false,
                  child: AnimatedPadding(
                    duration: const Duration(milliseconds: 150),
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 12,
                      bottom: bottomInset > 0 ? 12 : 16,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 6,
                            color: Colors.black12,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'الإجمالي',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text('${_money(total)} جنيه'),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'تأكد أنك في موقع الصيانة الآن قبل الإرسال حتى يتم تحديد موقعك بدقة.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: (_saving || !locationReady)
                                  ? null
                                  : () async {
                                      final ok = await _confirmSubmit();
                                      if (!ok) return;
                                      await _submit();
                                    },
                              child: Text(
                                _saving
                                    ? 'جاري الإرسال...'
                                    : (locationReady
                                        ? 'إرسال الطلب'
                                        : 'فعّل الموقع بدقة 50م أو أقل'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
