import 'dart:async';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedTabIndex = 0;

  // --- Task State ---
  final List<Map<String, dynamic>> _tasks = [
    {'title': 'Review project architecture & PRD', 'tag': 'Work', 'priority': 'P1', 'done': true},
    {'title': 'Grocery shopping for meal prep', 'tag': 'Pantry', 'priority': 'P2', 'done': false},
    {'title': '30-minute cardio session', 'tag': 'Health', 'priority': 'P2', 'done': false},
    {'title': 'Put laundry into washing machine', 'tag': 'Chore', 'priority': 'P3', 'done': true},
    {'title': 'Read Chapter 4 of System Design', 'tag': 'Study', 'priority': 'P3', 'done': false},
  ];

  // --- Chore Timer State (Laundry) ---
  int _timerSeconds = 45 * 60; // 45 minutes
  Timer? _timer;
  bool _isTimerRunning = false;

  void _toggleTimer() {
    if (_isTimerRunning) {
      _timer?.cancel();
      setState(() => _isTimerRunning = false);
    } else {
      setState(() => _isTimerRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_timerSeconds > 0) {
          setState(() => _timerSeconds--);
        } else {
          timer.cancel();
          setState(() => _isTimerRunning = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🔔 Laundry cycle finished!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      });
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _timerSeconds = 45 * 60;
      _isTimerRunning = false;
    });
  }

  String _formatTimer(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  // --- Nutrition & Water State ---
  final int _caloriesConsumed = 1450;
  final int _calorieGoal = 2200;
  int _waterGlasses = 5;
  final int _waterGoal = 8;

  // --- Grocery State ---
  final List<Map<String, dynamic>> _groceries = [
    {'name': 'Oat Milk (1L)', 'category': 'Dairy', 'price': 3.50, 'bought': false},
    {'name': 'Greek Yogurt', 'category': 'Dairy', 'price': 4.20, 'bought': true},
    {'name': 'Avocados (Bag of 4)', 'category': 'Produce', 'price': 5.00, 'bought': false},
    {'name': 'Chicken Breast (1kg)', 'category': 'Meat', 'price': 9.80, 'bought': false},
    {'name': 'Whole Grain Sourdough', 'category': 'Bakery', 'price': 3.90, 'bought': true},
  ];

  // --- Budget State ---
  final double _monthlyBudget = 2500.0;
  double _monthlySpent = 1620.0;
  final List<Map<String, dynamic>> _expenses = [
    {'title': 'Weekly Supermarket Run', 'category': 'Groceries', 'amount': 65.40, 'date': 'Today'},
    {'title': 'Metro Card Top-up', 'category': 'Transit', 'amount': 25.00, 'date': 'Yesterday'},
    {'title': 'Cloud Server Hosting', 'category': 'Bills', 'amount': 15.00, 'date': '15 Oct'},
  ];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _addNewTaskDialog() {
    final controller = TextEditingController();
    String priority = 'P2';
    String tag = 'General';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add New Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  hintText: 'e.g., Water the plants',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Priority: '),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: priority,
                    items: ['P1', 'P2', 'P3', 'P4']
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => priority = val);
                    },
                  ),
                  const Spacer(),
                  DropdownButton<String>(
                    value: tag,
                    items: ['General', 'Work', 'Health', 'Chore', 'Study']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => tag = val);
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  setState(() {
                    _tasks.insert(0, {
                      'title': controller.text.trim(),
                      'tag': tag,
                      'priority': priority,
                      'done': false,
                    });
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }

  void _addNewExpenseDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String category = 'Groceries';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Log New Expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount (\$)',
                  prefixText: '\$ ',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButton<String>(
                isExpanded: true,
                value: category,
                items: ['Groceries', 'Transit', 'Dining', 'Bills', 'Shopping']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => category = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final amt = double.tryParse(amountController.text);
                if (titleController.text.trim().isNotEmpty && amt != null) {
                  setState(() {
                    _expenses.insert(0, {
                      'title': titleController.text.trim(),
                      'category': category,
                      'amount': amt,
                      'date': 'Today',
                    });
                    _monthlySpent += amt;
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Save Expense'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 750;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.menu_book_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'E-Journal',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Add Task',
            icon: const Icon(Icons.add_task_rounded),
            onPressed: _addNewTaskDialog,
          ),
          IconButton(
            tooltip: 'Log Expense',
            icon: const Icon(Icons.receipt_long_rounded),
            onPressed: _addNewExpenseDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          // Desktop Navigation Rail
          if (isDesktop)
            NavigationRail(
              selectedIndex: _selectedTabIndex,
              onDestinationSelected: (index) => setState(() => _selectedTabIndex = index),
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard_rounded),
                  label: Text('Overview'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.check_circle_outline),
                  selectedIcon: Icon(Icons.check_circle),
                  label: Text('Tasks'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.cleaning_services_outlined),
                  selectedIcon: Icon(Icons.cleaning_services),
                  label: Text('Chores'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.shopping_cart_outlined),
                  selectedIcon: Icon(Icons.shopping_cart),
                  label: Text('Pantry'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.wallet_outlined),
                  selectedIcon: Icon(Icons.wallet),
                  label: Text('Finance'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.restaurant_outlined),
                  selectedIcon: Icon(Icons.restaurant),
                  label: Text('Nutrition'),
                ),
              ],
            ),
          // Main Content View
          Expanded(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [
                _buildOverviewTab(),
                _buildTasksTab(),
                _buildChoresTab(),
                _buildGroceryTab(),
                _buildBudgetTab(),
                _buildNutritionTab(),
              ],
            ),
          ),
        ],
      ),
      // Mobile Navigation Bar
      bottomNavigationBar: isDesktop
          ? null
          : NavigationBar(
              selectedIndex: _selectedTabIndex,
              onDestinationSelected: (index) => setState(() => _selectedTabIndex = index),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.check_circle_outline),
                  selectedIcon: Icon(Icons.check_circle),
                  label: 'Tasks',
                ),
                NavigationDestination(
                  icon: Icon(Icons.cleaning_services_outlined),
                  selectedIcon: Icon(Icons.cleaning_services),
                  label: 'Chores',
                ),
                NavigationDestination(
                  icon: Icon(Icons.shopping_cart_outlined),
                  selectedIcon: Icon(Icons.shopping_cart),
                  label: 'Grocery',
                ),
                NavigationDestination(
                  icon: Icon(Icons.wallet_outlined),
                  selectedIcon: Icon(Icons.wallet),
                  label: 'Budget',
                ),
                NavigationDestination(
                  icon: Icon(Icons.restaurant_outlined),
                  selectedIcon: Icon(Icons.restaurant),
                  label: 'Diet',
                ),
              ],
            ),
      floatingActionButton: _selectedTabIndex == 1
          ? FloatingActionButton.extended(
              onPressed: _addNewTaskDialog,
              icon: const Icon(Icons.add),
              label: const Text('New Task'),
            )
          : null,
    );
  }

  // ==========================================
  // TAB 1: OVERVIEW DASHBOARD
  // ==========================================
  Widget _buildOverviewTab() {
    final completedTasks = _tasks.where((t) => t['done'] == true).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ambient Greeting Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome to E-Journal',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Your day unscattered. Everything you do, spend, eat, and plan in one place.',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Live Preview',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // High-level Metrics Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 600 ? 2 : 1);
              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.6,
                children: [
                  // Task Card
                  _buildMetricCard(
                    title: 'Daily Tasks',
                    metric: '$completedTasks of ${_tasks.length} Done',
                    subtext: '${_tasks.length - completedTasks} remaining today',
                    icon: Icons.checklist_rounded,
                    color: Colors.indigoAccent,
                    onTap: () => setState(() => _selectedTabIndex = 1),
                  ),
                  // Active Chore Timer Card
                  _buildMetricCard(
                    title: 'Laundry Cycle',
                    metric: _formatTimer(_timerSeconds),
                    subtext: _isTimerRunning ? 'Timer active' : 'Paused',
                    icon: Icons.local_laundry_service_rounded,
                    color: Colors.amberAccent,
                    onTap: () => setState(() => _selectedTabIndex = 2),
                  ),
                  // Nutrition Card
                  _buildMetricCard(
                    title: 'Daily Nutrition',
                    metric: '$_caloriesConsumed / $_calorieGoal kcal',
                    subtext: '${_calorieGoal - _caloriesConsumed} kcal left',
                    icon: Icons.bolt_rounded,
                    color: Colors.greenAccent,
                    onTap: () => setState(() => _selectedTabIndex = 5),
                  ),
                  // Budget Card
                  _buildMetricCard(
                    title: 'Monthly Budget',
                    metric: '\$${(_monthlyBudget - _monthlySpent).toStringAsFixed(0)} left',
                    subtext: '\$${_monthlySpent.toStringAsFixed(0)} spent this month',
                    icon: Icons.savings_rounded,
                    color: Colors.lightBlueAccent,
                    onTap: () => setState(() => _selectedTabIndex = 4),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Today's High Priority Tasks
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today's Priority Agenda",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: () => setState(() => _selectedTabIndex = 1),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _tasks.take(3).length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return CheckboxListTile(
                  value: task['done'],
                  title: Text(
                    task['title'],
                    style: TextStyle(
                      decoration: task['done'] ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Text('Category: ${task['tag']} • ${task['priority']}'),
                  onChanged: (val) {
                    setState(() => task['done'] = val ?? false);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String metric,
    required String subtext,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Icon(icon, color: color, size: 22),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    metric,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtext,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TAB 2: TASKS & HABITS
  // ==========================================
  Widget _buildTasksTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tasks & Daily Habits',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            FilledButton.icon(
              onPressed: _addNewTaskDialog,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _tasks.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final task = _tasks[index];
              return ListTile(
                leading: Checkbox(
                  value: task['done'],
                  onChanged: (val) {
                    setState(() => task['done'] = val ?? false);
                  },
                ),
                title: Text(
                  task['title'],
                  style: TextStyle(
                    decoration: task['done'] ? TextDecoration.lineThrough : null,
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: task['priority'] == 'P1'
                        ? Colors.redAccent.withValues(alpha: 0.2)
                        : Colors.blueAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    task['priority'],
                    style: TextStyle(
                      color: task['priority'] == 'P1' ? Colors.redAccent : Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 3: DOMESTIC CHORES & TIMERS
  // ==========================================
  Widget _buildChoresTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Domestic Chores & Timers',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        // Active Timer Card
        Card(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_laundry_service_rounded),
                    SizedBox(width: 8),
                    Text(
                      'Laundry Cycle Timer',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _formatTimer(_timerSeconds),
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton.icon(
                      onPressed: _toggleTimer,
                      icon: Icon(_isTimerRunning ? Icons.pause : Icons.play_arrow),
                      label: Text(_isTimerRunning ? 'Pause' : 'Start Timer'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: _resetTimer,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Recurring Maintenance Schedule',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        const Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.bed_rounded),
                title: Text('Wash Bed Linens'),
                subtitle: Text('Interval: Every 10 days'),
                trailing: Text('3 days left', style: TextStyle(color: Colors.orange)),
              ),
              Divider(height: 1),
              ListTile(
                leading: Icon(Icons.air_rounded),
                title: Text('Clean AC Filters'),
                subtitle: Text('Interval: Every 90 days'),
                trailing: Text('62 days left', style: TextStyle(color: Colors.green)),
              ),
              Divider(height: 1),
              ListTile(
                leading: Icon(Icons.yard_rounded),
                title: Text('Water Balcony Plants'),
                subtitle: Text('Interval: Every 2 days'),
                trailing: Text('Due Today', style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 4: GROCERIES & PANTRY
  // ==========================================
  Widget _buildGroceryTab() {
    double totalEstimated = 0;
    for (var item in _groceries) {
      if (!item['bought']) {
        totalEstimated += item['price'];
      }
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Grocery & Pantry Checklist',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Basket Est: \$${totalEstimated.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _groceries.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = _groceries[index];
              return CheckboxListTile(
                value: item['bought'],
                title: Text(
                  item['name'],
                  style: TextStyle(
                    decoration: item['bought'] ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text('${item['category']} • \$${item['price'].toStringAsFixed(2)}'),
                onChanged: (val) {
                  setState(() => item['bought'] = val ?? false);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 5: BUDGET & FINANCE
  // ==========================================
  Widget _buildBudgetTab() {
    final remaining = _monthlyBudget - _monthlySpent;
    final progress = (_monthlySpent / _monthlyBudget).clamp(0.0, 1.0);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Personal Budget & Ledger',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            FilledButton.icon(
              onPressed: _addNewExpenseDialog,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Spend'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Monthly Cap: \$2,500.00'),
                    Text(
                      'Remaining: \$${remaining.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: remaining > 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(progress * 100).toStringAsFixed(1)}% of limit spent this month',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Recent Ledger Entries',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _expenses.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final exp = _expenses[index];
              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.receipt_outlined, size: 18),
                ),
                title: Text(exp['title']),
                subtitle: Text('${exp['category']} • ${exp['date']}'),
                trailing: Text(
                  '-\$${exp['amount'].toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 6: NUTRITION & HYDRATION
  // ==========================================
  Widget _buildNutritionTab() {
    final calorieRatio = (_caloriesConsumed / _calorieGoal).clamp(0.0, 1.0);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Calorie & Hydration Journal',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$_caloriesConsumed / $_calorieGoal kcal',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text('${((1 - calorieRatio) * _calorieGoal).toInt()} kcal remaining'),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: calorieRatio,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('Protein: 120g / 150g'),
                    Text('Carbs: 180g / 220g'),
                    Text('Fats: 45g / 65g'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Hydration Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Daily Hydration',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text('$_waterGlasses of $_waterGoal glasses consumed (approx. ${_waterGlasses * 250} ml)'),
                    ],
                  ),
                ),
                IconButton.filled(
                  icon: const Icon(Icons.add),
                  tooltip: 'Drink 250ml glass',
                  onPressed: () {
                    setState(() {
                      if (_waterGlasses < 15) _waterGlasses++;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
