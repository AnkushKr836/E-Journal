import 'task_status.dart';
import 'task_priority.dart';
import 'recurrence_rule.dart';
import 'subtask.dart';

class TaskItem {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final String tag;
  final List<SubTask> subtasks;
  final RecurrenceRule recurrence;
  
  // Focus / Pomodoro Timer integration
  final int targetDurationSeconds; // Default e.g. 25 mins (1500s)
  final int elapsedSeconds;        // Time spent tracking
  final bool isTimerRunning;
  
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime? completedAt;

  const TaskItem({
    required this.id,
    required this.title,
    this.description = '',
    this.status = TaskStatus.todo,
    this.priority = TaskPriority.p3,
    this.tag = 'General',
    this.subtasks = const [],
    this.recurrence = const RecurrenceRule(),
    this.targetDurationSeconds = 25 * 60,
    this.elapsedSeconds = 0,
    this.isTimerRunning = false,
    this.dueDate,
    required this.createdAt,
    this.completedAt,
  });

  bool get isCompleted => status == TaskStatus.completed;

  int get totalSubtasks => subtasks.length;
  int get completedSubtasks => subtasks.where((s) => s.isCompleted).length;
  bool get hasSubtasks => subtasks.isNotEmpty;

  double get subtaskProgress =>
      hasSubtasks ? (completedSubtasks / totalSubtasks) : (isCompleted ? 1.0 : 0.0);

  int get remainingSeconds {
    final rem = targetDurationSeconds - elapsedSeconds;
    return rem > 0 ? rem : 0;
  }

  String get formattedTimer {
    final total = isTimerRunning || elapsedSeconds > 0 ? remainingSeconds : targetDurationSeconds;
    final mins = (total ~/ 60).toString().padLeft(2, '0');
    final secs = (total % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  String get formattedElapsed {
    final mins = elapsedSeconds ~/ 60;
    if (mins < 60) return '${mins}m tracked';
    final hours = mins ~/ 60;
    final remMins = mins % 60;
    return '${hours}h ${remMins}m tracked';
  }

  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  TaskItem copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    String? tag,
    List<SubTask>? subtasks,
    RecurrenceRule? recurrence,
    int? targetDurationSeconds,
    int? elapsedSeconds,
    bool? isTimerRunning,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      tag: tag ?? this.tag,
      subtasks: subtasks ?? this.subtasks,
      recurrence: recurrence ?? this.recurrence,
      targetDurationSeconds: targetDurationSeconds ?? this.targetDurationSeconds,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
