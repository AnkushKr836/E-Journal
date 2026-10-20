import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/task_item.dart';
import '../../domain/models/task_status.dart';
import '../../domain/models/task_priority.dart';
import '../../domain/models/recurrence_rule.dart';
import '../../domain/models/subtask.dart';

// --- Filter Providers using Riverpod 3 Notifier ---
class TaskSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void setQuery(String q) => state = q;
}

final taskSearchQueryProvider =
    NotifierProvider<TaskSearchQueryNotifier, String>(TaskSearchQueryNotifier.new);

class TaskTagFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void setTag(String? t) => state = t;
}

final taskTagFilterProvider =
    NotifierProvider<TaskTagFilterNotifier, String?>(TaskTagFilterNotifier.new);

class TaskPriorityFilterNotifier extends Notifier<TaskPriority?> {
  @override
  TaskPriority? build() => null;
  void setPriority(TaskPriority? p) => state = p;
}

final taskPriorityFilterProvider =
    NotifierProvider<TaskPriorityFilterNotifier, TaskPriority?>(TaskPriorityFilterNotifier.new);

// --- Main Tasks Notifier ---
class TasksNotifier extends Notifier<List<TaskItem>> {
  Timer? _ticker;

  @override
  List<TaskItem> build() {
    ref.onDispose(() {
      _ticker?.cancel();
    });

    // Initial mock data showcasing multi-column, subtasks, timers, and recurrence
    final now = DateTime.now();
    return [
      TaskItem(
        id: 'task-1',
        title: 'Architect E-Journal Local-First Sync Engine',
        description: 'Design the offline-first SQLite Drift schema and sync contract with Supabase.',
        status: TaskStatus.inProgress,
        priority: TaskPriority.p1,
        tag: 'Dev',
        targetDurationSeconds: 45 * 60, // 45m deep focus
        elapsedSeconds: 18 * 60 + 24,   // 18m 24s elapsed
        isTimerRunning: true,
        dueDate: now.add(const Duration(hours: 4)),
        createdAt: now.subtract(const Duration(days: 1)),
        subtasks: const [
          SubTask(id: 's1', title: 'Define Drift table schemas for 8 modules', isCompleted: true),
          SubTask(id: 's2', title: 'Implement Last-Write-Wins conflict resolution', isCompleted: true),
          SubTask(id: 's3', title: 'Add offline optimistic mutation queue', isCompleted: false),
          SubTask(id: 's4', title: 'Write integration test for background delta sync', isCompleted: false),
        ],
      ),
      TaskItem(
        id: 'task-2',
        title: 'Weekly Supermarket Run & Pantry Restock',
        description: 'Buy produce, dairy staples, and ingredients for the 5-day meal prep plan.',
        status: TaskStatus.planned,
        priority: TaskPriority.p2,
        tag: 'Pantry',
        dueDate: now.add(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(hours: 6)),
        recurrence: RecurrenceRule(
          type: RecurrenceType.weekly,
          interval: 1,
          daysOfWeek: [DateTime.saturday],
          nextDueDate: now.add(const Duration(days: 4)),
        ),
        subtasks: const [
          SubTask(id: 's21', title: 'Check fridge inventory before leaving', isCompleted: true),
          SubTask(id: 's22', title: 'Verify budget limit: under \$75', isCompleted: false),
          SubTask(id: 's23', title: 'Pick up Greek yogurt and oat milk', isCompleted: false),
        ],
      ),
      TaskItem(
        id: 'task-3',
        title: 'Morning 30-min Cardio & Stretch',
        description: 'Zone 2 heart rate running on treadmill followed by lower back mobility.',
        status: TaskStatus.todo,
        priority: TaskPriority.p2,
        tag: 'Health',
        targetDurationSeconds: 30 * 60,
        elapsedSeconds: 0,
        createdAt: now.subtract(const Duration(days: 2)),
        recurrence: const RecurrenceRule(
          type: RecurrenceType.daily,
          interval: 1,
        ),
        subtasks: const [
          SubTask(id: 's31', title: 'Drink 500ml water with electrolytes', isCompleted: false),
          SubTask(id: 's32', title: '25 min steady-state jog', isCompleted: false),
          SubTask(id: 's33', title: '5 min cooldown & foam rolling', isCompleted: false),
        ],
      ),
      TaskItem(
        id: 'task-4',
        title: 'Deep Clean AC Filter & Living Room',
        description: 'Wash removable mesh filter with warm water and vacuum air vents.',
        status: TaskStatus.planned,
        priority: TaskPriority.p3,
        tag: 'Chore',
        createdAt: now.subtract(const Duration(days: 5)),
        recurrence: const RecurrenceRule(
          type: RecurrenceType.customDays,
          interval: 30, // Every 30 days
        ),
      ),
      TaskItem(
        id: 'task-5',
        title: 'Read System Design Interview: Chapter 5',
        description: 'Distributed cache eviction policies (LRU vs LFU) and consistent hashing.',
        status: TaskStatus.todo,
        priority: TaskPriority.p3,
        tag: 'Study',
        targetDurationSeconds: 40 * 60,
        elapsedSeconds: 0,
        createdAt: now.subtract(const Duration(hours: 12)),
      ),
      TaskItem(
        id: 'task-6',
        title: 'Draft Product Requirements Document (PRD)',
        description: 'Complete architecture specifications for E-Journal life management platform.',
        status: TaskStatus.completed,
        priority: TaskPriority.p1,
        tag: 'Work',
        createdAt: now.subtract(const Duration(days: 3)),
        completedAt: now.subtract(const Duration(hours: 2)),
        subtasks: const [
          SubTask(id: 's61', title: 'Competitive landscape analysis', isCompleted: true),
          SubTask(id: 's62', title: 'Feature breakdown for all 8 life modules', isCompleted: true),
          SubTask(id: 's63', title: 'Notification and alarm engine specifications', isCompleted: true),
        ],
      ),
    ];
  }

