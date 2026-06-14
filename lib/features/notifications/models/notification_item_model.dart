class NotificationItemModel {
  final int id;
  final String role;
  final String title;
  final String body;
  final bool isRead;
  final String createdAt;
  final Map<String, dynamic> dataJson;

  const NotificationItemModel({
    required this.id,
    required this.role,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    required this.dataJson,
  });

  factory NotificationItemModel.fromMap(Map<String, dynamic> map) {
    final rawData = map['data_json'];
    return NotificationItemModel(
      id: int.tryParse('${map['id']}') ?? 0,
      role: (map['role'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      body: (map['body'] ?? '').toString(),
      isRead: map['is_read'] == true ||
          '${map['is_read']}'.toLowerCase() == 'true',
      createdAt: (map['created_at'] ?? '').toString(),
      dataJson: rawData is Map<String, dynamic>
          ? rawData
          : <String, dynamic>{},
    );
  }
}
