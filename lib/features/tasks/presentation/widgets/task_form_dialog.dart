import 'package:flutter/material.dart';
import '../../domain/models/task_item.dart';
import '../../domain/models/task_status.dart';
import '../../domain/models/task_priority.dart';
import '../../domain/models/recurrence_rule.dart';
import '../../domain/models/subtask.dart';
import '../../../../core/widgets/glass_container.dart';

class TaskFormDialog extends StatefulWidget {
  final TaskItem? initialTask;
  final TaskStatus? defaultStatus;
  final void Function(TaskItem task) onSave;

  const TaskFormDialog({
    super.key,
    this.initialTask,
    this.defaultStatus,
    required this.onSave,
  });

  @override
  State<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends State<TaskFormDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _tagController;
  final TextEditingController _newSubtaskController = TextEditingController();

  late TaskStatus _status;
  late TaskPriority _priority;
  late String _selectedTag;
  late int _targetMinutes;
  
  // Recurrence
  late RecurrenceType _recurrenceType;
  late int _recurrenceInterval;
  late List<int> _selectedWeekdays;

  late List<SubTask> _subtasks;

  final List<String> _presetTags = ['Work', 'Dev', 'Health', 'Pantry', 'Chore', 'Study', 'Personal'];
  final List<int> _durationPresets = [15, 25, 45, 60, 90];

