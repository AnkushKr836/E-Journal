import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/task_item.dart';
import '../../domain/models/task_status.dart';
import '../providers/tasks_provider.dart';
import '../../../../core/widgets/glass_container.dart';

class TaskCard extends ConsumerStatefulWidget {
  final TaskItem task;
  final VoidCallback? onEdit;

  const TaskCard({
    super.key,
    required this.task,
    this.onEdit,
  });

  @override
  ConsumerState<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends ConsumerState<TaskCard> {
  bool _isSubtasksExpanded = false;
  final TextEditingController _subtaskInputController = TextEditingController();

  @override
  void dispose() {
    _subtaskInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tasksNotifier = ref.read(tasksProvider.notifier);

    return Draggable<String>(
      data: task.id,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 300,
          child: Opacity(
            opacity: 0.85,
            child: _buildCardContent(context, task, isDark, tasksNotifier, isDragging: true),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildCardContent(context, task, isDark, tasksNotifier),
      ),
      child: _buildCardContent(context, task, isDark, tasksNotifier),
    );
  }

  Widget _buildCardContent(
    BuildContext context,
    TaskItem task,
    bool isDark,
    TasksNotifier tasksNotifier, {
    bool isDragging = false,
  }) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      borderRadius: 18,
      padding: const EdgeInsets.all(14),
      glow: task.isTimerRunning,
      customBorderColor: task.isTimerRunning
          ? const Color(0xFF38BDF8).withValues(alpha: 0.6)
          : (task.status == TaskStatus.completed
              ? const Color(0xFF10B981).withValues(alpha: 0.3)
              : null),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: Priority Badge + Category Tag + Recurrence Icon + Menu
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Priority Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: task.priority.color.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: task.priority.color.withValues(alpha: 0.4),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(task.priority.icon, size: 11, color: task.priority.color),
                            const SizedBox(width: 3),
                            Text(
                              task.priority.code,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: task.priority.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Tag Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '#${task.tag}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF38BDF8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Recurrence Pill (if recurring)
                      if (task.recurrence.isRecurring)
                        Tooltip(
                          message: task.recurrence.description,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.purpleAccent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.repeat_rounded, size: 10, color: Colors.purpleAccent),
                                SizedBox(width: 3),
                                Text(
                                  'Recurring',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purpleAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Context Menu
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                iconSize: 18,
                icon: const Icon(Icons.more_horiz_rounded, color: Colors.grey),
                onSelected: (val) {
                  if (val == 'edit') {
                    widget.onEdit?.call();
                  } else if (val == 'delete') {
                    tasksNotifier.deleteTask(task.id);
                  } else if (val == 'reset_timer') {
                    tasksNotifier.resetTaskTimer(task.id);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 16),
                        SizedBox(width: 8),
                        Text('Edit Task'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'reset_timer',
                    child: Row(
                      children: [
                        Icon(Icons.refresh_rounded, size: 16),
                        SizedBox(width: 8),
                        Text('Reset Timer'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded, size: 16, color: Colors.redAccent),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.redAccent)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 2. Task Title & Description
          Text(
            task.title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.2,
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              color: task.isCompleted ? Colors.grey : null,
            ),
          ),
          if (task.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              task.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                height: 1.3,
              ),
            ),
          ],
          const SizedBox(height: 10),

          // 3. Nested Subtasks Progress & Expandable Checklist
          if (task.hasSubtasks || _isSubtasksExpanded) ...[
            InkWell(
              onTap: () => setState(() => _isSubtasksExpanded = !_isSubtasksExpanded),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isSubtasksExpanded ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_right_rounded,
                      size: 16,
                      color: const Color(0xFF38BDF8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Subtasks: ${task.completedSubtasks}/${task.totalSubtasks}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: task.subtaskProgress,
                          minHeight: 5,
                          backgroundColor: Colors.grey.withValues(alpha: 0.2),
                          color: task.subtaskProgress == 1.0 ? const Color(0xFF10B981) : const Color(0xFF38BDF8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${(task.subtaskProgress * 100).toInt()}%',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            // Expanded Subtask Checklist
            if (_isSubtasksExpanded) ...[
              const SizedBox(height: 8),
              for (final sub in task.subtasks)
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: Checkbox(
                          value: sub.isCompleted,
                          activeColor: const Color(0xFF38BDF8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          onChanged: (_) => tasksNotifier.toggleSubtask(task.id, sub.id),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          sub.title,
                          style: TextStyle(
                            fontSize: 12,
                            decoration: sub.isCompleted ? TextDecoration.lineThrough : null,
                            color: sub.isCompleted ? Colors.grey : null,
                          ),
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.close_rounded, size: 14, color: Colors.grey),
                        onPressed: () => tasksNotifier.removeSubtask(task.id, sub.id),
                      ),
                    ],
                  ),
                ),

              // Inline add subtask input
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 6, right: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _subtaskInputController,
                        style: const TextStyle(fontSize: 12),
                        decoration: const InputDecoration(
                          hintText: '+ Add subtask...',
                          hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (val) {
                          if (val.trim().isNotEmpty) {
                            tasksNotifier.addSubtask(task.id, val.trim());
                            _subtaskInputController.clear();
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline_rounded, size: 16, color: Color(0xFF38BDF8)),
                      onPressed: () {
                        if (_subtaskInputController.text.trim().isNotEmpty) {
                          tasksNotifier.addSubtask(task.id, _subtaskInputController.text.trim());
                          _subtaskInputController.clear();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
          ],

          // 4. Integrated Focus / Pomodoro Timer Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: task.isTimerRunning
                  ? const Color(0xFF38BDF8).withValues(alpha: 0.15)
                  : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04)),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: task.isTimerRunning
                    ? const Color(0xFF38BDF8).withValues(alpha: 0.4)
                    : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  task.isTimerRunning ? Icons.timer_rounded : Icons.timer_outlined,
                  size: 15,
                  color: task.isTimerRunning ? const Color(0xFF38BDF8) : Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(
                  task.formattedTimer,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: task.isTimerRunning ? const Color(0xFF38BDF8) : null,
                  ),
                ),
                if (task.elapsedSeconds > 0) ...[
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '• ${task.formattedElapsed}',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                const Spacer(),

                // Play / Pause Timer Button
                InkWell(
                  onTap: () => tasksNotifier.toggleTaskTimer(task.id),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: task.isTimerRunning
                          ? const Color(0xFF38BDF8)
                          : Colors.grey.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          task.isTimerRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          size: 13,
                          color: task.isTimerRunning ? Colors.black : Colors.grey,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          task.isTimerRunning ? 'Pause' : 'Focus',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: task.isTimerRunning ? Colors.black : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // 5. Stage Navigation Bar (Move between To-Do | Planning | In Progress | Completed)
          Row(
            children: [
              // Previous stage button
              if (task.status.previousStatus != null)
                Flexible(
                  child: InkWell(
                    onTap: () => tasksNotifier.retreatTaskStatus(task.id),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.arrow_back_ios_new_rounded, size: 10, color: Colors.grey),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              task.status.previousStatus!.label,
                              style: const TextStyle(fontSize: 9, color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              const Spacer(),

              // Recurring Rollover Action (if completed and recurring)
              if (task.isCompleted && task.recurrence.isRecurring)
                Tooltip(
                  message: 'Rollover to next recurring occurrence',
                  child: FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.purpleAccent.withValues(alpha: 0.2),
                      foregroundColor: Colors.purpleAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () => tasksNotifier.rolloverRecurringTask(task.id),
                    icon: const Icon(Icons.replay_rounded, size: 12),
                    label: const Text('Rollover', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),

              // Next stage button
              if (task.status.nextStatus != null) ...[
                const SizedBox(width: 6),
                Flexible(
                  child: InkWell(
                    onTap: () => tasksNotifier.advanceTaskStatus(task.id),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: task.status.nextStatus!.color.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: task.status.nextStatus!.color.withValues(alpha: 0.4),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              task.status.nextStatus!.label,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: task.status.nextStatus!.color,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Icon(Icons.arrow_forward_ios_rounded, size: 10, color: task.status.nextStatus!.color),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
