import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';
import '../../data/models/task.dart';
import '../../repositories/task_repository.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) => TaskRepository());

final taskNotifierProvider = AsyncNotifierProvider<TaskNotifier, List<Task>>(TaskNotifier.new);

class TaskNotifier extends AsyncNotifier<List<Task>> {
  late final TaskRepository _repository;
  final _uuid = const Uuid();

  @override
  Future<List<Task>> build() async {
    _repository = ref.watch(taskRepositoryProvider);
    await _repository.init();
    return _repository.getAllTasks();
  }

  Future<void> addTask(Task task) async {
    final current = await future;
    final maxOrder = current.isEmpty ? 0 : current.map((t) => t.orderIndex).reduce((a, b) => a > b ? a : b);
    final newTask = task.copyWith(orderIndex: maxOrder + 1);

    await _repository.addTask(newTask);
    state = AsyncData([...current, newTask]);
  }

  Future<void> updateTask(Task task) async {
    await _repository.updateTask(task);

    final current = await future;
    List<Task> newList = current.map((t) => t.id == task.id ? task : t).toList();

    // Recurring logic (Stretch Goal 2)
    if (task.status == 'Done' && task.isRecurring && task.recurringType != null) {
      final nextDue = task.recurringType == 'daily'
          ? task.dueDate.add(const Duration(days: 1))
          : task.dueDate.add(const Duration(days: 7));

      final newRecurringTask = Task(
        id: _uuid.v4(),
        title: task.title,
        description: task.description,
        dueDate: nextDue,
        status: 'To-Do',
        blockedById: null,
        isRecurring: true,
        recurringType: task.recurringType,
        orderIndex: newList.length,
      );

      await _repository.addTask(newRecurringTask);
      newList.add(newRecurringTask);
    }

    state = AsyncData(newList);
  }

  Future<void> deleteTask(String id) async {
    await _repository.deleteTask(id);
    final current = await future;
    state = AsyncData(current.where((t) => t.id != id).toList());
  }

  // Stretch Goal 3: Persistent Drag-and-Drop
  Future<void> reorder(int oldIndex, int newIndex) async {
    final current = await future;
    if (oldIndex < newIndex) newIndex--;
    final moved = current.removeAt(oldIndex);
    current.insert(newIndex, moved);

    // Re-assign orderIndex
    final updated = current.asMap().map((i, t) => MapEntry(i, t.copyWith(orderIndex: i))).values.toList();

    state = AsyncData(updated);

    // Save directly (no 2-second delay for smooth UX)
    for (var task in updated) {
      await _repository.taskBox.put(task.id, task);
    }
  }
}

final searchTermProvider = StateProvider<String>((ref) => '');
final statusFilterProvider = StateProvider<String?>((ref) => null);

// Filtered + sorted + debounced provider
final filteredTasksProvider = Provider<List<Task>>((ref) {
  final tasksAsync = ref.watch(taskNotifierProvider);
  final search = ref.watch(searchTermProvider);
  final filter = ref.watch(statusFilterProvider);

  return tasksAsync.when(
    data: (tasks) {
      // Sort by saved orderIndex (Stretch Goal 3)
      var sorted = List<Task>.from(tasks)..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

      var filtered = sorted;
      if (search.isNotEmpty) {
        filtered = filtered
            .where((t) => t.title.toLowerCase().contains(search.toLowerCase()))
            .toList();
      }
      if (filter != null) {
        filtered = filtered.where((t) => t.status == filter).toList();
      }
      return filtered;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});