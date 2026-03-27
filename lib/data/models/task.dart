import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  DateTime dueDate;

  @HiveField(4)
  String status;

  @HiveField(5)
  String? blockedById;

  @HiveField(6)
  bool isRecurring;

  @HiveField(7)
  String? recurringType; // "daily" or "weekly"

  @HiveField(8)
  int orderIndex;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    this.blockedById,
    this.isRecurring = false,
    this.recurringType,
    this.orderIndex = 0,
  });

  Task copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    String? status,
    String? blockedById,
    bool? isRecurring,
    String? recurringType,
    int? orderIndex,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      blockedById: blockedById ?? this.blockedById,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringType: recurringType ?? this.recurringType,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }
}
