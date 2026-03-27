import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/task.dart';
import 'status_badge.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final List<Task> allTasks;
  final String searchTerm;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.allTasks,
    this.searchTerm = '',
    required this.onEdit,
    required this.onDelete,
  });

  bool get _isBlocked {
    if (task.blockedById == null) return false;
    for (final t in allTasks) {
      if (t.id == task.blockedById) return t.status != 'Done';
    }
    return false;
  }

  // Fixed: now accepts BuildContext as parameter
  Widget _highlightTitle(String text, String query, BuildContext context) {
    if (query.isEmpty) {
      return Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18));
    }
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final matches = lowerQuery.allMatches(lowerText).toList();
    if (matches.isEmpty) {
      return Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18));
    }

    final spans = <TextSpan>[];
    int start = 0;
    for (final match in matches) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }
      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: const TextStyle(backgroundColor: Colors.yellow, fontWeight: FontWeight.bold),
      ));
      start = match.end;
    }
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }
    return RichText(
      text: TextSpan(
        children: spans,
        style: DefaultTextStyle.of(context).style.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBlocked = _isBlocked;
    String blockedText = '';
    if (task.blockedById != null) {
      for (final t in allTasks) {
        if (t.id == task.blockedById) {
          blockedText = 'Blocked by: ${t.title}';
          break;
        }
      }
    }

    return Opacity(
      opacity: isBlocked ? 0.5 : 1,
      child: Card(
        color: isBlocked ? Colors.grey[200] : null,
        child: ListTile(
          onTap: onEdit,
          title: _highlightTitle(task.title, searchTerm, context), // ← Fixed here
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(task.description, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Text('Due: ${DateFormat.yMMMd().format(task.dueDate)}', style: TextStyle(color: Colors.grey[600])),
              if (blockedText.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(blockedText, style: const TextStyle(fontSize: 13, color: Colors.red)),
              ],
              if (task.isRecurring && task.recurringType != null) ...[
                const SizedBox(height: 6),
                Chip(
                  label: Text('${task.recurringType!.toUpperCase()} 🔄', style: const TextStyle(fontSize: 12)),
                  backgroundColor: Colors.blue.withOpacity(0.15),
                  side: BorderSide.none,
                ),
              ],
              const SizedBox(height: 8),
              StatusBadge(status: task.status),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: onDelete,
          ),
        ),
      ),
    );
  }
}