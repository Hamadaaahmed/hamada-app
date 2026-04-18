
import 'package:flutter/material.dart';

import '../../data/client_orders_service.dart';
import '../../../other_requests/models/other_request_model.dart';

class ClientOtherRequestDetailsScreen extends StatefulWidget {
  final int requestId;

  const ClientOtherRequestDetailsScreen({
    super.key,
    required this.requestId,
  });

  @override
  State<ClientOtherRequestDetailsScreen> createState() =>
      _ClientOtherRequestDetailsScreenState();
}

class _ClientOtherRequestDetailsScreenState
    extends State<ClientOtherRequestDetailsScreen> {
  final _service = ClientOrdersService();

  bool _loading = true;
  bool _submitting = false;
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
      final data = await _service.getMyOtherRequestModel(widget.requestId);
      if (!mounted) return;
      setState(() {
        _request = data;
      });
    } catch (_) {
      if (!mounted) return;
      _snack('تعذر تحميل تفاصيل الطلب', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool get _isSpare => _request?.isSparePart == true;

  String _requestKindText(String kind) {
    switch (kind) {
      case 'spare_part_request':
        return 'طلب قطع غيار';
      case 'machine_request':
      default:
        return 'طلب مكن';
    }
  }

  String _statusText(String status) {
    switch (status) {
      case 'pending':
        return 'معلق';
      case 'quoted':
        return 'بانتظار موافقتك على السعر';
      case 'price_accepted':
        return 'تمت موافقتك على السعر';
      case 'price_rejected':
        return 'تم رفض السعر';
      case 'scheduled':
        return 'تم تحديد موعد';
      case 'unavailable':
        return 'غير متوفر حاليًا';
      case 'rejected':
        return 'مرفوض';
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

  Widget _row(String label, String value) {
    if (value.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _acceptQuote() async {
    if (mounted) setState(() => _submitting = true);
    try {
      final res = await _service.acceptOtherRequestQuote(widget.requestId);
      if (!mounted) return;
      if (res['ok'] == true) {
        _snack('تمت الموافقة على السعر');
        await _load();
      } else {
        _snack(
          (res['error'] ?? 'تعذر تنفيذ العملية').toString(),
          error: true,
        );
      }
    } catch (_) {
      if (!mounted) return;
      _snack('تعذر تنفيذ العملية', error: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _rejectQuote() async {
    if (mounted) setState(() => _submitting = true);
    try {
      final res = await _service.rejectOtherRequestQuote(widget.requestId);
      if (!mounted) return;
      if (res['ok'] == true) {
        _snack('تم رفض السعر');
        await _load();
      } else {
        _snack(
          (res['error'] ?? 'تعذر تنفيذ العملية').toString(),
          error: true,
        );
      }
    } catch (_) {
      if (!mounted) return;
      _snack('تعذر تنفيذ العملية', error: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
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
    final canRespondToQuote = status == 'quoted';
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
                    _row(
                      'نوع الطلب',
                      _requestKindText(row.requestKind),
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
                      _isSpare ? 'وصف القطعة المطلوبة' : 'وصف الطلب',
                      row.faultDescription,
                    ),
                    _row(
                      'ملاحظات الإدارة',
                      row.adminNote,
                    ),
                    _row('سبب الرفض', row.rejectReason),
                    _row(
                      'وقت الإنشاء',
                      _fmtDate(row.createdAt),
                    ),
                    _row(
                      'آخر تحديث',
                      _fmtDate(row.updatedAt),
                    ),
                    _row(
                      'موعد الزيارة',
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
                    if (canRespondToQuote) ...[
                      const SizedBox(height: 20),
                      const Text(
                        'تم تسعير الطلب. يمكنك الآن قبول السعر أو رفضه.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed:
                                  _submitting ? null : _acceptQuote,
                              icon: const Icon(Icons.check_circle_outline),
                              label: Text(
                                _submitting ? 'جارٍ التنفيذ...' : 'قبول السعر',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed:
                                  _submitting ? null : _rejectQuote,
                              icon: const Icon(Icons.close_outlined),
                              label: const Text('رفض السعر'),
                            ),
                          ),
                        ],
                      ),
                    ],
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
