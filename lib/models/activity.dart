class Activity {
  final int? id;
  final String activityType;
  final String description;
  final double co2Saved;
  final String date;

  Activity({
    this.id,
    required this.activityType,
    required this.description,
    required this.co2Saved,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'activity_type': activityType,
      'description': description,
      'co2_saved': co2Saved,
      'date': date,
    };
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'],
      activityType: map['activity_type'],
      description: map['description'] ?? '',
      co2Saved: (map['co2_saved'] ?? 0).toDouble(),
      date: map['date'],
    );
  }
}
