class OrderModel {
  final int id;
  final int clientId;
  final String phone;
  final double? lat;
  final double? lng;
  final double? accuracyM;
  final String status;
  final int totalCents;
  final int paidCents;
  final String adminNote;
  final String rejectReason;
  final String scheduledAt;
  final String completedAt;
  final String createdAt;

  const OrderModel({
    required this.id,
    required this.clientId,
    required this.phone,
    required this.lat,
    required this.lng,
    required this.accuracyM,
    required this.status,
    required this.totalCents,
    required this.paidCents,
    required this.adminNote,
    required this.rejectReason,
    required this.scheduledAt,
    required this.completedAt,
    required this.createdAt,
  });

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    return double.tryParse('$value');
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: int.tryParse('${map['id']}') ?? 0,
      clientId: int.tryParse('${map['client_id']}') ?? 0,
      phone: (map['phone'] ?? '').toString(),
      lat: _toDouble(map['lat']),
      lng: _toDouble(map['lng']),
      accuracyM: _toDouble(map['accuracy_m']),
      status: (map['status'] ?? '').toString(),
      totalCents: int.tryParse('${map['total_cents']}') ?? 0,
      paidCents: int.tryParse('${map['paid_cents']}') ?? 0,
      adminNote: (map['admin_note'] ?? '').toString(),
      rejectReason: (map['reject_reason'] ?? '').toString(),
      scheduledAt: (map['scheduled_at'] ?? '').toString(),
      completedAt: (map['completed_at'] ?? '').toString(),
      createdAt: (map['created_at'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap({bool includeType = true}) {
    return {
      if (includeType) 'type': 'order',
      'id': id,
      'client_id': clientId,
      'phone': phone,
      'lat': lat,
      'lng': lng,
      'accuracy_m': accuracyM,
      'status': status,
      'total_cents': totalCents,
      'paid_cents': paidCents,
      'admin_note': adminNote,
      'reject_reason': rejectReason,
      'scheduled_at': scheduledAt,
      'completed_at': completedAt,
      'created_at': createdAt,
    };
  }
}
