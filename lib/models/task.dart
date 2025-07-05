import 'package:intl/intl.dart';


class Task {
  final String id;
  final String title;
  final String description;
  final DateTime reminderTime;
  final bool isCompleted;
  final DateTime? completedAt;
  final bool isRecurring;
  final String? recurringFrequency;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.reminderTime,
    this.isCompleted = false,
    this.completedAt,
    this.isRecurring = false,
    this.recurringFrequency,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'reminderTime': reminderTime.toIso8601String(),
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'isRecurring': isRecurring,
      'recurringFrequency': recurringFrequency,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      reminderTime: DateTime.parse(json['reminderTime']),
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      isRecurring: json['isRecurring'] ?? false,
      recurringFrequency: json['recurringFrequency'],
    );
  }

  Task copyWith({
    String? title,
    String? description,
    DateTime? reminderTime,
    bool? isCompleted,
    DateTime? completedAt,
    bool? isRecurring,
    String? recurringFrequency,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      reminderTime: reminderTime ?? this.reminderTime,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringFrequency: recurringFrequency ?? this.recurringFrequency,
    );
  }

  @override
  String toString() {
    return 'Task{id: $id, title: $title, reminderTime: ${reminderTime.toLocal()}}, isCompleted: $isCompleted';
  }

  String get formattedTime {
    return DateFormat('h:mm a').format(reminderTime);
  }

  String get formattedDate {
    return DateFormat('MMM d, yyyy').format(reminderTime);
  }
}
