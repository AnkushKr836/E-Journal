import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/glass_container.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  // Navigation: 0: Schedule/Calendar, 1: Tasks, 2: Chores, 3: Grocery, 4: Budget, 5: Nutrition
  int _currentNavIndex = 0;
  String _calendarViewMode = 'Week'; // Today, Week, Month

  // --- Chore Timer State (Laundry) ---
  int _timerSeconds = 45 * 60;
  Timer? _timer;
  bool _isTimerRunning = false;

  // --- Task State ---
  final List<Map<String, dynamic>> _tasks = [
    {'title': 'Review project architecture & PRD', 'tag': 'Work', 'priority': 'P1', 'done': true},
    {'title': 'Grocery shopping for weekly meal prep', 'tag': 'Pantry', 'priority': 'P2', 'done': false},
    {'title': '30-minute cardio & health workout', 'tag': 'Health', 'priority': 'P2', 'done': false},
    {'title': 'Put bed linens in washing machine', 'tag': 'Chore', 'priority': 'P3', 'done': true},
    {'title': 'Read Chapter 4 of System Design', 'tag': 'Study', 'priority': 'P3', 'done': false},
  ];

  // --- Grocery State ---
  final List<Map<String, dynamic>> _groceries = [
    {'name': 'Oat Milk (1L)', 'category': 'Dairy', 'price': 3.50, 'bought': false},
    {'name': 'Greek Yogurt', 'category': 'Dairy', 'price': 4.20, 'bought': true},
    {'name': 'Avocados (Bag of 4)', 'category': 'Produce', 'price': 5.00, 'bought': false},
    {'name': 'Chicken Breast (1kg)', 'category': 'Meat', 'price': 9.80, 'bought': false},
    {'name': 'Whole Grain Sourdough', 'category': 'Bakery', 'price': 3.90, 'bought': true},
  ];

  // --- Nutrition & Hydration ---
  final int _caloriesConsumed = 1450;
  final int _calorieGoal = 2200;
  int _waterGlasses = 5;
  final int _waterGoal = 8;

  // --- Budget State ---
  final double _monthlyBudget = 2500.0;
  final double _monthlySpent = 1620.0;
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

  void _addNewTaskDialog() {
    final controller = TextEditingController();
    String priority = 'P2';
    String tag = 'General';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Add New Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  hintText: 'e.g., Clean work desk',
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
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF38BDF8),
                foregroundColor: Colors.black,
              ),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return Scaffold(
      body: Stack(
        children: [
          // Ambient Radiant Background for rich Frosted Glass Refraction
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? const [
                          Color(0xFF030712), // Cosmic Black
                          Color(0xFF0A1128), // Midnight Blue
                          Color(0xFF0F172A), // Deep Slate
                        ]
                      : const [
                          Color(0xFFF1F5F9), // Crisp Icy Slate
                          Color(0xFFE0F2FE), // Icy Sky Mist
                          Color(0xFFF8FAFC), // Pure Icy White
                        ],
                ),
              ),
            ),
          ),
          // Subtle Glowing Ambient Orbs behind the frosted glass
          Positioned(
            top: -60,
            right: 80,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF38BDF8).withValues(alpha: isDark ? 0.12 : 0.20),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 200,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? const Color(0xFF1E40AF).withValues(alpha: 0.15)
                    : const Color(0xFFBAE6FD).withValues(alpha: 0.35),
              ),
            ),
          ),

          // Main Layout Surface
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Frosted Sidebar (Matching reference image)
                  if (isDesktop)
                    _buildFrostedSidebar(isDark),

                  if (isDesktop) const SizedBox(width: 16),

                  // Main Content View
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Header & Search Bar
                        _buildTopHeader(isDark),
                        const SizedBox(height: 16),

                        // Active View (Schedule or Sub-Modules)
                        Expanded(
                          child: IndexedStack(
                            index: _currentNavIndex,
                            children: [
                              _buildScheduleView(isDark), // 0: Main Calendar View
                              _buildTasksView(isDark),    // 1: Tasks
                              _buildChoresView(isDark),   // 2: Chores
                              _buildGroceryView(isDark),  // 3: Grocery
                              _buildBudgetView(isDark),   // 4: Budget
                              _buildNutritionView(isDark),// 5: Nutrition
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // Mobile Navigation Bar
      bottomNavigationBar: isDesktop
          ? null
          : GlassContainer(
              borderRadius: 0,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMobileNavItem(Icons.calendar_today_rounded, 'Schedule', 0),
                  _buildMobileNavItem(Icons.checklist_rounded, 'Tasks', 1),
                  _buildMobileNavItem(Icons.local_laundry_service_rounded, 'Chores', 2),
                  _buildMobileNavItem(Icons.shopping_cart_outlined, 'Pantry', 3),
                  _buildMobileNavItem(Icons.wallet_outlined, 'Budget', 4),
                  _buildMobileNavItem(Icons.restaurant_outlined, 'Diet', 5),
                ],
              ),
            ),
    );
  }

  // ==========================================
  // 1. LEFT FROSTED SIDEBAR
  // ==========================================
  Widget _buildFrostedSidebar(bool isDark) {
    return GlassContainer(
      width: 255,
      height: double.infinity,
      borderRadius: 28,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo Row with brand pill
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'E-Journal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.chevron_left, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // General Section
          _buildSidebarSectionLabel('GENERAL'),
          _buildSidebarItem(Icons.grid_view_rounded, 'Schedule', 0),
          _buildSidebarItem(Icons.checklist_rounded, 'Tasks & Habits', 1),
          _buildSidebarItem(Icons.cleaning_services_rounded, 'Chores & Timers', 2, badge: _isTimerRunning ? 'Active' : null),
          _buildSidebarItem(Icons.shopping_basket_rounded, 'Pantry & Grocery', 3),
          _buildSidebarItem(Icons.account_balance_wallet_rounded, 'Budget & Finance', 4),
          _buildSidebarItem(Icons.restaurant_rounded, 'Nutrition & Macros', 5),

          const SizedBox(height: 24),

          // Tools Section
          _buildSidebarSectionLabel('TOOLS & SETTINGS'),
          // Theme Toggle Item
          ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            leading: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              size: 20,
              color: const Color(0xFF38BDF8),
            ),
            title: Text(
              isDark ? 'Light Theme' : 'Dark Theme',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                isDark ? 'Dark' : 'Light',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8)),
              ),
            ),
            onTap: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
          ),
          _buildSidebarItem(Icons.settings_outlined, 'Preferences', 6),

          const Spacer(),

          // User Profile Card at bottom of sidebar
          GlassContainer(
            borderRadius: 16,
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                  child: const Text('AK', style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Ankush', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('Pro Life-OS', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ),
                const Icon(Icons.logout_rounded, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
          color: Colors.grey.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String label, int index, {String? badge}) {
    final isSelected = _currentNavIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF38BDF8).withValues(alpha: 0.18)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: isSelected
            ? Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4), width: 1)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        leading: Icon(
          icon,
          size: 20,
          color: isSelected ? const Color(0xFF38BDF8) : (Colors.grey),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? const Color(0xFF38BDF8) : null,
            fontSize: 13,
          ),
        ),
        trailing: badge != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(badge, style: const TextStyle(fontSize: 10, color: Colors.greenAccent, fontWeight: FontWeight.bold)),
              )
            : null,
        onTap: () {
          if (index <= 5) {
            setState(() => _currentNavIndex = index);
          }
        },
      ),
    ),
  );
  }

  Widget _buildMobileNavItem(IconData icon, String label, int index) {
    final isSelected = _currentNavIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentNavIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 22,
            color: isSelected ? const Color(0xFF38BDF8) : Colors.grey,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color(0xFF38BDF8) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 2. TOP HEADER & SEARCH BAR
  // ==========================================
  Widget _buildTopHeader(bool isDark) {
    return Row(
      children: [
        // Frosted Search Bar with embedded pills
        Expanded(
          child: GlassContainer(
            borderRadius: 30,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: Color(0xFF38BDF8), size: 22),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Search anything in your day...',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
                // Filter pills inside the search bar (like reference image)
                _buildSearchFilterPill('Tasks'),
                const SizedBox(width: 6),
                _buildSearchFilterPill('Chores'),
                const SizedBox(width: 6),
                _buildSearchFilterPill('Diet'),
                const SizedBox(width: 6),
                _buildSearchFilterPill('Finance'),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Action Buttons: Theme Switcher, Notifications, Add Event
        GlassContainer(
          borderRadius: 24,
          padding: const EdgeInsets.all(10),
          onTap: () {
            ref.read(themeModeProvider.notifier).toggleTheme();
          },
          child: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            size: 20,
            color: const Color(0xFF38BDF8),
          ),
        ),
        const SizedBox(width: 10),
        GlassContainer(
          borderRadius: 24,
          padding: const EdgeInsets.all(10),
          child: const Stack(
            children: [
              Icon(Icons.notifications_outlined, size: 20),
              Positioned(
                top: 0,
                right: 0,
                child: CircleAvatar(radius: 4, backgroundColor: Color(0xFF38BDF8)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Prominent Icy Blue Action Button
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF38BDF8),
            foregroundColor: const Color(0xFF0A0F1D),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
          onPressed: _addNewTaskDialog,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Add Log', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildSearchFilterPill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2), width: 0.8),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }

  // ==========================================
  // 3. MAIN SCHEDULE VIEW (Mirroring the Reference Image!)
  // ==========================================
  Widget _buildScheduleView(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Row: "Stay up to date, Ankush" + Date & View Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stay up to date, Ankush',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                ),
                const SizedBox(height: 6),
                // Date range pill
                GlassContainer(
                  borderRadius: 18,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'October 19 - 25, 2026',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                    ],
                  ),
                ),
              ],
            ),
            // Today / Week / Month Switcher
            GlassContainer(
              borderRadius: 20,
              padding: const EdgeInsets.all(4),
              child: Row(
                children: ['Today', 'Week', 'Month'].map((mode) {
                  final isCurrent = _calendarViewMode == mode;
                  return GestureDetector(
                    onTap: () => setState(() => _calendarViewMode = mode),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? const Color(0xFF38BDF8)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        mode,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isCurrent
                              ? const Color(0xFF0A0F1D)
                              : (isDark ? Colors.white70 : Colors.black87),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // The 7-Day Header Row
        _buildDaysHeaderRow(isDark),
        const SizedBox(height: 12),

        // Timeline Schedule Grid
        Expanded(
          child: Stack(
            children: [
              // Scrollable Timeline Grid
              SingleChildScrollView(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time Labels Column (07:00, 07:30, 08:00, 08:30...)
                    _buildTimeLabelsColumn(),
                    const SizedBox(width: 10),

                    // Columns for Monday through Sunday
                    Expanded(child: _buildDayColumn(0, isDark)), // Mon
                    const SizedBox(width: 8),
                    Expanded(child: _buildDayColumn(1, isDark)), // Tue
                    const SizedBox(width: 8),
                    Expanded(child: _buildDayColumn(2, isDark)), // Wed
                    const SizedBox(width: 8),
                    Expanded(child: _buildDayColumn(3, isDark, isToday: true)), // Thu (Today)
                    const SizedBox(width: 8),
                    Expanded(child: _buildDayColumn(4, isDark)), // Fri
                    const SizedBox(width: 8),
                    Expanded(child: _buildDayColumn(5, isDark)), // Sat
                    const SizedBox(width: 8),
                    Expanded(child: _buildDayColumn(6, isDark)), // Sun
                  ],
                ),
              ),

              // Glowing Current Time Line (Like the 07:21 line in the reference image!)
              Positioned(
                top: 85,
                left: 0,
                right: 0,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF43F5E), // Pink indicator pill
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF43F5E).withValues(alpha: 0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Text(
                        '08:45',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1.5,
                        margin: const EdgeInsets.only(left: 4),
                        color: const Color(0xFFF43F5E).withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDaysHeaderRow(bool isDark) {
    final days = [
      {'name': 'MONDAY', 'date': '19/10'},
      {'name': 'TUESDAY', 'date': '20/10'},
      {'name': 'WEDNESDAY', 'date': '21/10'},
      {'name': 'THU', 'date': '22/10', 'today': true},
      {'name': 'FRIDAY', 'date': '23/10'},
      {'name': 'SATURDAY', 'date': '24/10'},
      {'name': 'SUNDAY', 'date': '25/10'},
    ];

    return Row(
      children: [
        const SizedBox(width: 48), // align with time labels
        for (var d in days) ...[
          Expanded(
            child: GlassContainer(
              borderRadius: 16,
              padding: const EdgeInsets.symmetric(vertical: 8),
              customColor: d['today'] == true
                  ? (isDark ? const Color(0xFF1E293B) : const Color(0xFF0F172A))
                  : null,
              child: Column(
                children: [
                  Text(
                    d['name'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: d['today'] == true ? const Color(0xFF38BDF8) : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    d['date'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: d['today'] == true ? Colors.white : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (d != days.last) const SizedBox(width: 8),
        ],
      ],
    );
  }

  Widget _buildTimeLabelsColumn() {
    final times = ['07:00', '07:30', '08:00', '08:30', '09:00', '09:30', '10:00', '10:30', '11:00', '11:30', '12:00'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var t in times)
          Container(
            height: 60,
            alignment: Alignment.topRight,
            child: Text(
              t,
              style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ),
      ],
    );
  }

  Widget _buildDayColumn(int dayIndex, bool isDark, {bool isToday = false}) {
    // Generate life-logging blocks based on column
    return Column(
      children: [
        if (dayIndex == 0) ...[
          _buildScheduleCard(
            title: 'Morning Yoga & Water',
            subtitle: 'Health & Hydration',
            time: '07:00 - 07:30',
            color: const Color(0xFF38BDF8),
            status: 'Done',
            icon: Icons.self_improvement_rounded,
          ),
          const SizedBox(height: 12),
          _buildScheduleCard(
            title: 'Laundry Cycle 🧺',
            subtitle: 'Bed Linens & Gym Clothes',
            time: '08:30 - 09:15',
            color: const Color(0xFFF59E0B),
            status: _isTimerRunning ? '$_timerSeconds s' : 'Ready',
            icon: Icons.local_laundry_service_rounded,
            onAction: _toggleTimer,
            actionLabel: _isTimerRunning ? 'Pause' : 'Start',
          ),
        ],
        if (dayIndex == 1) ...[
          _buildScheduleCard(
            title: 'Macro Breakfast',
            subtitle: '450 kcal • 35g Protein',
            time: '07:30 - 08:15',
            color: const Color(0xFF10B981),
            status: 'Logged',
            icon: Icons.egg_alt_rounded,
          ),
          const SizedBox(height: 12),
          _buildScheduleCard(
            title: 'System Design Deep Work',
            subtitle: 'E-Journal Architecture',
            time: '09:00 - 11:00',
            color: const Color(0xFF6366F1),
            status: 'In progress...',
            icon: Icons.code_rounded,
          ),
        ],
        if (dayIndex == 2) ...[
          _buildScheduleCard(
            title: 'Supermarket Run',
            subtitle: 'Pantry Restock • \$65 est.',
            time: '08:00 - 08:45',
            color: const Color(0xFF0EA5E9),
            status: '12 items',
            icon: Icons.shopping_cart_rounded,
          ),
        ],
        if (dayIndex == 3) ...[
          _buildScheduleCard(
            title: 'Cardio & Step Count',
            subtitle: '5,000 steps target',
            time: '07:00 - 08:00',
            color: const Color(0xFFF43F5E),
            status: 'Active',
            icon: Icons.fitness_center_rounded,
            isHighlighted: true,
          ),
          const SizedBox(height: 12),
          _buildScheduleCard(
            title: 'Budget & Bill Review',
            subtitle: 'WiFi, Rent & Subscriptions',
            time: '09:00 - 10:00',
            color: const Color(0xFF38BDF8),
            status: '\$1,620 spent',
            icon: Icons.wallet_rounded,
          ),
        ],
        if (dayIndex == 4) ...[
          _buildScheduleCard(
            title: 'Goa Trip Itinerary',
            subtitle: 'Flight booking & Hotel check',
            time: '08:00 - 09:30',
            color: const Color(0xFF8B5CF6),
            status: 'Planning',
            icon: Icons.flight_takeoff_rounded,
          ),
        ],
        if (dayIndex == 5) ...[
          _buildScheduleCard(
            title: 'Deep Clean AC Filter',
            subtitle: 'Home Maintenance (90d)',
            time: '09:00 - 09:45',
            color: const Color(0xFFF59E0B),
            status: 'Chore',
            icon: Icons.cleaning_services_rounded,
          ),
        ],
        if (dayIndex == 6) ...[
          _buildScheduleCard(
            title: 'Weekly Reflection',
            subtitle: 'Expenses & Habit Review',
            time: '10:00 - 11:00',
            color: const Color(0xFF38BDF8),
            status: 'Upcoming',
            icon: Icons.auto_stories_rounded,
          ),
        ],
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildScheduleCard({
    required String title,
    required String subtitle,
    required String time,
    required Color color,
    required String status,
    required IconData icon,
    bool isHighlighted = false,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    return GlassContainer(
      borderRadius: 18,
      padding: const EdgeInsets.all(12),
      glow: isHighlighted,
      customBorderColor: isHighlighted ? color.withValues(alpha: 0.6) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 13),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: color),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
          const SizedBox(height: 6),
          Text(
            time,
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: color),
          ),
          if (onAction != null && actionLabel != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 26,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: color.withValues(alpha: 0.2),
                  foregroundColor: color,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: onAction,
                child: Text(actionLabel, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // 4. SUB-MODULE VIEWS (Tasks, Chores, etc.)
  // ==========================================
  Widget _buildTasksView(bool isDark) {
    return ListView(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Daily Tasks & Habits', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF38BDF8), foregroundColor: Colors.black),
              onPressed: _addNewTaskDialog,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Task'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        for (var task in _tasks)
          GlassContainer(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            borderRadius: 16,
            child: CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: task['done'],
              activeColor: const Color(0xFF38BDF8),
              title: Text(
                task['title'],
                style: TextStyle(
                  decoration: task['done'] ? TextDecoration.lineThrough : null,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text('Category: ${task['tag']} • Priority: ${task['priority']}'),
              onChanged: (val) => setState(() => task['done'] = val ?? false),
            ),
          ),
      ],
    );
  }

  Widget _buildChoresView(bool isDark) {
    return ListView(
      children: [
        const Text('Domestic Chores & Laundry', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        // Timer Card
        GlassContainer(
          borderRadius: 24,
          glow: _isTimerRunning,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text('Active Laundry Cycle Timer', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 12),
              Text(
                _formatTimer(_timerSeconds),
                style: const TextStyle(fontSize: 52, fontWeight: FontWeight.bold, letterSpacing: -1, color: Color(0xFF38BDF8)),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFF38BDF8), foregroundColor: Colors.black),
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
      ],
    );
  }

  Widget _buildGroceryView(bool isDark) {
    double totalEstimated = 0;
    for (var item in _groceries) {
      if (!item['bought']) totalEstimated += item['price'];
    }

    return ListView(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Pantry & Grocery', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            GlassContainer(
              borderRadius: 14,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Text(
                'Basket Est: \$${totalEstimated.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF38BDF8)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        for (var item in _groceries)
          GlassContainer(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            borderRadius: 16,
            child: CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: item['bought'],
              activeColor: const Color(0xFF38BDF8),
              title: Text(
                item['name'],
                style: TextStyle(decoration: item['bought'] ? TextDecoration.lineThrough : null, fontWeight: FontWeight.w600),
              ),
              subtitle: Text('${item['category']} • \$${item['price'].toStringAsFixed(2)}'),
              onChanged: (val) => setState(() => item['bought'] = val ?? false),
            ),
          ),
      ],
    );
  }

  Widget _buildBudgetView(bool isDark) {
    final remaining = _monthlyBudget - _monthlySpent;
    final progress = (_monthlySpent / _monthlyBudget).clamp(0.0, 1.0);

    return ListView(
      children: [
        const Text('Budget & Financial Ledger', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        GlassContainer(
          borderRadius: 24,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Monthly Limit: \$2,500.00'),
                  Text(
                    'Remaining: \$${remaining.toStringAsFixed(2)}',
                    style: TextStyle(fontWeight: FontWeight.bold, color: remaining > 0 ? const Color(0xFF38BDF8) : Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
                color: const Color(0xFF38BDF8),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        for (var exp in _expenses)
          GlassContainer(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            borderRadius: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exp['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('${exp['category']} • ${exp['date']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                Text('-\$${exp['amount'].toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildNutritionView(bool isDark) {
    return ListView(
      children: [
        const Text('Nutrition & Hydration', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        GlassContainer(
          borderRadius: 24,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$_caloriesConsumed / $_calorieGoal kcal', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8))),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (_caloriesConsumed / _calorieGoal).clamp(0.0, 1.0),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
                color: const Color(0xFF38BDF8),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlassContainer(
          borderRadius: 24,
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Daily Hydration Tracker', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('$_waterGlasses of $_waterGoal glasses (${_waterGlasses * 250} ml)'),
                  ],
                ),
              ),
              IconButton.filled(
                style: IconButton.styleFrom(backgroundColor: const Color(0xFF38BDF8), foregroundColor: Colors.black),
                icon: const Icon(Icons.add),
                onPressed: () => setState(() {
                  if (_waterGlasses < 15) _waterGlasses++;
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
