import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

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

  @override
  void initState() {
    super.initState();
    _load();
    _ensureLocation();
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

  Future<void> _ensureLocation() async {
    if (mounted) {
      setState(() {
        _locating = true;
        _locationError = null;
      });
    }

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() {
          _locationError =
              'خدمة الموقع غير مفعلة. فعّل GPS ثم حدّث الموقع.';
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
          _locationError =
              'تم رفض إذن الموقع. اسمح بالموقع ثم أعد المحاولة.';
        });
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _locationError =
              'إذن الموقع مرفوض نهائيًا. فعّله من إعدادات التطبيق.';
        });
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      );

      if (!mounted) return;
      setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;
        _accuracyM = pos.accuracy;

        if ((_accuracyM ?? 9999) > 30) {
          _locationError =
              'دقة الموقع الحالية ${(_accuracyM ?? 0).toStringAsFixed(1)} متر. المطلوب 30 متر أو أقل.';
        } else {
          _locationError = null;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _locationError = 'تعذر تحديد الموقع، حاول مرة أخرى';
      });
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

    if (_lat == null || _lng == null || _accuracyM == null) {
      _snack('لا يمكن الإرسال بدون تحديد الموقع أولًا', error: true);
      return;
    }

    if ((_accuracyM ?? 9999) > 30) {
      _snack(
        'لا يمكن الإرسال إلا إذا كانت دقة الموقع 30 متر أو أقل',
        error: true,
      );
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
            'دقة الموقع أعلى من المسموح. المطلوب 30 متر أو أقل.',
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
    final locationReady = _lat != null &&
        _lng != null &&
        _accuracyM != null &&
        (_accuracyM ?? 9999) <= 30;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('طلب صيانة'),
        actions: [
          IconButton(
            onPressed: _locating ? null : _ensureLocation,
            icon: const Icon(Icons.my_location),
            tooltip: 'تحديث الموقع',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 160),
                    children: [
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
                          color: _phoneLocked ? Colors.white70 : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                  style: const TextStyle(color: Colors.red),
                                )
                              else
                                Text(
                                  'تم تحديد الموقع بنجاح\nالدقة: ${(_accuracyM ?? 0).toStringAsFixed(1)} متر',
                                ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: OutlinedButton.icon(
                                  onPressed: _locating ? null : _ensureLocation,
                                  icon: const Icon(Icons.my_location),
                                  label: const Text('تحديث الموقع'),
                                ),
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
                      const SizedBox(height: 12),
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
                                        : 'فعّل الموقع بدقة 30م أو أقل'),
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
