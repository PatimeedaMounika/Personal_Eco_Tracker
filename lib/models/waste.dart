class Waste {
  final int? id;
  final String wasteType;
  final double quantity;
  final bool recycled;
  final String date;

  Waste({
    this.id,
    required this.wasteType,
    required this.quantity,
    required this.recycled,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'waste_type': wasteType,
      'quantity': quantity,
      'recycled': recycled ? 1 : 0,
      'date': date,
    };
  }

  factory Waste.fromMap(Map<String, dynamic> map) {
    return Waste(
      id: map['id'],
      wasteType: map['waste_type'],
      quantity: (map['quantity'] ?? 0).toDouble(),
      recycled: map['recycled'] == 1,
      date: map['date'],
    );
  }
}
