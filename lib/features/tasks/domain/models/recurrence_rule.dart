enum RecurrenceType {
  none,
  daily,
  weekly,
  monthly,
  customDays;

  String get label {
    switch (this) {
      case RecurrenceType.none:
        return 'No Recurrence';
      case RecurrenceType.daily:
        return 'Daily';
      case RecurrenceType.weekly:
        return 'Weekly';
      case RecurrenceType.monthly:
        return 'Monthly';
      case RecurrenceType.customDays:
        return 'Custom Interval';
    }
  }
}

class RecurrenceRule {
  final RecurrenceType type;
  final int interval; // e.g. every 1 day, every 2 weeks, every 3 days
  final List<int> daysOfWeek; // 1 = Monday, 7 = Sunday
  final DateTime? nextDueDate;

  const RecurrenceRule({
    this.type = RecurrenceType.none,
    this.interval = 1,
    this.daysOfWeek = const [],
    this.nextDueDate,
  });

  bool get isRecurring => type != RecurrenceType.none;

  String get description {
    switch (type) {
      case RecurrenceType.none:
        return 'One-time task';
      case RecurrenceType.daily:
        return interval == 1 ? 'Repeats Daily' : 'Repeats Every $interval Days';
      case RecurrenceType.weekly:
        if (daysOfWeek.isEmpty) return 'Repeats Weekly';
        const dayNames = {1: 'Mon', 2: 'Tue', 3: 'Wed', 4: 'Thu', 5: 'Fri', 6: 'Sat', 7: 'Sun'};
        final names = daysOfWeek.map((d) => dayNames[d] ?? '').where((n) => n.isNotEmpty).join(', ');
        return 'Repeats Weekly on $names';
      case RecurrenceType.monthly:
        return interval == 1 ? 'Repeats Monthly' : 'Repeats Every $interval Months';
      case RecurrenceType.customDays:
        return 'Repeats Every $interval Days';
    }
  }

  DateTime calculateNextOccurrence(DateTime from) {
    switch (type) {
      case RecurrenceType.none:
        return from;
      case RecurrenceType.daily:
      case RecurrenceType.customDays:
        return from.add(Duration(days: interval > 0 ? interval : 1));
      case RecurrenceType.weekly:
        if (daysOfWeek.isEmpty) {
          return from.add(Duration(days: 7 * (interval > 0 ? interval : 1)));
        }
        // Find next day in the list
        for (int i = 1; i <= 7 * (interval > 0 ? interval : 1); i++) {
          final candidate = from.add(Duration(days: i));
          if (daysOfWeek.contains(candidate.weekday)) {
            return candidate;
          }
        }
        return from.add(const Duration(days: 7));
      case RecurrenceType.monthly:
        return DateTime(
          from.year,
          from.month + (interval > 0 ? interval : 1),
          from.day,
          from.hour,
          from.minute,
        );
    }
  }

  RecurrenceRule copyWith({
    RecurrenceType? type,
    int? interval,
    List<int>? daysOfWeek,
    DateTime? nextDueDate,
  }) {
    return RecurrenceRule(
      type: type ?? this.type,
      interval: interval ?? this.interval,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      nextDueDate: nextDueDate ?? this.nextDueDate,
    );
  }
}
