import 'dart:convert';

class OtherRequestModel {
  final int id;
  final int clientId;
  final String requestKind;
  final String email;
  final String phone;
  final String machineName;
  final String faultDescription;
  final String imageUrl;
  final String replacementImageUrl;
  final String imageUrlsJson;
  final String replacementImageUrlsJson;
  final double? lat;
  final double? lng;
  final double? accuracyM;
  final String status;
  final int quotedPriceCents;
  final String adminNote;
  final String rejectReason;
  final String scheduledAt;
  final String completedAt;
  final String createdAt;
  final String updatedAt;

  const OtherRequestModel({
    required this.id,
    required this.clientId,
    required this.requestKind,
    required this.email,
    required this.phone,
    required this.machineName,
    required this.faultDescription,
    required this.imageUrl,
    required this.replacementImageUrl,
    required this.imageUrlsJson,
    required this.replacementImageUrlsJson,
    required this.lat,
    required this.lng,
    required this.accuracyM,
    required this.status,
    required this.quotedPriceCents,
    required this.adminNote,
    required this.rejectReason,
    required this.scheduledAt,
    required this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isSparePart => requestKind == 'spare_part_request';
  bool get isMachineRequest => !isSparePart;

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    return double.tryParse('$value');
  }

  static List<String> _parseJsonList(String raw) {
    try {
      final parsed = jsonDecode(raw);
      if (parsed is List) {
        return parsed
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    } catch (_) {}
    return <String>[];
  }

  List<String> get imageUrls {
    final list = _parseJsonList(imageUrlsJson);
    final single = imageUrl.trim();
    if (single.isNotEmpty && !list.contains(single)) {
      list.insert(0, single);
    }
    return list;
  }

  List<String> get replacementImageUrls {
    final list = _parseJsonList(replacementImageUrlsJson);
    final single = replacementImageUrl.trim();
    if (single.isNotEmpty && !list.contains(single)) {
      list.insert(0, single);
    }
    return list;
  }

  factory OtherRequestModel.fromMap(Map<String, dynamic> raw) {
    return OtherRequestModel(
      id: int.tryParse('${raw['id']}') ?? 0,
      clientId: int.tryParse('${raw['client_id']}') ?? 0,
      requestKind: (raw['request_kind'] ?? 'machine_request').toString(),
      email: (raw['email'] ?? '').toString(),
      phone: (raw['phone'] ?? '').toString(),
      machineName: (raw['machine_name'] ?? '').toString(),
      faultDescription: (raw['fault_description'] ?? '').toString(),
      imageUrl: (raw['image_url'] ?? '').toString(),
      replacementImageUrl: (raw['replacement_image_url'] ?? '').toString(),
      imageUrlsJson: (raw['image_urls_json'] ?? '[]').toString(),
      replacementImageUrlsJson:
          (raw['replacement_image_urls_json'] ?? '[]').toString(),
      lat: _toDouble(raw['lat']),
      lng: _toDouble(raw['lng']),
      accuracyM: _toDouble(raw['accuracy_m']),
      status: (raw['status'] ?? '').toString(),
      quotedPriceCents: int.tryParse('${raw['quoted_price_cents']}') ?? 0,
      adminNote: (raw['admin_note'] ?? '').toString(),
      rejectReason: (raw['reject_reason'] ?? '').toString(),
      scheduledAt: (raw['scheduled_at'] ?? '').toString(),
      completedAt: (raw['completed_at'] ?? '').toString(),
      createdAt: (raw['created_at'] ?? '').toString(),
      updatedAt: (raw['updated_at'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap({bool includeType = true}) {
    return {
      if (includeType) 'type': 'other_request',
      'id': id,
      'client_id': clientId,
      'request_kind': requestKind,
      'email': email,
      'phone': phone,
      'machine_name': machineName,
      'fault_description': faultDescription,
      'image_url': imageUrl,
      'replacement_image_url': replacementImageUrl,
      'image_urls_json': imageUrlsJson,
      'replacement_image_urls_json': replacementImageUrlsJson,
      'lat': lat,
      'lng': lng,
      'accuracy_m': accuracyM,
      'status': status,
      'quoted_price_cents': quotedPriceCents,
      'admin_note': adminNote,
      'reject_reason': rejectReason,
      'scheduled_at': scheduledAt,
      'completed_at': completedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
