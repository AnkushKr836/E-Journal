import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/task_item.dart';
import '../domain/models/task_status.dart';
import '../domain/models/task_priority.dart';
import 'providers/tasks_provider.dart';
import 'widgets/kanban_column.dart';
import 'widgets/task_card.dart';
import 'widgets/task_form_dialog.dart';
import '../../../core/widgets/glass_container.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  bool _isBoardView = true; // true: Kanban Board, false: List View
  final TextEditingController _searchController = TextEditingController();

  final List<String> _tags = ['All', 'Work', 'Dev', 'Health', 'Pantry', 'Chore', 'Study'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openTaskForm([TaskItem? task, TaskStatus? defaultStatus]) {
    showDialog(
      context: context,
      builder: (ctx) => TaskFormDialog(
        initialTask: task,
        defaultStatus: defaultStatus,
        onSave: (savedTask) {
          if (task == null) {
            ref.read(tasksProvider.notifier).addTask(savedTask);
          } else {
            ref.read(tasksProvider.notifier).updateTask(savedTask);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allTasks = ref.watch(tasksProvider);
    final filteredTasks = ref.watch(filteredTasksProvider);
    final currentTagFilter = ref.watch(taskTagFilterProvider);
    final currentPriorityFilter = ref.watch(taskPriorityFilterProvider);

    // Compute metrics
    final totalCount = allTasks.length;
    final inProgressCount = allTasks.where((t) => t.status == TaskStatus.inProgress).length;
    final completedCount = allTasks.where((t) => t.status == TaskStatus.completed).length;
    final totalFocusSeconds = allTasks.fold<int>(0, (sum, t) => sum + t.elapsedSeconds);
    final totalFocusMinutes = totalFocusSeconds ~/ 60;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header & Controls
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tasks & Focus Board',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Organize, time-block, and execute daily routines with zero friction.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // View Mode Toggle (Kanban vs List)
              GlassContainer(
                borderRadius: 18,
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _buildViewToggle(Icons.view_kanban_rounded, 'Board', _isBoardView, () {
                      setState(() => _isBoardView = true);
                    }),
                    _buildViewToggle(Icons.view_agenda_rounded, 'List', !_isBoardView, () {
                      setState(() => _isBoardView = false);
                    }),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Add Task Button
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF38BDF8),
                  foregroundColor: const Color(0xFF0A0F1D),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => _openTaskForm(),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('New Task', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2. Metrics Summary Ribbon
          Row(
            children: [
              _buildMetricChip(Icons.format_list_bulleted_rounded, '$totalCount Total', Colors.blueGrey),
              const SizedBox(width: 10),
              _buildMetricChip(Icons.bolt_rounded, '$inProgressCount In Progress', const Color(0xFFF59E0B)),
              const SizedBox(width: 10),
              _buildMetricChip(Icons.check_circle_rounded, '$completedCount Completed', const Color(0xFF10B981)),
              const SizedBox(width: 10),
              _buildMetricChip(
                Icons.timer_rounded,
                '$totalFocusMinutes mins tracked',
                const Color(0xFF38BDF8),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 3. Search & Filter Bar
          Row(
            children: [
              // Search Input
              Expanded(
                flex: 3,
                child: GlassContainer(
                  borderRadius: 16,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Filter by task title or keyword...',
                      hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                      icon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF38BDF8)),
                      border: InputBorder.none,
                      isDense: true,
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 16),
                              onPressed: () {
                                _searchController.clear();
                                ref.read(taskSearchQueryProvider.notifier).setQuery('');
                              },
                            )
                          : null,
                    ),
                    onChanged: (val) {
                      ref.read(taskSearchQueryProvider.notifier).setQuery(val);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Priority Filter Dropdown
              GlassContainer(
                borderRadius: 16,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<TaskPriority?>(
                    value: currentPriorityFilter,
                    hint: const Text('Priority', style: TextStyle(fontSize: 12)),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Priorities', style: TextStyle(fontSize: 12))),
                      for (final p in TaskPriority.values)
                        DropdownMenuItem(
                          value: p,
                          child: Text('${p.code} - ${p.label}', style: TextStyle(fontSize: 12, color: p.color)),
                        ),
                    ],
                    onChanged: (p) => ref.read(taskPriorityFilterProvider.notifier).setPriority(p),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Tag Filter Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _tags.map((tag) {
                final isSelected = (tag == 'All' && currentTagFilter == null) || (tag == currentTagFilter);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(tag == 'All' ? 'All Tags' : '#$tag'),
                    selected: isSelected,
                    selectedColor: const Color(0xFF38BDF8).withValues(alpha: 0.25),
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? const Color(0xFF38BDF8) : null,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        ref.read(taskTagFilterProvider.notifier).setTag(tag == 'All' ? null : tag);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // 4. Main Body: Kanban Board vs List View
          Expanded(
            child: _isBoardView
                ? _buildKanbanBoard(filteredTasks)
                : _buildListView(filteredTasks),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle(IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF38BDF8) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? const Color(0xFF0A0F1D) : Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF0A0F1D) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricChip(IconData icon, String label, Color color) {
    return GlassContainer(
      borderRadius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  // Kanban Multi-Column Board
  Widget _buildKanbanBoard(List<TaskItem> tasks) {
    final todoTasks = tasks.where((t) => t.status == TaskStatus.todo).toList();
    final plannedTasks = tasks.where((t) => t.status == TaskStatus.planned).toList();
    final inProgressTasks = tasks.where((t) => t.status == TaskStatus.inProgress).toList();
    final completedTasks = tasks.where((t) => t.status == TaskStatus.completed).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KanbanColumn(
            status: TaskStatus.todo,
            tasks: todoTasks,
            onAddTask: () => _openTaskForm(null, TaskStatus.todo),
            onEditTask: (t) => _openTaskForm(t),
          ),
          const SizedBox(width: 14),
          KanbanColumn(
            status: TaskStatus.planned,
            tasks: plannedTasks,
            onAddTask: () => _openTaskForm(null, TaskStatus.planned),
            onEditTask: (t) => _openTaskForm(t),
          ),
          const SizedBox(width: 14),
          KanbanColumn(
            status: TaskStatus.inProgress,
            tasks: inProgressTasks,
            onAddTask: () => _openTaskForm(null, TaskStatus.inProgress),
            onEditTask: (t) => _openTaskForm(t),
          ),
          const SizedBox(width: 14),
          KanbanColumn(
            status: TaskStatus.completed,
            tasks: completedTasks,
            onAddTask: () => _openTaskForm(null, TaskStatus.completed),
            onEditTask: (t) => _openTaskForm(t),
          ),
        ],
      ),
    );
  }

  // Compact List View
  Widget _buildListView(List<TaskItem> tasks) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_rounded, size: 48, color: Colors.grey.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            const Text('No tasks match the active filters', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskCard(
          key: ValueKey(task.id),
          task: task,
          onEdit: () => _openTaskForm(task),
        );
      },
    );
  }
}
