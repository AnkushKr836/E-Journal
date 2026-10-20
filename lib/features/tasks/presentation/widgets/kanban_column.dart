import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/task_item.dart';
import '../../domain/models/task_status.dart';
import '../providers/tasks_provider.dart';
import 'task_card.dart';
import '../../../../core/widgets/glass_container.dart';

class KanbanColumn extends ConsumerWidget {
  final TaskStatus status;
  final List<TaskItem> tasks;
  final VoidCallback onAddTask;
  final void Function(TaskItem task) onEditTask;

  const KanbanColumn({
    super.key,
    required this.status,
    required this.tasks,
    required this.onAddTask,
    required this.onEditTask,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DragTarget<String>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) {
        final taskId = details.data;
        ref.read(tasksProvider.notifier).moveTaskStatus(taskId, status);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;

        return GlassContainer(
          width: 320,
          borderRadius: 24,
          padding: const EdgeInsets.all(16),
          glow: isHovered,
          customBorderColor: isHovered
              ? status.color.withValues(alpha: 0.8)
              : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06)),
          customColor: isHovered
              ? status.color.withValues(alpha: 0.1)
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: status.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(status.icon, size: 16, color: status.color),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    status.label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${tasks.length}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: status.color,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Add Task to this Column
                  IconButton(
                    iconSize: 18,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.add_rounded, color: Colors.grey),
                    tooltip: 'Add to ${status.label}',
                    onPressed: onAddTask,
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Task Cards List
              Expanded(
                child: tasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.drag_indicator_rounded,
                              size: 28,
                              color: Colors.grey.withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Drop tasks here or click +',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return TaskCard(
                            key: ValueKey(task.id),
                            task: task,
                            onEdit: () => onEditTask(task),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
