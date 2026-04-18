import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/client_bottom_nav.dart';
import '../../../../app/ui.dart';
import '../../../../app/router.dart';
import '../../../../core/app_states.dart';
import '../../../../core/order_socket_service.dart';
import '../../../../core/secure_storage.dart';
import '../../../orders/models/order_model.dart';
import '../../../other_requests/models/other_request_model.dart';
import '../../data/client_orders_service.dart';

class ClientOrdersScreen extends StatefulWidget {
  const ClientOrdersScreen({super.key});

  @override
  State<ClientOrdersScreen> createState() => _ClientOrdersScreenState();
}

class _ClientOrdersScreenState extends State<ClientOrdersScreen> {
  final _service = ClientOrdersService();

  bool _loading = true;
  List<_OrderListEntry> _orders = [];
  Timer? _timer;
  StreamSubscription<Map<String, dynamic>>? _socketSub;
  int _clientId = 0;
  bool _socketConnected = false;
  bool _isLoadingNow = false;

  String _selectedSection = 'maintenance';
  String _selectedStatus = 'all';

  static const List<String> _statusOrder = [
    'all',
    'pending',
    'accepted',
    'in_progress',
    'scheduled',
    'quoted',
    'price_accepted',
    'price_rejected',
    'unavailable',
    'completed',
    'rejected',
    'cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _boot();
    _timer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (_socketConnected || _isLoadingNow) return;
      _load(silent: true);
    });
  }

  @override
  void dispose() {
    _socketSub?.cancel();
    OrderSocketService.I.disconnect();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _boot() async {
    await _resolveClientId();
    await _load();
    await _ensureSocketConnected();
  }

  Future<void> _resolveClientId() async {
    _clientId = await AppStorage.I.getClientIdFromToken();
  }

  Future<void> _ensureSocketConnected() async {
    final token = await AppStorage.I.getClientToken();
    if (token == null || token.isEmpty || _clientId <= 0) return;

    if (_socketConnected) return;
    await _socketSub?.cancel();

    _socketSub = OrderSocketService.I
        .connect(
          token: token,
          role: 'client',
          clientId: _clientId,
        )
        .listen((event) {
      if (!mounted) return;

      final socketEvent = (event['_socket_event'] ?? '').toString();
      if (socketEvent.isNotEmpty) {
        if (socketEvent == 'connected' || socketEvent == 'reconnected') {
          _socketConnected = true;
        } else if (socketEvent == 'disconnected' ||
            socketEvent == 'connect_error' ||
            socketEvent == 'error') {
          _socketConnected = false;
        }
        return;
      }

      _load(silent: true);
    });
  }

  Future<void> _load({bool silent = false}) async {
    if (_isLoadingNow) return;
    _isLoadingNow = true;

    if (!silent && mounted) {
      setState(() => _loading = true);
    }

    try {
      final normalOrders = await _service.listMyOrderModels();
      final otherRequests = await _service.listMyOtherRequestModels();

      final merged = <_OrderListEntry>[
        ...normalOrders.map(_OrderListEntry.order),
        ...otherRequests.map(_OrderListEntry.otherRequest),
      ];

      merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (!mounted) return;
      setState(() => _orders = merged);

      if (_clientId > 0 && !_socketConnected) {
        await _ensureSocketConnected();
      }
    } catch (_) {
      if (!mounted) return;
      _snack('خطأ في تحميل الطلبات', error: true);
    } finally {
      _isLoadingNow = false;
      if (!silent && mounted) {
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

  bool _isMaintenance(_OrderListEntry item) => item.type == _EntryType.order;

  bool _isSparePart(_OrderListEntry item) =>
      item.type == _EntryType.otherRequest &&
      item.requestKind == 'spare_part_request';

  bool _isMachineRequest(_OrderListEntry item) =>
      item.type == _EntryType.otherRequest && !_isSparePart(item);

  bool _matchesSelectedSection(_OrderListEntry item) {
    switch (_selectedSection) {
      case 'maintenance':
        return _isMaintenance(item);
      case 'machine':
        return _isMachineRequest(item);
      case 'spare':
        return _isSparePart(item);
      default:
        return true;
    }
  }

  bool _matchesSelectedStatus(_OrderListEntry item) {
    if (_selectedStatus == 'all') return true;
    return item.status == _selectedStatus;
  }

  int _countForSection(String section) {
    switch (section) {
      case 'maintenance':
        return _orders.where(_isMaintenance).length;
      case 'machine':
        return _orders.where(_isMachineRequest).length;
      case 'spare':
        return _orders.where(_isSparePart).length;
      default:
        return 0;
    }
  }

  String _statusText(String status) {
    switch (status) {
      case 'pending':
        return 'معلق';
      case 'accepted':
        return 'مقبول';
      case 'in_progress':
        return 'جاري التنفيذ';
      case 'scheduled':
        return 'تم تحديد موعد';
      case 'completed':
        return 'مكتمل';
      case 'rejected':
        return 'مرفوض';
      case 'cancelled':
        return 'ملغي';
      case 'quoted':
        return 'تم التسعير';
      case 'price_accepted':
        return 'تمت الموافقة على السعر';
      case 'price_rejected':
        return 'تم رفض السعر';
      case 'unavailable':
        return 'غير متوفر حاليًا';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.amber;
      case 'accepted':
        return Colors.blue;
      case 'in_progress':
        return Colors.orange;
      case 'scheduled':
        return Colors.cyan;
      case 'completed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      case 'quoted':
        return Colors.blue;
      case 'price_accepted':
        return Colors.green;
      case 'price_rejected':
        return Colors.red;
      case 'unavailable':
        return Colors.deepOrange;
      default:
        return Colors.blueGrey;
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

  Widget _statusBadge(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(40),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha(140)),
      ),
      child: Text(
        _statusText(status),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _typeBadge(_OrderListEntry item) {
    late final Color color;
    late final String text;

    if (_isMaintenance(item)) {
      color = Colors.green;
      text = 'طلب صيانة';
    } else if (_isSparePart(item)) {
      color = Colors.orange;
      text = 'طلب قطع غيار';
    } else {
      color = Colors.deepPurpleAccent;
      text = 'طلب مكن';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha(120)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  String _requestTitle(_OrderListEntry item) {
    if (_isMaintenance(item)) return 'طلب صيانة رقم #${item.id}';
    if (_isSparePart(item)) return 'طلب قطع غيار رقم #${item.id}';
    return 'طلب مكن رقم #${item.id}';
  }

  String _emptyMessage() {
    switch (_selectedSection) {
      case 'maintenance':
        return _selectedStatus == 'all'
            ? 'لا توجد طلبات صيانة بعد'
            : 'لا توجد طلبات بهذه الحالة';
      case 'machine':
        return _selectedStatus == 'all'
            ? 'لا توجد طلبات مكن بعد'
            : 'لا توجد طلبات بهذه الحالة';
      case 'spare':
        return _selectedStatus == 'all'
            ? 'لا توجد طلبات قطع غيار بعد'
            : 'لا توجد طلبات بهذه الحالة';
      default:
        return 'لا توجد طلبات بعد';
    }
  }

  String _sectionTitle() {
    switch (_selectedSection) {
      case 'maintenance':
        return 'طلبات الصيانة';
      case 'machine':
        return 'طلبات المكن';
      case 'spare':
        return 'طلبات قطع الغيار';
      default:
        return 'طلباتي';
    }
  }

  IconData _sectionIcon() {
    switch (_selectedSection) {
      case 'maintenance':
        return Icons.build_circle_outlined;
      case 'machine':
        return Icons.precision_manufacturing_outlined;
      case 'spare':
        return Icons.settings_outlined;
      default:
        return Icons.list_alt_outlined;
    }
  }

  Color _sectionColor() {
    switch (_selectedSection) {
      case 'maintenance':
        return Colors.green;
      case 'machine':
        return Colors.deepPurple;
      case 'spare':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  List<String> _statusOptionsForSection(List<_OrderListEntry> items) {
    final set = <String>{};
    for (final item in items) {
      final status = item.status.trim();
      if (status.isNotEmpty) {
        set.add(status);
      }
    }

    final result = <String>['all'];
    for (final status in _statusOrder) {
      if (status != 'all' && set.contains(status)) {
        result.add(status);
      }
    }

    for (final status in set) {
      if (!result.contains(status)) {
        result.add(status);
      }
    }

    return result;
  }

  Widget _sectionCard({
    required String keyName,
    required IconData icon,
    required String title,
    required Color color,
  }) {
    final selected = _selectedSection == keyName;
    final count = _countForSection(keyName);

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => setState(() {
          _selectedSection = keyName;
          _selectedStatus = 'all';
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: selected ? color.withAlpha(28) : Colors.white,
            border: Border.all(
              color: selected ? color : Colors.black12,
              width: selected ? 1.4 : 1,
            ),
            boxShadow: const [
              BoxShadow(
                blurRadius: 8,
                color: Colors.black12,
              ),
            ],
          ),
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: color.withAlpha(28),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: selected ? color : null,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$count',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: selected ? color : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    final selected = _selectedStatus == status;
    final color = status == 'all' ? _sectionColor() : _statusColor(status);

    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ChoiceChip(
        label: Text(status == 'all' ? 'الكل' : _statusText(status)),
        selected: selected,
        onSelected: (_) => setState(() => _selectedStatus = status),
        labelStyle: TextStyle(
          color: selected ? color : Colors.black87,
          fontWeight: selected ? FontWeight.bold : FontWeight.w500,
        ),
        selectedColor: color.withAlpha(28),
        backgroundColor: Colors.white,
        side: BorderSide(
          color: selected ? color : Colors.black12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sectionOrders = _orders.where(_matchesSelectedSection).toList();
    final filteredOrders = sectionOrders.where(_matchesSelectedStatus).toList();
    final statusOptions = _statusOptionsForSection(sectionOrders);
    final sectionColor = _sectionColor();

    return Scaffold(
      appBar: AppBar(
        title: const Text('طلباتي'),
        actions: [
          IconButton(
            onPressed: () => _load(),
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
          ),
        ],
      ),
      bottomNavigationBar: const ClientBottomNav(currentIndex: 1),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(12, 12, 12, 4),
                  child: AppHeroHeader(
                    title: 'كل طلباتك في شاشة واحدة',
                    subtitle: 'الصيانة وطلبات المكن وقطع الغيار بنفس البيانات الحالية مع عرض أوضح.',
                    icon: Icons.receipt_long_outlined,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  child: Row(
                    children: [
                      _sectionCard(
                        keyName: 'maintenance',
                        icon: Icons.build_circle_outlined,
                        title: 'طلبات الصيانة',
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      _sectionCard(
                        keyName: 'machine',
                        icon: Icons.precision_manufacturing_outlined,
                        title: 'طلبات المكن',
                        color: Colors.deepPurple,
                      ),
                      const SizedBox(width: 8),
                      _sectionCard(
                        keyName: 'spare',
                        icon: Icons.settings_outlined,
                        title: 'طلبات قطع الغيار',
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: sectionColor.withAlpha(18),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: sectionColor.withAlpha(80)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: sectionColor.withAlpha(28),
                          child: Icon(_sectionIcon(), color: sectionColor),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _sectionTitle(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'عدد الطلبات: ${sectionOrders.length}',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (statusOptions.length > 1)
                  SizedBox(
                    height: 52,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: statusOptions.map(_statusChip).toList(),
                    ),
                  ),
                Expanded(
                  child: filteredOrders.isEmpty
                      ? AppEmptyState(title: _emptyMessage(), subtitle: 'عند إنشاء طلب جديد سيظهر هنا تلقائيًا.', icon: Icons.receipt_long_outlined)
                      : RefreshIndicator(
                          onRefresh: () => _load(),
                          child: ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: filteredOrders.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 6),
                            padding: const EdgeInsets.all(12),
                            itemBuilder: (_, i) {
                              final item = filteredOrders[i];
                              final isOther =
                                  item.type == _EntryType.otherRequest;

                              return Card(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    isOther
                                        ? AppRouter.clientOtherRequestDetails
                                        : AppRouter.clientOrderDetails,
                                    arguments: item.id,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                _requestTitle(item),
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            _statusBadge(item.status),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        _typeBadge(item),
                                        const SizedBox(height: 10),
                                        if (isOther) ...[
                                          Text(
                                            'الاسم المطلوب: ${item.machineName}',
                                          ),
                                          Text(
                                            'السعر المسعّر: ${_money(item.quotedPriceCents)} جنيه',
                                          ),
                                          Text(
                                            'تاريخ الإنشاء: ${_fmtDate(item.createdAt)}',
                                          ),
                                          if (item.scheduledAt.trim().isNotEmpty)
                                            Text(
                                              'الموعد: ${_fmtDate(item.scheduledAt)}',
                                            ),
                                        ] else ...[
                                          Text(
                                            'الإجمالي: ${_money(item.totalCents)} جنيه',
                                          ),
                                          Text(
                                            'المدفوع: ${_money(item.paidCents)} جنيه',
                                          ),
                                          Text(
                                            'تاريخ الإنشاء: ${_fmtDate(item.createdAt)}',
                                          ),
                                          if (item.scheduledAt.trim().isNotEmpty)
                                            Text(
                                              'موعد الصيانة: ${_fmtDate(item.scheduledAt)}',
                                            ),
                                        ],
                                        if (item.rejectReason.trim().isNotEmpty)
                                          Text(
                                            'السبب: ${item.rejectReason}',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}

enum _EntryType {
  order,
  otherRequest,
}

class _OrderListEntry {
  final _EntryType type;
  final int id;
  final String requestKind;
  final String status;
  final String machineName;
  final int quotedPriceCents;
  final int totalCents;
  final int paidCents;
  final String rejectReason;
  final String scheduledAt;
  final String createdAt;

  const _OrderListEntry({
    required this.type,
    required this.id,
    required this.requestKind,
    required this.status,
    required this.machineName,
    required this.quotedPriceCents,
    required this.totalCents,
    required this.paidCents,
    required this.rejectReason,
    required this.scheduledAt,
    required this.createdAt,
  });

  factory _OrderListEntry.order(OrderModel order) {
    return _OrderListEntry(
      type: _EntryType.order,
      id: order.id,
      requestKind: '',
      status: order.status,
      machineName: '',
      quotedPriceCents: 0,
      totalCents: order.totalCents,
      paidCents: order.paidCents,
      rejectReason: order.rejectReason,
      scheduledAt: order.scheduledAt,
      createdAt: order.createdAt,
    );
  }

  factory _OrderListEntry.otherRequest(OtherRequestModel request) {
    return _OrderListEntry(
      type: _EntryType.otherRequest,
      id: request.id,
      requestKind: request.requestKind,
      status: request.status,
      machineName: request.machineName,
      quotedPriceCents: request.quotedPriceCents,
      totalCents: 0,
      paidCents: 0,
      rejectReason: request.rejectReason,
      scheduledAt: request.scheduledAt,
      createdAt: request.createdAt,
    );
  }
}