  void _startGlobalTicker() {
    if (_ticker != null && _ticker!.isActive) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      bool anyRunning = false;
      state = [
        for (final task in state)
          if (task.isTimerRunning) ...[
            task.copyWith(elapsedSeconds: task.elapsedSeconds + 1),
          ] else ...[
            task,
          ]
      ];
      anyRunning = state.any((t) => t.isTimerRunning);
      if (!anyRunning) {
        _ticker?.cancel();
        _ticker = null;
      }
    });
  }

  // --- Actions ---

  void addTask(TaskItem task) {
    state = [task, ...state];
  }

  void updateTask(TaskItem updatedTask) {
    state = [
      for (final task in state)
        if (task.id == updatedTask.id) updatedTask else task,
    ];
  }

  void deleteTask(String taskId) {
    state = state.where((task) => task.id != taskId).toList();
  }

  void moveTaskStatus(String taskId, TaskStatus newStatus) {
    state = [
      for (final task in state)
        if (task.id == taskId)
          task.copyWith(
            status: newStatus,
            completedAt: newStatus == TaskStatus.completed ? DateTime.now() : null,
            isTimerRunning: newStatus == TaskStatus.completed ? false : task.isTimerRunning,
          )
        else
          task,
    ];
  }

  void advanceTaskStatus(String taskId) {
    final task = state.firstWhere((t) => t.id == taskId);
    final next = task.status.nextStatus;
    if (next != null) {
      moveTaskStatus(taskId, next);
    }
  }

  void retreatTaskStatus(String taskId) {
    final task = state.firstWhere((t) => t.id == taskId);
    final prev = task.status.previousStatus;
    if (prev != null) {
      moveTaskStatus(taskId, prev);
    }
  }

  void toggleTaskTimer(String taskId) {
    state = [
      for (final task in state)
        if (task.id == taskId)
          task.copyWith(isTimerRunning: !task.isTimerRunning)
        else
          task,
    ];

    final hasRunning = state.any((t) => t.isTimerRunning);
    if (hasRunning) {
      _startGlobalTicker();
    }
  }

  void resetTaskTimer(String taskId) {
    state = [
      for (final task in state)
        if (task.id == taskId)
          task.copyWith(isTimerRunning: false, elapsedSeconds: 0)
        else
          task,
    ];
  }

  void toggleSubtask(String taskId, String subtaskId) {
    state = [
      for (final task in state)
        if (task.id == taskId)
          task.copyWith(
            subtasks: [
              for (final sub in task.subtasks)
                if (sub.id == subtaskId)
                  sub.copyWith(isCompleted: !sub.isCompleted)
                else
                  sub,
            ],
          )
        else
          task,
    ];
  }

  void addSubtask(String taskId, String title) {
    if (title.trim().isEmpty) return;
    state = [
      for (final task in state)
        if (task.id == taskId)
          task.copyWith(
            subtasks: [
              ...task.subtasks,
              SubTask(
                id: 'sub-${DateTime.now().millisecondsSinceEpoch}',
                title: title.trim(),
                isCompleted: false,
              ),
            ],
          )
        else
          task,
    ];
  }

  void removeSubtask(String taskId, String subtaskId) {
    state = [
      for (final task in state)
        if (task.id == taskId)
          task.copyWith(
            subtasks: task.subtasks.where((s) => s.id != subtaskId).toList(),
          )
        else
          task,
    ];
  }

  /// Handles recurring task rollover: logs completion, advances due date, resets to To-Do
  void rolloverRecurringTask(String taskId) {
    final now = DateTime.now();
    state = [
      for (final task in state)
        if (task.id == taskId && task.recurrence.isRecurring) ...[
          task.copyWith(
            status: TaskStatus.todo,
            dueDate: task.recurrence.calculateNextOccurrence(task.dueDate ?? now),
            elapsedSeconds: 0,
            isTimerRunning: false,
            // Reset subtasks for next cycle
            subtasks: [
              for (final sub in task.subtasks) sub.copyWith(isCompleted: false),
            ],
          ),
        ] else ...[
          task,
        ],
    ];
  }
}

final tasksProvider = NotifierProvider<TasksNotifier, List<TaskItem>>(() {
  return TasksNotifier();
});

// --- Computed Filtered Tasks ---
final filteredTasksProvider = Provider<List<TaskItem>>((ref) {
  final tasks = ref.watch(tasksProvider);
  final query = ref.watch(taskSearchQueryProvider).toLowerCase();
  final tagFilter = ref.watch(taskTagFilterProvider);
  final priorityFilter = ref.watch(taskPriorityFilterProvider);

  return tasks.where((task) {
    final matchesQuery = query.isEmpty ||
        task.title.toLowerCase().contains(query) ||
        task.description.toLowerCase().contains(query) ||
        task.tag.toLowerCase().contains(query);

    final matchesTag = tagFilter == null || task.tag == tagFilter;
    final matchesPriority = priorityFilter == null || task.priority == priorityFilter;

    return matchesQuery && matchesTag && matchesPriority;
  }).toList();
});