  @override
  void initState() {
    super.initState();
    final task = widget.initialTask;

    _titleController = TextEditingController(text: task?.title ?? '');
    _descController = TextEditingController(text: task?.description ?? '');
    _selectedTag = task?.tag ?? 'Work';
    _tagController = TextEditingController(text: _selectedTag);

    _status = task?.status ?? widget.defaultStatus ?? TaskStatus.todo;
    _priority = task?.priority ?? TaskPriority.p2;
    _targetMinutes = (task?.targetDurationSeconds ?? (25 * 60)) ~/ 60;

    _recurrenceType = task?.recurrence.type ?? RecurrenceType.none;
    _recurrenceInterval = task?.recurrence.interval ?? 1;
    _selectedWeekdays = List<int>.from(task?.recurrence.daysOfWeek ?? [DateTime.now().weekday]);

    _subtasks = List<SubTask>.from(task?.subtasks ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _tagController.dispose();
    _newSubtaskController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final rule = RecurrenceRule(
      type: _recurrenceType,
      interval: _recurrenceInterval,
      daysOfWeek: _recurrenceType == RecurrenceType.weekly ? _selectedWeekdays : [],
      nextDueDate: _recurrenceType != RecurrenceType.none
          ? DateTime.now().add(Duration(days: _recurrenceInterval))
          : null,
    );

    final task = TaskItem(
      id: widget.initialTask?.id ?? 'task-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: _descController.text.trim(),
      status: _status,
      priority: _priority,
      tag: _selectedTag.isNotEmpty ? _selectedTag : 'General',
      subtasks: _subtasks,
      recurrence: rule,
      targetDurationSeconds: _targetMinutes * 60,
      elapsedSeconds: widget.initialTask?.elapsedSeconds ?? 0,
      isTimerRunning: widget.initialTask?.isTimerRunning ?? false,
      createdAt: widget.initialTask?.createdAt ?? DateTime.now(),
      completedAt: widget.initialTask?.completedAt,
    );

    widget.onSave(task);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.initialTask != null;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: GlassContainer(
        width: 600,
        borderRadius: 24,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isEditing ? Icons.edit_note_rounded : Icons.add_task_rounded,
                      color: const Color(0xFF38BDF8),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEditing ? 'Edit Task' : 'Create New Task',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Title input
              TextField(
                controller: _titleController,
                autofocus: !isEditing,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Task Title *',
                  hintText: 'e.g. Design offline sync architecture',
                  filled: true,
                  fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),

              // Description input
              TextField(
                controller: _descController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Notes & Context (Optional)',
                  hintText: 'Add details, requirements, links...',
                  filled: true,
                  fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),

              // Status (Column) & Priority Selectors
              Row(
                children: [
                  // Status Dropdown
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Column Stage', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<TaskStatus>(
                              value: _status,
                              isExpanded: true,
                              items: TaskStatus.values.map((s) {
                                return DropdownMenuItem(
                                  value: s,
                                  child: Row(
                                    children: [
                                      Icon(s.icon, size: 16, color: s.color),
                                      const SizedBox(width: 8),
                                      Text(s.label, style: const TextStyle(fontSize: 13)),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _status = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Priority Dropdown
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Priority Level', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<TaskPriority>(
                              value: _priority,
                              isExpanded: true,
                              items: TaskPriority.values.map((p) {
                                return DropdownMenuItem(
                                  value: p,
                                  child: Row(
                                    children: [
                                      Icon(p.icon, size: 16, color: p.color),
                                      const SizedBox(width: 8),
                                      Text('${p.code} - ${p.label}', style: TextStyle(fontSize: 12, color: p.color)),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _priority = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Category Tag Selector
              const Text('Category Tag', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _presetTags.map((tag) {
                  final isSelected = _selectedTag == tag;
                  return ChoiceChip(
                    label: Text('#$tag'),
                    selected: isSelected,
                    selectedColor: const Color(0xFF38BDF8).withValues(alpha: 0.25),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? const Color(0xFF38BDF8) : null,
                    ),
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedTag = tag);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Focus / Pomodoro Target Duration
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Focus Duration (Pomodoro)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  Text('$_targetMinutes minutes', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF38BDF8), fontSize: 12)),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: _durationPresets.map((mins) {
                  final isSelected = _targetMinutes == mins;
                  return ChoiceChip(
                    label: Text('${mins}m'),
                    selected: isSelected,
                    selectedColor: const Color(0xFF38BDF8).withValues(alpha: 0.25),
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? const Color(0xFF38BDF8) : null,
                    ),
                    onSelected: (selected) {
                      if (selected) setState(() => _targetMinutes = mins);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Recurrence Settings Section
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.repeat_rounded, size: 16, color: Colors.purpleAccent),
                  const SizedBox(width: 8),
                  const Text('Task Recurrence', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  DropdownButton<RecurrenceType>(
                    value: _recurrenceType,
                    underline: const SizedBox(),
                    items: RecurrenceType.values.map((r) {
                      return DropdownMenuItem(value: r, child: Text(r.label, style: const TextStyle(fontSize: 12)));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _recurrenceType = val);
                    },
                  ),
                ],
              ),

              // Recurrence Detail Inputs
              if (_recurrenceType == RecurrenceType.weekly) ...[
                const SizedBox(height: 8),
                const Text('Repeat on days:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (int day = 1; day <= 7; day++)
                      _buildWeekdayChip(day),
                  ],
                ),
              ] else if (_recurrenceType == RecurrenceType.customDays) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Every ', style: TextStyle(fontSize: 12)),
                    SizedBox(
                      width: 60,
                      child: TextFormField(
                        initialValue: '$_recurrenceInterval',
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(isDense: true),
                        onChanged: (v) {
                          final parsed = int.tryParse(v);
                          if (parsed != null && parsed > 0) {
                            _recurrenceInterval = parsed;
                          }
                        },
                      ),
                    ),
                    const Text(' days', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
              const SizedBox(height: 16),

              // Nested Subtasks Section
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Nested Subtasks (${_subtasks.length})', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              for (int i = 0; i < _subtasks.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(Icons.check_box_outline_blank_rounded, size: 16, color: Colors.grey.withValues(alpha: 0.6)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_subtasks[i].title, style: const TextStyle(fontSize: 13)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, size: 16, color: Colors.redAccent),
                        onPressed: () {
                          setState(() => _subtasks.removeAt(i));
                        },
                      ),
                    ],
                  ),
                ),

              // Add Subtask row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newSubtaskController,
                      decoration: InputDecoration(
                        hintText: 'Add checklist subtask...',
                        hintStyle: const TextStyle(fontSize: 12),
                        isDense: true,
                        filled: true,
                        fillColor: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                      onSubmitted: (val) {
                        if (val.trim().isNotEmpty) {
                          setState(() {
                            _subtasks.add(SubTask(id: 'sub-${DateTime.now().millisecondsSinceEpoch}', title: val.trim()));
                            _newSubtaskController.clear();
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                      foregroundColor: const Color(0xFF38BDF8),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    onPressed: () {
                      if (_newSubtaskController.text.trim().isNotEmpty) {
                        setState(() {
                          _subtasks.add(SubTask(
                            id: 'sub-${DateTime.now().millisecondsSinceEpoch}',
                            title: _newSubtaskController.text.trim(),
                          ));
                          _newSubtaskController.clear();
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Dialog Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF38BDF8),
                      foregroundColor: const Color(0xFF0A0F1D),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _submit,
                    child: Text(isEditing ? 'Save Changes' : 'Create Task', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeekdayChip(int weekday) {
    const dayLabels = {1: 'M', 2: 'T', 3: 'W', 4: 'T', 5: 'F', 6: 'S', 7: 'S'};
    final isSelected = _selectedWeekdays.contains(weekday);

    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedWeekdays.remove(weekday);
          } else {
            _selectedWeekdays.add(weekday);
          }
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF38BDF8) : Colors.grey.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Text(
          dayLabels[weekday] ?? '',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }
}
