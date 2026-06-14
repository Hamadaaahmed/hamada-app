
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/contact_name_text.dart';
import '../../../../core/phone_dialer.dart';
import '../../data/admin_other_requests_service.dart';
import '../../../other_requests/models/other_request_model.dart';

class AdminOtherRequestDetailsScreen extends StatefulWidget {
  final int requestId;

  const AdminOtherRequestDetailsScreen({
    super.key,
    required this.requestId,
  });

  @override
  State<AdminOtherRequestDetailsScreen> createState() =>
      _AdminOtherRequestDetailsScreenState();
}

class _AdminOtherRequestDetailsScreenState
    extends State<AdminOtherRequestDetailsScreen> {
  final _service = AdminOtherRequestsService();

  bool _loading = true;
  OtherRequestModel? _request;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red : null,
      ),
    );
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    try {
      final data = await _service.getRequestModel(widget.requestId);
      if (!mounted) return;
      setState(() => _request = data);
    } catch (e) {
      if (!mounted) return;
      _snack(_service.mapError(e), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool get _isSpare => _request?.isSparePart == true;

  String _typeText() => _isSpare ? 'طلب قطع غيار' : 'طلب مكن';

  String _statusText(String status) {
    switch (status) {
      case 'pending':
        return 'معلق';
      case 'quoted':
        return 'تم التسعير';
      case 'price_accepted':
        return 'وافق العميل على السعر';
      case 'price_rejected':
        return 'رفض العميل السعر';
      case 'scheduled':
        return 'تم تحديد موعد';
      case 'unavailable':
        return 'غير متوفر حاليًا';
      case 'completed':
        return 'مكتمل';
      default:
        return status;
    }
  }

  String _money(int cents) {
    final v = cents / 100.0;
    return v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
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


  List<String> _referenceImages(OtherRequestModel row) => row.imageUrls;

  List<String> _replacementImages(OtherRequestModel row) => row.replacementImageUrls;

  Future<String?> _askText({
    required String title,
    required String label,
    String initial = '',
    bool multiline = false,
  }) async {
    final ctrl = TextEditingController(text: initial);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: ctrl,
          minLines: multiline ? 3 : 1,
          maxLines: multiline ? 5 : 1,
          keyboardType:
              multiline ? TextInputType.multiline : TextInputType.text,
          decoration: InputDecoration(labelText: label),
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
    if (ok != true) return null;
    return ctrl.text.trim();
  }

  Future<void> _quote() async {
    final priceText = await _askText(
      title: 'تسعير الطلب',
      label: 'السعر بالجنيه',
    );
    if (priceText == null || priceText.isEmpty) return;

    final pounds = double.tryParse(priceText.replaceAll(',', '.'));
    if (pounds == null || pounds <= 0) {
      _snack('اكتب سعرًا صحيحًا', error: true);
      return;
    }

    final note = await _askText(
      title: 'ملاحظة الأدمن',
      label: 'ملاحظة (اختياري)',
    );

    try {
      final data = await _service.quoteRequest(
        id: widget.requestId,
        quotedPriceCents: (pounds * 100).round(),
        adminNote: note,
      );
      if (!mounted) return;
      if (data['ok'] == true) {
        _snack('تم تسعير الطلب');
        _load();
      } else {
        _snack(
          (data['error'] ?? 'فشل تسعير الطلب').toString(),
          error: true,
        );
      }
    } catch (e) {
      _snack(_service.mapError(e), error: true);
    }
  }

  Future<void> _markUnavailable() async {
    final note = await _askText(
      title: 'غير متوفر حاليًا',
      label: 'ملاحظة (اختياري)',
    );

    try {
      final data = await _service.markUnavailable(
        id: widget.requestId,
        adminNote: note,
      );
      if (!mounted) return;
      if (data['ok'] == true) {
        _snack('تم تحديث الطلب إلى غير متوفر حاليًا');
        _load();
      } else {
        _snack(
          (data['error'] ?? 'فشل تنفيذ العملية').toString(),
          error: true,
        );
      }
    } catch (e) {
      _snack(_service.mapError(e), error: true);
    }
  }

  Future<void> _schedule() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: DateTime.now(),
    );
    if (date == null) return;
    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    final dt = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    final note = await _askText(
      title: 'ملاحظة الأدمن',
      label: 'ملاحظة (اختياري)',
    );

    try {
      final data = await _service.scheduleRequest(
        id: widget.requestId,
        scheduledAtIso: dt.toIso8601String(),
        adminNote: note,
      );
      if (!mounted) return;
      if (data['ok'] == true) {
        _snack('تم تحديد موعد');
        _load();
      } else {
        _snack(
          (data['error'] ?? 'فشل تحديد الموعد').toString(),
          error: true,
        );
      }
    } catch (e) {
      _snack(_service.mapError(e), error: true);
    }
  }

  Future<void> _complete() async {
    final note = await _askText(
      title: 'إنهاء الطلب',
      label: 'ملاحظة (اختياري)',
    );

    try {
      final data = await _service.completeRequest(
        id: widget.requestId,
        adminNote: note,
      );
      if (!mounted) return;
      if (data['ok'] == true) {
        _snack('تم إنهاء الطلب');
        _load();
      } else {
        _snack(
          (data['error'] ?? 'فشل إنهاء الطلب').toString(),
          error: true,
        );
      }
    } catch (e) {
      _snack(_service.mapError(e), error: true);
    }
  }

  Future<void> _openMap() async {
    final row = _request;
    if (row == null) return;

    final lat = row.lat;
    final lng = row.lng;
    if (lat == null || lng == null) {
      _snack('لا يوجد موقع محفوظ', error: true);
      return;
    }

    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _snack('تعذر فتح الخرائط', error: true);
    }
  }

  Widget _row(String label, String value, {Widget? child}) {
    if (value.trim().isEmpty && child == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: child ?? Text(value)),
        ],
      ),
    );
  }

  void _openImagesViewer(List<String> images, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ImagesViewerScreen(
          images: images,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  Widget _imagesSection(String title, List<String> images) {
    if (images.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title (${images.length})',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'اضغط على أي صورة لفتحها',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 116,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final url = images[i];
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _openImagesViewer(images, i),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          url,
                          width: 116,
                          height: 116,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 116,
                            height: 116,
                            alignment: Alignment.center,
                            color: Colors.black12,
                            child: const Text('تعذر التحميل'),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(150),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${i + 1}/${images.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final row = _request;
    final status = row?.status ?? '';

    final canQuote = status == 'pending' || status == 'quoted';
    final canUnavailable = ['pending', 'quoted', 'price_accepted'].contains(status);
    final canSchedule = status == 'price_accepted';
    final canComplete = status == 'scheduled';
    final referenceImages = row == null ? <String>[] : _referenceImages(row);
    final replacementImages = row == null ? <String>[] : _replacementImages(row);

    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل الطلب #${widget.requestId}'),
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : row == null
              ? const Center(child: Text('الطلب غير موجود'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _row('نوع الطلب', _typeText()),
                    _row(
                      'العميل',
                      row.phone,
                      child: row.phone.trim().isEmpty
                          ? null
                          : InkWell(
                              onTap: () =>
                                  PhoneDialer.openDialer(row.phone),
                              child: ContactNameText(
                                phone: row.phone,
                                fallbackPrefix: null,
                                style: const TextStyle(
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                    ),
                    _row(
                      'الهاتف',
                      row.phone,
                      child: InkWell(
                        onTap: () =>
                            PhoneDialer.openDialer(row.phone),
                        child: ContactNameText(
                          phone: row.phone,
                          fallbackPrefix: null,
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    _row(
                      _isSpare ? 'اسم قطعة الغيار' : 'اسم الماكينة',
                      row.machineName,
                    ),
                    _row('الحالة', _statusText(status)),
                    _row(
                      'السعر المسعّر',
                      '${_money(row.quotedPriceCents)} جنيه',
                    ),
                    _row(
                      _isSpare ? 'وصف القطعة المطلوبة' : 'التفاصيل',
                      row.faultDescription,
                    ),
                    _row(
                      'ملاحظة الأدمن',
                      row.adminNote,
                    ),
                    _row('السبب', row.rejectReason),
                    _row(
                      'وقت الإنشاء',
                      _fmtDate(row.createdAt),
                    ),
                    _row(
                      'آخر تحديث',
                      _fmtDate(row.updatedAt),
                    ),
                    _row(
                      'الموعد',
                      _fmtDate(row.scheduledAt),
                    ),
                    _row(
                      'وقت الإنهاء',
                      _fmtDate(row.completedAt),
                    ),
                    _imagesSection(
                      _isSpare ? 'صور قطعة الغيار' : 'صور المكنة المطلوبة',
                      referenceImages,
                    ),
                    if (!_isSpare)
                      _imagesSection(
                        'صور المكنة القديمة للاستبدال',
                        replacementImages,
                      ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 46,
                      child: OutlinedButton.icon(
                        onPressed: _openMap,
                        icon: const Icon(Icons.location_on_outlined),
                        label: const Text('فتح الموقع على الخرائط'),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        if (canQuote)
                          ElevatedButton.icon(
                            onPressed: _quote,
                            icon: const Icon(Icons.sell_outlined),
                            label: const Text('تسعير'),
                          ),
                        if (canUnavailable)
                          ElevatedButton.icon(
                            onPressed: _markUnavailable,
                            icon: const Icon(Icons.remove_shopping_cart_outlined),
                            label: const Text('غير متوفر حاليًا'),
                          ),
                        if (canSchedule)
                          ElevatedButton.icon(
                            onPressed: _schedule,
                            icon: const Icon(Icons.event_available_outlined),
                            label: const Text('تحديد موعد'),
                          ),
                        if (canComplete)
                          ElevatedButton.icon(
                            onPressed: _complete,
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('إنهاء'),
                          ),
                      ],
                    ),
                  ],
                ),
    );
  }
}

class _ImagesViewerScreen extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _ImagesViewerScreen({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_ImagesViewerScreen> createState() => _ImagesViewerScreenState();
}

class _ImagesViewerScreenState extends State<_ImagesViewerScreen> {
  late final PageController _controller;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_current + 1} / ${widget.images.length}'),
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) {
              return Center(
                child: _DoubleTapZoomNetworkImage(url: widget.images[i]),
              );
            },
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(150),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'اسحب للتنقل • دبل كليك للتكبير',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DoubleTapZoomNetworkImage extends StatefulWidget {
  final String url;

  const _DoubleTapZoomNetworkImage({required this.url});

  @override
  State<_DoubleTapZoomNetworkImage> createState() =>
      _DoubleTapZoomNetworkImageState();
}

class _DoubleTapZoomNetworkImageState
    extends State<_DoubleTapZoomNetworkImage> {
  final TransformationController _controller = TransformationController();

  void _onDoubleTap() {
    final isZoomed = _controller.value != Matrix4.identity();
    if (isZoomed) {
      _controller.value = Matrix4.identity();
    } else {
      _controller.value = Matrix4.diagonal3Values(2.5, 2.5, 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _onDoubleTap,
      child: InteractiveViewer(
        transformationController: _controller,
        minScale: 1,
        maxScale: 4,
        child: Image.network(
          widget.url,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) =>
              const Center(child: Text('تعذر تحميل الصورة')),
        ),
      ),
    );
  }
}
