class Transport {
  final int? id;
  final String mode;
  final double distance;
  final double co2Emission;
  final String date;

  Transport({
    this.id,
    required this.mode,
    required this.distance,
    required this.co2Emission,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mode': mode,
      'distance': distance,
      'co2_emission': co2Emission,
      'date': date,
    };
  }

  factory Transport.fromMap(Map<String, dynamic> map) {
    return Transport(
      id: map['id'],
      mode: map['mode'],
      distance: (map['distance'] ?? 0).toDouble(),
      co2Emission: (map['co2_emission'] ?? 0).toDouble(),
      date: map['date'],
    );
  }
}
