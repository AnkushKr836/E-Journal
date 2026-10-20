import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_journal/features/tasks/domain/models/task_item.dart';
import 'package:e_journal/features/tasks/domain/models/task_status.dart';
import 'package:e_journal/features/tasks/domain/models/task_priority.dart';
import 'package:e_journal/features/tasks/domain/models/recurrence_rule.dart';
import 'package:e_journal/features/tasks/domain/models/subtask.dart';
import 'package:e_journal/features/tasks/presentation/providers/tasks_provider.dart';

void main() {
  group('Tasks Module Unit & Integration Tests', () {
    test('RecurrenceRule calculates correct next occurrence for daily and custom', () {
      final baseDate = DateTime(2026, 10, 20, 10, 0);

      // Daily recurrence
      const daily = RecurrenceRule(type: RecurrenceType.daily, interval: 1);
      final nextDaily = daily.calculateNextOccurrence(baseDate);
      expect(nextDaily, DateTime(2026, 10, 21, 10, 0));

      // Custom interval (e.g. Every 3 days)
      const custom = RecurrenceRule(type: RecurrenceType.customDays, interval: 3);
      final nextCustom = custom.calculateNextOccurrence(baseDate);
      expect(nextCustom, DateTime(2026, 10, 23, 10, 0));
    });

    test('TaskItem correctly calculates nested subtask progress and timer formatting', () {
      final task = TaskItem(
        id: 'test-1',
        title: 'Complete System Architecture',
        createdAt: DateTime.now(),
        targetDurationSeconds: 25 * 60,
        elapsedSeconds: 5 * 60 + 30, // 5m 30s
        isTimerRunning: true,
        subtasks: const [
          SubTask(id: 's1', title: 'Subtask 1', isCompleted: true),
          SubTask(id: 's2', title: 'Subtask 2', isCompleted: false),
          SubTask(id: 's3', title: 'Subtask 3', isCompleted: true),
          SubTask(id: 's4', title: 'Subtask 4', isCompleted: false),
        ],
      );

      // Subtask metrics
      expect(task.totalSubtasks, 4);
      expect(task.completedSubtasks, 2);
      expect(task.subtaskProgress, 0.5);

      // Timer metrics
      expect(task.remainingSeconds, 25 * 60 - (5 * 60 + 30));
      expect(task.formattedElapsed, '5m tracked');
    });

    test('TasksNotifier properly advances statuses and handles recurring rollover', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(tasksProvider.notifier);

      // Add a test recurring task in To-Do
      final testTask = TaskItem(
        id: 'rec-task-1',
        title: 'Morning Daily Cardio',
        status: TaskStatus.todo,
        priority: TaskPriority.p2,
        createdAt: DateTime.now(),
        recurrence: const RecurrenceRule(type: RecurrenceType.daily, interval: 1),
      );
      notifier.addTask(testTask);

      // Verify added
      var current = container.read(tasksProvider).firstWhere((t) => t.id == 'rec-task-1');
      expect(current.status, TaskStatus.todo);

      // Advance to Planning to Do
      notifier.advanceTaskStatus('rec-task-1');
      current = container.read(tasksProvider).firstWhere((t) => t.id == 'rec-task-1');
      expect(current.status, TaskStatus.planned);

      // Advance to In Progress
      notifier.advanceTaskStatus('rec-task-1');
      current = container.read(tasksProvider).firstWhere((t) => t.id == 'rec-task-1');
      expect(current.status, TaskStatus.inProgress);

      // Advance to Completed
      notifier.advanceTaskStatus('rec-task-1');
      current = container.read(tasksProvider).firstWhere((t) => t.id == 'rec-task-1');
      expect(current.status, TaskStatus.completed);
      expect(current.completedAt, isNotNull);

      // Rollover recurring task back to To-Do for next day
      notifier.rolloverRecurringTask('rec-task-1');
      current = container.read(tasksProvider).firstWhere((t) => t.id == 'rec-task-1');
      expect(current.status, TaskStatus.todo);
      expect(current.dueDate, isNotNull);
    });
  });
}
