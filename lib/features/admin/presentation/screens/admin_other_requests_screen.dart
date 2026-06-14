import 'package:flutter/material.dart';

import '../../../../app/router.dart';
import '../../../../core/contact_name_text.dart';
import '../../data/admin_other_requests_service.dart';

class AdminOtherRequestsScreen extends StatefulWidget {
  final String requestKind;

  const AdminOtherRequestsScreen({
    super.key,
    required this.requestKind,
  });

  @override
  State<AdminOtherRequestsScreen> createState() =>
      _AdminOtherRequestsScreenState();
}

class _AdminOtherRequestsScreenState extends State<AdminOtherRequestsScreen> {
  final _service = AdminOtherRequestsService();

  bool _loading = true;
  List<Map<String, dynamic>> _requests = [];

  bool get _isSpare => widget.requestKind == 'spare_part_request';
  String get _title => _isSpare ? 'طلبات قطع الغيار' : 'طلبات المكن';
  String get _emptyText =>
      _isSpare ? 'لا توجد طلبات قطع غيار بعد' : 'لا توجد طلبات مكن بعد';

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
      final rows = await _service.listRequests(widget.requestKind);
      if (!mounted) return;
      setState(() => _requests = rows);
    } catch (e) {
      if (!mounted) return;
      _snack(_service.mapError(e), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

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

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.amber;
      case 'quoted':
        return Colors.blue;
      case 'price_accepted':
        return Colors.green;
      case 'price_rejected':
        return Colors.red;
      case 'scheduled':
        return Colors.cyan;
      case 'unavailable':
        return Colors.deepOrange;
      case 'completed':
        return Colors.green;
      default:
        return Colors.blueGrey;
    }
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

  Widget _badge(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(35),
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || !mounted) return;
        Navigator.pushReplacementNamed(context, AppRouter.adminHome);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_title),
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
            : _requests.isEmpty
                ? Center(child: Text(_emptyText))
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: _requests.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      padding: const EdgeInsets.all(12),
                      itemBuilder: (_, i) {
                        final item = _requests[i];
                        final phone = (item['phone'] ?? '').toString();
                        final status = (item['status'] ?? '').toString();
                        final machineName =
                            (item['machine_name'] ?? '').toString();
                        final createdAt = (item['created_at'] ?? '').toString();

                        return Card(
                          child: ListTile(
                            title: phone.trim().isNotEmpty
                                ? ContactNameText(
                                    phone: phone,
                                    fallbackPrefix: null,
                                  )
                                : Text('عميل #${item['client_id']}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  machineName.isEmpty
                                      ? 'بدون اسم'
                                      : machineName,
                                ),
                                const SizedBox(height: 4),
                                Text('طلب #${item['id']} • ${_fmtDate(createdAt)}'),
                              ],
                            ),
                            isThreeLine: true,
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _badge(status),
                                const SizedBox(height: 6),
                                const Icon(Icons.chevron_right),
                              ],
                            ),
                            onTap: () async {
                              await Navigator.pushNamed(
                                context,
                                AppRouter.adminOtherRequestDetails,
                                arguments: item['id'] as int? ?? 0,
                              );
                              _load();
                            },
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
