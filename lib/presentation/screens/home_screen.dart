import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import 'task_form_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = ref.watch(filteredTasksProvider);
    final tasksAsync = ref.watch(taskNotifierProvider);
    final searchTerm = ref.watch(searchTermProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Flodo Tasks')),
      body: tasksAsync.when(
        data: (_) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search tasks by title...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onChanged: (value) {
                        if (_debounce?.isActive ?? false) _debounce!.cancel();
                        _debounce = Timer(const Duration(milliseconds: 300), () {
                          ref.read(searchTermProvider.notifier).state = value; // Debounced (Stretch Goal 1)
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<String?>(
                    value: ref.watch(statusFilterProvider),
                    hint: const Text('All'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All')),
                      ...['To-Do', 'In Progress', 'Done'].map((s) => DropdownMenuItem(value: s, child: Text(s))),
                    ],
                    onChanged: (v) => ref.read(statusFilterProvider.notifier).state = v,
                  ),
                ],
              ),
            ),
            Expanded(
              child: filteredTasks.isEmpty
                  ? const Center(child: Text('No tasks yet.\nTap + to create one!', textAlign: TextAlign.center))
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredTasks.length,
                      onReorder: (oldIndex, newIndex) {
                        ref.read(taskNotifierProvider.notifier).reorder(oldIndex, newIndex);
                      },
                      itemBuilder: (context, index) {
                        final task = filteredTasks[index];
                        final allTasks = ref.watch(taskNotifierProvider).value ?? [];
                        return TaskCard(
                          key: ValueKey(task.id),
                          task: task,
                          allTasks: allTasks,
                          searchTerm: searchTerm,
                          onEdit: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TaskFormScreen(task: task))),
                          onDelete: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete Task?'),
                                content: const Text('This action cannot be undone.'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await ref.read(taskNotifierProvider.notifier).deleteTask(task.id);
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TaskFormScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }
}