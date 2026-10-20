import 'package:flutter/material.dart';

enum TaskStatus {
  todo,
  planned,
  inProgress,
  completed;

  String get label {
    switch (this) {
      case TaskStatus.todo:
        return 'To-Do';
      case TaskStatus.planned:
        return 'Planning to Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
    }
  }

  IconData get icon {
    switch (this) {
      case TaskStatus.todo:
        return Icons.inbox_rounded;
      case TaskStatus.planned:
        return Icons.calendar_month_rounded;
      case TaskStatus.inProgress:
        return Icons.bolt_rounded;
      case TaskStatus.completed:
        return Icons.check_circle_rounded;
    }
  }

  Color get color {
    switch (this) {
      case TaskStatus.todo:
        return const Color(0xFF94A3B8); // Slate
      case TaskStatus.planned:
        return const Color(0xFF38BDF8); // Icy Blue
      case TaskStatus.inProgress:
        return const Color(0xFFF59E0B); // Amber
      case TaskStatus.completed:
        return const Color(0xFF10B981); // Emerald Green
    }
  }

  TaskStatus? get nextStatus {
    switch (this) {
      case TaskStatus.todo:
        return TaskStatus.planned;
      case TaskStatus.planned:
        return TaskStatus.inProgress;
      case TaskStatus.inProgress:
        return TaskStatus.completed;
      case TaskStatus.completed:
        return null;
    }
  }

  TaskStatus? get previousStatus {
    switch (this) {
      case TaskStatus.todo:
        return null;
      case TaskStatus.planned:
        return TaskStatus.todo;
      case TaskStatus.inProgress:
        return TaskStatus.planned;
      case TaskStatus.completed:
        return TaskStatus.inProgress;
    }
  }
}
