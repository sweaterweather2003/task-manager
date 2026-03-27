import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/task.dart';
import '../../repositories/task_repository.dart';
import '../providers/task_provider.dart';

class TaskFormScreen extends ConsumerStatefulWidget {
  final Task? task;
  const TaskFormScreen({super.key, this.task});

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  String _status = 'To-Do';
  String? _blockedById;
  bool _isRecurring = false;
  String? _recurringType;
  bool _isLoading = false;
  bool _isEdit = false;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _isEdit = widget.task != null;
    if (_isEdit) {
      _titleController = TextEditingController(text: widget.task!.title);
      _descriptionController = TextEditingController(text: widget.task!.description);
      _dueDate = widget.task!.dueDate;
      _status = widget.task!.status;
      _blockedById = widget.task!.blockedById;
      _isRecurring = widget.task!.isRecurring;
      _recurringType = widget.task!.recurringType;
    } else {
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _isRecurring = false;
      _recurringType = null;
      _loadDraft();
    }

    _titleController.addListener(_saveDraftListener);
    _descriptionController.addListener(_saveDraftListener);
  }

  Future<void> _loadDraft() async {
    final repo = ref.read(taskRepositoryProvider);
    final draft = repo.getDraft();
    if (draft != null) {
      _titleController.text = draft['title'] ?? '';
      _descriptionController.text = draft['description'] ?? '';
      if (draft['dueDate'] != null) _dueDate = DateTime.fromMillisecondsSinceEpoch(draft['dueDate']);
      _status = draft['status'] ?? 'To-Do';
      _blockedById = draft['blockedById'];
      _isRecurring = draft['isRecurring'] ?? false;
      _recurringType = draft['recurringType'];
    }
  }

  void _saveDraftListener() {
    if (_isEdit) return;
    _saveDraft();
  }

  void _saveDraft() {
    final repo = ref.read(taskRepositoryProvider);
    final draftData = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'dueDate': _dueDate.millisecondsSinceEpoch,
      'status': _status,
      'blockedById': _blockedById,
      'isRecurring': _isRecurring,
      'recurringType': _recurringType,
    };
    repo.saveDraft(draftData);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
      _saveDraft();
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final notifier = ref.read(taskNotifierProvider.notifier);
    final repo = ref.read(taskRepositoryProvider);

    if (_isEdit) {
      final updated = widget.task!.copyWith(
        title: _titleController.text,
        description: _descriptionController.text,
        dueDate: _dueDate,
        status: _status,
        blockedById: _blockedById,
        isRecurring: _isRecurring,
        recurringType: _recurringType,
      );
      await notifier.updateTask(updated);
    } else {
      final newTask = Task(
        id: _uuid.v4(),
        title: _titleController.text,
        description: _descriptionController.text,
        dueDate: _dueDate,
        status: _status,
        blockedById: _blockedById,
        isRecurring: _isRecurring,
        recurringType: _recurringType,
      );
      await notifier.addTask(newTask);
      await repo.clearDraft();
    }

    setState(() => _isLoading = false);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final allTasks = ref.watch(taskNotifierProvider).value ?? [];
    final possibleBlockers = allTasks.where((t) => t.id != widget.task?.id).toList();

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Task' : 'Create Task')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title *'),
              validator: (v) => v?.trim().isEmpty ?? true ? 'Title is required' : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            ListTile(
              title: const Text('Due Date'),
              subtitle: Text(DateFormat.yMMMd().format(_dueDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDueDate,
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: const [
                DropdownMenuItem(value: 'To-Do', child: Text('To-Do')),
                DropdownMenuItem(value: 'In Progress', child: Text('In Progress')),
                DropdownMenuItem(value: 'Done', child: Text('Done')),
              ],
              onChanged: (v) {
                if (v != null) {
                  setState(() => _status = v);
                  _saveDraft();
                }
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String?>(
              initialValue: _blockedById,
              decoration: const InputDecoration(labelText: 'Blocked By (Optional)'),
              items: [
                const DropdownMenuItem(value: null, child: Text('None')),
                ...possibleBlockers.map((t) => DropdownMenuItem(value: t.id, child: Text(t.title))),
              ],
              onChanged: (v) {
                setState(() => _blockedById = v);
                _saveDraft();
              },
            ),
            const SizedBox(height: 20),
            // Stretch Goal 2: Recurring
            SwitchListTile(
              title: const Text('Recurring Task'),
              subtitle: const Text('Auto-create next task when marked Done'),
              value: _isRecurring,
              onChanged: (v) {
                setState(() {
                  _isRecurring = v;
                  if (!v) _recurringType = null;
                });
                _saveDraft();
              },
            ),
            if (_isRecurring) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _recurringType,
                decoration: const InputDecoration(labelText: 'Frequency'),
                items: const [
                  DropdownMenuItem(value: 'daily', child: Text('Daily')),
                  DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                ],
                onChanged: (v) {
                  setState(() => _recurringType = v);
                  _saveDraft();
                },
              ),
            ],
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveTask,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                  : Text(_isEdit ? 'Update Task' : 'Create Task', style: const TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}