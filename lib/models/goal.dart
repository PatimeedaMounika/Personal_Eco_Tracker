class Goal {
  final int? id;
  final String title;
  final double target;
  final double progress;
  final String? deadline;

  Goal({
    this.id,
    required this.title,
    required this.target,
    required this.progress,
    this.deadline,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'target': target,
      'progress': progress,
      'deadline': deadline,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'],
      title: map['title'],
      target: (map['target'] ?? 0).toDouble(),
      progress: (map['progress'] ?? 0).toDouble(),
      deadline: map['deadline'],
    );
  }
}
