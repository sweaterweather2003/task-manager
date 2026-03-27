import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/task.dart';

class TaskRepository {
  static const String _taskBoxName = 'tasks';
  static const String _draftBoxName = 'drafts';

  Box<Task>? _taskBox;
  Box? _draftBox;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TaskAdapter());
    _taskBox = await Hive.openBox<Task>(_taskBoxName);
    _draftBox = await Hive.openBox(_draftBoxName);
  }

  Box<Task> get taskBox {
    if (_taskBox == null) throw Exception('Repository not initialized');
    return _taskBox!;
  }

  Box get draftBox {
    if (_draftBox == null) throw Exception('Repository not initialized');
    return _draftBox!;
  }

  List<Task> getAllTasks() => taskBox.values.toList();

  Future<void> addTask(Task task) async {
    await Future.delayed(const Duration(seconds: 2));
    await taskBox.put(task.id, task);
  }

  Future<void> updateTask(Task task) async {
    await Future.delayed(const Duration(seconds: 2));
    await taskBox.put(task.id, task);
  }

  Future<void> deleteTask(String id) async {
    await taskBox.delete(id);
  }

  // Draft (only for new tasks)
  Map<String, dynamic>? getDraft() {
    final data = draftBox.get('new_task');
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  Future<void> saveDraft(Map<String, dynamic> draftData) async {
    await draftBox.put('new_task', draftData);
  }

  Future<void> clearDraft() async {
    await draftBox.delete('new_task');
  }
}