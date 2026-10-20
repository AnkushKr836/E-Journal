import 'package:flutter/material.dart';

enum TaskPriority {
  p1, // Urgent & Important
  p2, // High / Important
  p3, // Medium / Normal
  p4; // Low / Someday

  String get code {
    switch (this) {
      case TaskPriority.p1:
        return 'P1';
      case TaskPriority.p2:
        return 'P2';
      case TaskPriority.p3:
        return 'P3';
      case TaskPriority.p4:
        return 'P4';
    }
  }

  String get label {
    switch (this) {
      case TaskPriority.p1:
        return 'Urgent & Critical';
      case TaskPriority.p2:
        return 'High Priority';
      case TaskPriority.p3:
        return 'Medium Priority';
      case TaskPriority.p4:
        return 'Low Priority';
    }
  }

  Color get color {
    switch (this) {
      case TaskPriority.p1:
        return const Color(0xFFF43F5E); // Rose / Red
      case TaskPriority.p2:
        return const Color(0xFFF97316); // Orange
      case TaskPriority.p3:
        return const Color(0xFF38BDF8); // Icy Blue
      case TaskPriority.p4:
        return const Color(0xFF64748B); // Slate Grey
    }
  }

  IconData get icon {
    switch (this) {
      case TaskPriority.p1:
        return Icons.priority_high_rounded;
      case TaskPriority.p2:
        return Icons.flag_rounded;
      case TaskPriority.p3:
        return Icons.outlined_flag_rounded;
      case TaskPriority.p4:
        return Icons.low_priority_rounded;
    }
  }
}
