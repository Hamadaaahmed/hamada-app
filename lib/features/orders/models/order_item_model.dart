class OrderItemModel {
  final int machineId;
  final String machineName;
  final String icon;
  final int qty;
  final int unitPriceCents;

  const OrderItemModel({
    required this.machineId,
    required this.machineName,
    required this.icon,
    required this.qty,
    required this.unitPriceCents,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      machineId: int.tryParse('${map['machine_id']}') ?? 0,
      machineName: (map['machine_name'] ?? '').toString(),
      icon: (map['icon'] ?? '🧵').toString(),
      qty: int.tryParse('${map['qty']}') ?? 0,
      unitPriceCents: int.tryParse('${map['unit_price_cents']}') ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'machine_id': machineId,
      'machine_name': machineName,
      'icon': icon,
      'qty': qty,
      'unit_price_cents': unitPriceCents,
    };
  }
}
