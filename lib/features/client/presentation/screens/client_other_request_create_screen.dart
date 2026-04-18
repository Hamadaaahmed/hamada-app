import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../app/client_bottom_nav.dart';
import '../../../../app/ui.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/client_orders_service.dart';

class ClientOtherRequestCreateScreen extends StatefulWidget {
  final String requestKind;

  const ClientOtherRequestCreateScreen({
    super.key,
    required this.requestKind,
  });

  @override
  State<ClientOtherRequestCreateScreen> createState() =>
      _ClientOtherRequestCreateScreenState();
}

class _ClientOtherRequestCreateScreenState
    extends State<ClientOtherRequestCreateScreen> {
  final _service = ClientOrdersService();
  final _machineName = TextEditingController();
  final _faultDescription = TextEditingController();
  final _picker = ImagePicker();

  bool _saving = false;
  bool _locating = false;

  List<XFile> _referenceImages = [];
  List<XFile> _replacementImages = [];
  double? _lat;
  double? _lng;
  double? _accuracyM;
  String? _locationError;
  bool _locationReady = false;

  bool get _isSparePart => widget.requestKind == 'spare_part_request';

  @override
  void initState() {
    super.initState();
    _startAutoLocation();
  }

  @override
  void dispose() {
    _machineName.dispose();
    _faultDescription.dispose();
    super.dispose();
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red : null,
      ),
    );
  }

  Future<void> _pickReferenceImages() async {
    final files = await _picker.pickMultiImage(imageQuality: 82);
    if (!mounted || files.isEmpty) return;

    final merged = [..._referenceImages, ...files];
    final unique = <String, XFile>{};
    for (final file in merged) {
      unique[file.path] = file;
    }

    final result = unique.values.take(10).toList();

    setState(() => _referenceImages = result);

    if (merged.length > 10) {
      _snack('الحد الأقصى 10 صور');
    }
  }

  Future<void> _pickReplacementImages() async {
    final files = await _picker.pickMultiImage(imageQuality: 82);
    if (!mounted || files.isEmpty) return;

    final merged = [..._replacementImages, ...files];
    final unique = <String, XFile>{};
    for (final file in merged) {
      unique[file.path] = file;
    }

    final result = unique.values.take(10).toList();

    setState(() => _replacementImages = result);

    if (merged.length > 10) {
      _snack('الحد الأقصى 10 صور');
    }
  }

  void _removeReferenceImage(int index) {
    setState(() => _referenceImages.removeAt(index));
  }

  void _removeReplacementImage(int index) {
    setState(() => _replacementImages.removeAt(index));
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

  Future<void> _submit() async {
    final locationReady = _locationReady &&
        _lat != null &&
        _lng != null &&
        _accuracyM != null &&
        (_accuracyM ?? 9999) <= 50;
    final machineName = _machineName.text.trim();
    final faultDescription = _faultDescription.text.trim();

    if (machineName.isEmpty) {
      _snack(_isSparePart ? 'اكتب اسم قطعة الغيار' : 'اكتب اسم الماكينة',
          error: true);
      return;
    }

    if (faultDescription.isEmpty) {
      _snack(_isSparePart ? 'اكتب وصف القطعة المطلوبة' : 'اكتب وصف الطلب',
          error: true);
      return;
    }

    if (!locationReady) {
      _snack(_locationError ?? 'انتظر تحديد الموقع بدقة للإرسال');
      return;
    }

    if (mounted) setState(() => _saving = true);
    try {
      final res = _isSparePart
          ? await _service.createSparePartRequest(
              machineName: machineName,
              faultDescription: faultDescription,
              referenceImagePaths:
                  _referenceImages.map((e) => e.path).toList(),
              lat: _lat,
              lng: _lng,
              accuracyM: _accuracyM,
            )
          : await _service.createMachineRequest(
              machineName: machineName,
              faultDescription: faultDescription,
              referenceImagePaths:
                  _referenceImages.map((e) => e.path).toList(),
              replacementImagePaths:
                  _replacementImages.map((e) => e.path).toList(),
              lat: _lat,
              lng: _lng,
              accuracyM: _accuracyM,
            );

      if (!mounted) return;

      if (res['ok'] == true) {
        _snack('تم إرسال الطلب بنجاح');
        Navigator.pop(context, true);
      } else {
        final error = (res['error'] ?? 'فشل إرسال الطلب').toString();
        if (error == 'LOCATION_ACCURACY_TOO_HIGH') {
          _snack(
            'دقة الموقع أعلى من المسموح. المطلوب 50 متر أو أقل.',
            error: true,
          );
        } else if (error == 'PHONE_NOT_SET') {
          _snack(
            'رقم الهاتف غير محفوظ للحساب. تواصل مع الإدارة.',
            error: true,
          );
        } else {
          _snack('تعذر إرسال الطلب، حاول مرة أخرى', error: true);
        }
      }
    } catch (_) {
      _snack('تعذر إرسال الطلب، حاول مرة أخرى', error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _imagesPreview({
    required List<XFile> files,
    required VoidCallback onAdd,
    required void Function(int index) onRemove,
    required String buttonText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.image_outlined),
          label: Text(buttonText),
        ),
        const SizedBox(height: 8),
        Text('عدد الصور: ${files.length}/10'),
        if (files.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 108,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: files.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final file = files[i];
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(
                        File(file.path),
                        width: 108,
                        height: 108,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: InkWell(
                        onTap: () => onRemove(i),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSparePart ? 'طلب قطع غيار' : 'طلب مكن غير موجود'),
        actions: const [],
      ),
      bottomNavigationBar: const ClientBottomNav(currentIndex: 3),
      body: SafeArea(
        bottom: true,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            24 + MediaQuery.of(context).viewPadding.bottom,
          ),
        children: [
          AppHeroHeader(
            title: _isSparePart ? 'طلب قطع غيار' : 'طلب مكن غير موجود',
            subtitle: _isSparePart
                ? 'نفس خطوات الإرسال الحالية مع شكل أوضح للحقول والصور.'
                : 'إرسال الطلب بالموقع والصور بدون تغيير أي وظيفة موجودة.',
            icon: _isSparePart ? Icons.extension_outlined : Icons.precision_manufacturing_outlined,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _machineName,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: _isSparePart ? 'اسم قطعة الغيار' : 'اسم الماكينة',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _faultDescription,
            minLines: 4,
            maxLines: 6,
            decoration: InputDecoration(
              labelText: _isSparePart ? 'وصف القطعة المطلوبة' : 'وصف الطلب',
              border: const OutlineInputBorder(),
              alignLabelWithHint: true,
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
                    Row(
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(_locationError ?? 'جاري تحديد الموقع...'),
                        ),
                      ],
                    )
                  else if (_locationError != null)
                    Text(
                      _locationError!,
                      style: const TextStyle(color: Colors.orange),
                    )
                  else if (_accuracyM != null)
                    Text(
                      'تم تحديد الموقع بدقة ${_accuracyM!.toStringAsFixed(1)} متر',
                      style: const TextStyle(color: Colors.green),
                    )
                  else
                    const Text('لم يتم تحديد الموقع بعد'),
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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isSparePart
                        ? 'صور قطعة الغيار المطلوبة'
                        : 'صور المكنة المطلوبة',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _imagesPreview(
                    files: _referenceImages,
                    onAdd: _pickReferenceImages,
                    onRemove: _removeReferenceImage,
                    buttonText: _referenceImages.isEmpty
                        ? 'اختيار الصور'
                        : 'إضافة أو تغيير الصور',
                  ),
                ],
              ),
            ),
          ),
          if (!_isSparePart) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'صور المكنة القديمة للاستبدال',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _imagesPreview(
                      files: _replacementImages,
                      onAdd: _pickReplacementImages,
                      onRemove: _removeReplacementImage,
                      buttonText: _replacementImages.isEmpty
                          ? 'اختيار صور الاستبدال'
                          : 'إضافة أو تغيير صور الاستبدال',
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: (_saving || !_locationReady) ? null : _submit,
              icon: const Icon(Icons.send_outlined),
              label: Text(_saving ? 'جاري الإرسال...' : 'إرسال الطلب'),
            ),
          ),
        ],
        ),
      ),
    );
  }
}
