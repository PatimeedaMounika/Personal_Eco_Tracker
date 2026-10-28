class Energy {
  final int? id;
  final String appliance;
  final double usageHours;
  final double estimatedUnits;
  final String date;

  Energy({
    this.id,
    required this.appliance,
    required this.usageHours,
    required this.estimatedUnits,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'appliance': appliance,
      'usage_hours': usageHours,
      'estimated_units': estimatedUnits,
      'date': date,
    };
  }

  factory Energy.fromMap(Map<String, dynamic> map) {
    return Energy(
      id: map['id'],
      appliance: map['appliance'],
      usageHours: (map['usage_hours'] ?? 0).toDouble(),
      estimatedUnits: (map['estimated_units'] ?? 0).toDouble(),
      date: map['date'],
    );
  }
}
