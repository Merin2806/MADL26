import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TaskMateApp());
}

const _ink = Color(0xFF172B2A);
const _muted = Color(0xFF71817F);
const _green = Color(0xFF167D70);
const _canvas = Color(0xFFF5F8F7);
const _line = Color(0xFFE6ECEA);

class TaskMateApp extends StatelessWidget {
  const TaskMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _green,
      brightness: Brightness.light,
      primary: _green,
      surface: Colors.white,
    );
    return MaterialApp(
      title: 'TaskMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: _canvas,
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            color: _ink,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.8,
          ),
          titleLarge: TextStyle(
            color: _ink,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          bodyMedium: TextStyle(color: _ink, fontSize: 14),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF7F9F8),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _green, width: 1.5),
          ),
        ),
      ),
      home: const TaskMateDashboard(),
    );
  }
}

enum TaskPriority { low, medium, high }

enum TaskFilter { all, pending, completed }

class TaskItem {
  TaskItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.dueDate,
    this.isCompleted = false,
  });

  int id;
  String title;
  String description;
  String category;
  TaskPriority priority;
  DateTime dueDate;
  bool isCompleted;
}

List<TaskItem> _demoTasks() {
  final today = DateUtils.dateOnly(DateTime.now());
  return [
    TaskItem(
      id: 1,
      title: 'Review Q3 product roadmap',
      description: 'Align milestones with the design and engineering teams.',
      category: 'Work',
      priority: TaskPriority.high,
      dueDate: today,
    ),
    TaskItem(
      id: 2,
      title: 'Prepare presentation for Monday',
      description: 'Pull together the latest launch metrics and key takeaways.',
      category: 'Work',
      priority: TaskPriority.medium,
      dueDate: today.add(const Duration(days: 1)),
    ),
    TaskItem(
      id: 3,
      title: 'Book a table for dinner',
      description: 'Find somewhere new for Friday night.',
      category: 'Personal',
      priority: TaskPriority.low,
      dueDate: today.add(const Duration(days: 3)),
      isCompleted: true,
    ),
    TaskItem(
      id: 4,
      title: 'Send project update to Alex',
      description: 'Share progress, open questions, and the next steps.',
      category: 'Work',
      priority: TaskPriority.medium,
      dueDate: today.add(const Duration(days: 2)),
    ),
    TaskItem(
      id: 5,
      title: 'Pick up groceries',
      description: 'Coffee, fresh fruit, and ingredients for the week.',
      category: 'Personal',
      priority: TaskPriority.low,
      dueDate: today.add(const Duration(days: 4)),
    ),
  ];
}

class TaskMateDashboard extends StatefulWidget {
  const TaskMateDashboard({super.key});

  @override
  State<TaskMateDashboard> createState() => _TaskMateDashboardState();
}

class _TaskMateDashboardState extends State<TaskMateDashboard> {
  final List<TaskItem> _tasks = _demoTasks();
  final TextEditingController _searchController = TextEditingController();
  String _search = '';
  String _section = 'Dashboard';
  TaskFilter _filter = TaskFilter.all;
  int _nextId = 6;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _completedCount => _tasks.where((task) => task.isCompleted).length;

  List<TaskItem> get _visibleTasks {
    final query = _search.trim().toLowerCase();
    return _tasks.where((task) {
      final matchesSearch = task.title.toLowerCase().contains(query);
      final matchesFilter = switch (_filter) {
        TaskFilter.all => true,
        TaskFilter.pending => !task.isCompleted,
        TaskFilter.completed => task.isCompleted,
      };
      return matchesSearch && matchesFilter;
    }).toList()..sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      return a.dueDate.compareTo(b.dueDate);
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _ink,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Future<void> _openTaskForm({TaskItem? task}) async {
    final result = await showDialog<TaskItem>(
      context: context,
      builder: (context) => TaskFormDialog(task: task),
    );
    if (result == null || !mounted) return;
    setState(() {
      if (task == null) {
        result.id = _nextId++;
        _tasks.insert(0, result);
      } else {
        final index = _tasks.indexWhere((item) => item.id == task.id);
        if (index != -1) _tasks[index] = result;
      }
    });
    _showMessage(task == null ? 'Task added' : 'Task updated');
  }

  void _toggleTask(TaskItem task, bool? value) {
    setState(() => task.isCompleted = value ?? !task.isCompleted);
    _showMessage(task.isCompleted ? 'Task completed' : 'Task moved to pending');
  }

  Future<void> _deleteTask(TaskItem task) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this task?'),
        content: Text('“${task.title}” will be removed from your list.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB33E3E),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete != true || !mounted) return;
    setState(() => _tasks.removeWhere((item) => item.id == task.id));
    _showMessage('Task deleted');
  }

  Future<void> _resetTasks() async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset demo data?'),
        content: const Text(
          'This replaces your current session tasks with the original sample tasks.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset tasks'),
          ),
        ],
      ),
    );
    if (shouldReset != true || !mounted) return;
    setState(() {
      _tasks
        ..clear()
        ..addAll(_demoTasks());
      _nextId = 6;
      _search = '';
      _searchController.clear();
      _filter = TaskFilter.all;
      _section = 'Dashboard';
    });
    _showMessage('Demo tasks restored');
  }

  void _selectSection(String section) {
    setState(() {
      _section = section;
      _filter = switch (section) {
        'Completed' => TaskFilter.completed,
        'All Tasks' || 'Dashboard' => TaskFilter.all,
        _ => _filter,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewportSize = MediaQuery.sizeOf(context);
    if (viewportSize.isEmpty) return const SizedBox.shrink();
    final viewportWidth = viewportSize.width;
    final isWide = viewportWidth >= 1000;
    final isCompact = viewportWidth < 680;
    final horizontalPadding = isCompact ? 36.0 : 76.0;
    final contentWidth = (viewportWidth - (isWide ? 252 : 0))
        .clamp(0.0, 1440.0)
        .toDouble();
    final summaryWidth = (contentWidth - horizontalPadding)
        .clamp(0.0, 1440.0)
        .toDouble();
    return Scaffold(
      drawer: isWide ? null : Drawer(child: _sidebar(isDrawer: true)),
      body: Row(
        children: [
          if (isWide) SizedBox(width: 252, child: _sidebar()),
          Expanded(
            child: SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1440),
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            isCompact ? 18 : 38,
                            isCompact ? 14 : 26,
                            isCompact ? 18 : 38,
                            36,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _topBar(isWide: isWide, isCompact: isCompact),
                              const SizedBox(height: 30),
                              if (_section == 'Settings')
                                _settingsPanel()
                              else ...[
                                _welcomeHeader(isCompact),
                                const SizedBox(height: 26),
                                _summaryCards(isCompact, summaryWidth),
                                const SizedBox(height: 32),
                                _taskSection(isCompact),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebar({bool isDrawer = false}) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: _line)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: _green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 11),
                  const Text(
                    'taskmate',
                    style: TextStyle(
                      color: _ink,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.7,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 42),
              const Padding(
                padding: EdgeInsets.only(left: 12, bottom: 12),
                child: Text(
                  'WORKSPACE',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.3,
                  ),
                ),
              ),
              for (final item in const [
                ('Dashboard', Icons.grid_view_rounded),
                ('All Tasks', Icons.checklist_rounded),
                ('Completed', Icons.task_alt_rounded),
              ])
                _navItem(item.$1, item.$2, isDrawer: isDrawer),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F8F6),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.wb_sunny_outlined, color: _green, size: 20),
                    SizedBox(height: 10),
                    Text(
                      'Small steps, big progress.',
                      style: TextStyle(
                        color: _ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'You’re doing great. Keep it up!',
                      style: TextStyle(color: _muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _navItem('Settings', Icons.settings_outlined, isDrawer: isDrawer),
              if (isDrawer)
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    tooltip: 'Close navigation',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(String label, IconData icon, {required bool isDrawer}) {
    final selected = _section == label;
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Material(
        color: selected ? const Color(0xFFEAF5F2) : Colors.transparent,
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          borderRadius: BorderRadius.circular(11),
          onTap: () {
            _selectSection(label);
            if (isDrawer) Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 19, color: selected ? _green : _muted),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? _green : const Color(0xFF52615F),
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                if (label == 'All Tasks') ...[
                  const Spacer(),
                  Text(
                    '${_tasks.length}',
                    style: const TextStyle(color: _muted, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar({required bool isWide, required bool isCompact}) {
    final date = DateTime.now();
    final dateText = MaterialLocalizations.of(context).formatFullDate(date);
    return Row(
      children: [
        if (!isWide) ...[
          Builder(
            builder: (context) => IconButton(
              tooltip: 'Open navigation',
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(Icons.menu_rounded, color: _ink),
            ),
          ),
          if (!isCompact) const SizedBox(width: 8),
        ],
        if (!isCompact)
          Text(dateText, style: const TextStyle(color: _muted, fontSize: 13)),
        const Spacer(),
        Container(
          height: 38,
          width: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFDDEFEA),
            borderRadius: BorderRadius.circular(13),
          ),
          alignment: Alignment.center,
          child: const Text(
            'TM',
            style: TextStyle(
              color: _green,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _welcomeHeader(bool compact) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 18,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _section == 'Completed' ? 'Nice work!' : 'Good morning, Alex 👋',
              style: TextStyle(
                color: _ink,
                fontSize: compact ? 25 : 30,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.9,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              _section == 'Completed'
                  ? 'Here’s everything you’ve checked off.'
                  : 'A little progress each day adds up. Let’s make today count.',
              style: const TextStyle(color: _muted, fontSize: 13, height: 1.5),
            ),
          ],
        ),
        FilledButton.icon(
          key: const Key('add-task-button'),
          onPressed: _openTaskForm,
          icon: const Icon(Icons.add_rounded, size: 19),
          label: const Text('Add task'),
          style: FilledButton.styleFrom(
            backgroundColor: _green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryCards(bool compact, double availableWidth) {
    final pending = _tasks.length - _completedCount;
    final rate = _tasks.isEmpty
        ? 0
        : (_completedCount / _tasks.length * 100).round();
    final cards = [
      _SummaryData(
        'Total tasks',
        '${_tasks.length}',
        Icons.sticky_note_2_outlined,
        const Color(0xFFE9F3F1),
        _green,
        'Across your list',
      ),
      _SummaryData(
        'Completed',
        '$_completedCount',
        Icons.task_alt_rounded,
        const Color(0xFFEAF5EE),
        const Color(0xFF438A5C),
        'You’re on a roll',
      ),
      _SummaryData(
        'Pending',
        '$pending',
        Icons.hourglass_bottom_rounded,
        const Color(0xFFFFF4E8),
        const Color(0xFFC48236),
        'Ready when you are',
      ),
      _SummaryData(
        'Completion rate',
        '$rate%',
        Icons.trending_up_rounded,
        const Color(0xFFEEF0FB),
        const Color(0xFF6872BC),
        'Keep the momentum',
      ),
    ];
    final columns = compact ? 2 : 4;
    const gap = 14.0;
    final width =
        (availableWidth - gap * (columns - 1))
            .clamp(0.0, availableWidth)
            .toDouble() /
        columns;
    return Wrap(
      spacing: gap,
      runSpacing: gap,
      children: [
        for (final card in cards)
          SizedBox(
            width: width,
            child: _SummaryCard(data: card),
          ),
      ],
    );
  }

  Widget _taskSection(bool compact) {
    final sectionTitle = _section == 'Completed'
        ? 'Completed tasks'
        : 'Your tasks';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_section == 'Dashboard')
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'Your tasks',
                style: TextStyle(
                  color: _ink,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: () => _selectSection('All Tasks'),
                child: const Text('View all'),
              ),
            ],
          )
        else ...[
          Text(
            sectionTitle,
            style: const TextStyle(
              color: _ink,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 44,
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _search = value),
                  decoration: InputDecoration(
                    hintText: 'Search tasks',
                    hintStyle: const TextStyle(color: _muted, fontSize: 13),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      size: 19,
                      color: _muted,
                    ),
                    suffixIcon: _search.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _search = '');
                            },
                            icon: const Icon(Icons.close_rounded, size: 17),
                          ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
            if (!compact) const SizedBox(width: 14),
            if (!compact)
              Wrap(
                spacing: 6,
                children: [
                  for (final filter in TaskFilter.values) _filterChip(filter),
                ],
              ),
          ],
        ),
        if (compact) ...[
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final filter in TaskFilter.values) ...[
                  _filterChip(filter),
                  const SizedBox(width: 7),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: 14),
        if (_visibleTasks.isEmpty)
          _emptyState()
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _line),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x080D2825),
                  blurRadius: 18,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                for (var index = 0; index < _visibleTasks.length; index++)
                  _TaskRow(
                    task: _visibleTasks[index],
                    isLast: index == _visibleTasks.length - 1,
                    onToggle: (value) =>
                        _toggleTask(_visibleTasks[index], value),
                    onEdit: () => _openTaskForm(task: _visibleTasks[index]),
                    onDelete: () => _deleteTask(_visibleTasks[index]),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        Text(
          '${_visibleTasks.length} ${_visibleTasks.length == 1 ? 'task' : 'tasks'} shown',
          style: const TextStyle(color: _muted, fontSize: 11),
        ),
      ],
    );
  }

  Widget _filterChip(TaskFilter filter) {
    final label = switch (filter) {
      TaskFilter.all => 'All',
      TaskFilter.pending => 'Pending',
      TaskFilter.completed => 'Completed',
    };
    final selected = _filter == filter;
    return ChoiceChip(
      key: Key('filter-${filter.name}'),
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _filter = filter),
      showCheckmark: false,
      labelStyle: TextStyle(
        color: selected ? Colors.white : _muted,
        fontSize: 12,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 7),
      side: BorderSide(color: selected ? _green : _line),
      backgroundColor: Colors.white,
      selectedColor: _green,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _emptyState() {
    final isSearch = _search.isNotEmpty;
    final noTasks = _tasks.isEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 42, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _line),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF5F2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isSearch ? Icons.search_off_rounded : Icons.checklist_rounded,
              color: _green,
              size: 25,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            isSearch
                ? 'No tasks match your search'
                : noTasks
                ? 'Your list is clear'
                : _filter == TaskFilter.completed
                ? 'Nothing completed yet'
                : 'You’re all caught up',
            style: const TextStyle(color: _ink, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            isSearch
                ? 'Try a different title or clear your search.'
                : noTasks
                ? 'Add a task to get your day moving.'
                : 'There are no tasks in this view right now.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: _muted, fontSize: 12),
          ),
          if (noTasks && !isSearch) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _openTaskForm,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add your first task'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _settingsPanel() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              color: _ink,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Manage your TaskMate demo workspace.',
            style: TextStyle(color: _muted, fontSize: 13),
          ),
          const SizedBox(height: 24),
          const Divider(color: _line),
          const SizedBox(height: 10),
          const Text(
            'Your data',
            style: TextStyle(color: _ink, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 7),
          const Text(
            'Tasks are kept in memory for this session and are not saved permanently.',
            style: TextStyle(color: _muted, fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            key: const Key('reset-demo-data-button'),
            onPressed: _resetTasks,
            icon: const Icon(Icons.restart_alt_rounded),
            label: const Text('Reset demo data'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF9A4545),
              side: const BorderSide(color: Color(0xFFE9D8D8)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryData {
  const _SummaryData(
    this.title,
    this.value,
    this.icon,
    this.background,
    this.foreground,
    this.caption,
  );

  final String title;
  final String value;
  final IconData icon;
  final Color background;
  final Color foreground;
  final String caption;
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.data});

  final _SummaryData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 142),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x070D2825),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  data.title,
                  style: const TextStyle(color: _muted, fontSize: 12),
                ),
              ),
              Container(
                width: 31,
                height: 31,
                decoration: BoxDecoration(
                  color: data.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(data.icon, color: data.foreground, size: 17),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            data.value,
            key: Key(
              'summary-${data.title.toLowerCase().replaceAll(' ', '-')}',
            ),
            style: const TextStyle(
              color: _ink,
              fontSize: 26,
              height: 1.1,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            data.caption,
            style: const TextStyle(color: _muted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.task,
    required this.isLast,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final TaskItem task;
  final bool isLast;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final priorityColor = switch (task.priority) {
      TaskPriority.low => const Color(0xFF558260),
      TaskPriority.medium => const Color(0xFFB47A2B),
      TaskPriority.high => const Color(0xFFB34B4B),
    };
    final priorityLabel = switch (task.priority) {
      TaskPriority.low => 'Low',
      TaskPriority.medium => 'Medium',
      TaskPriority.high => 'High',
    };
    final dueDate = MaterialLocalizations.of(context)
        .formatShortDate(task.dueDate);
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: task.isCompleted ? 0.72 : 1,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 13, 11, 13),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Checkbox(
                    key: Key('task-checkbox-${task.id}'),
                    value: task.isCompleted,
                    onChanged: onToggle,
                    activeColor: _green,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        key: Key('task-title-${task.id}'),
                        style: TextStyle(
                          color: task.isCompleted ? _muted : _ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        task.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 7,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _MetaPill(
                            icon: Icons.folder_outlined,
                            text: task.category,
                            color: const Color(0xFF657875),
                            background: const Color(0xFFF1F5F4),
                          ),
                          _MetaPill(
                            icon: Icons.flag_outlined,
                            text: '$priorityLabel priority',
                            color: priorityColor,
                            background: priorityColor.withValues(alpha: 0.09),
                          ),
                          _MetaPill(
                            icon: Icons.calendar_today_outlined,
                            text: dueDate,
                            color: const Color(0xFF657875),
                            background: const Color(0xFFF1F5F4),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  tooltip: 'Task actions',
                  icon: const Icon(Icons.more_horiz_rounded, color: _muted),
                  onSelected: (action) {
                    if (action == 'edit') onEdit();
                    if (action == 'delete') onDelete();
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit task')),
                    PopupMenuItem(value: 'delete', child: Text('Delete task')),
                  ],
                ),
              ],
            ),
            if (!isLast)
              const Padding(
                padding: EdgeInsets.only(top: 13),
                child: Divider(height: 1, color: _line),
              ),
          ],
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.icon,
    required this.text,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final String text;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: color, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class TaskFormDialog extends StatefulWidget {
  const TaskFormDialog({super.key, this.task});

  final TaskItem? task;

  @override
  State<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends State<TaskFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late String _category;
  late TaskPriority _priority;
  late DateTime _dueDate;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(
      text: task?.description ?? '',
    );
    _category = task?.category ?? 'Work';
    _priority = task?.priority ?? TaskPriority.medium;
    _dueDate = task?.dueDate ?? DateUtils.dateOnly(DateTime.now());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _chooseDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (selected != null) setState(() => _dueDate = selected);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final oldTask = widget.task;
    Navigator.pop(
      context,
      TaskItem(
        id: oldTask?.id ?? 0,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _category,
        priority: _priority,
        dueDate: _dueDate,
        isCompleted: oldTask?.isCompleted ?? false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.task != null;
    return AlertDialog(
      title: Text(editing ? 'Edit task' : 'Add a task'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  key: const Key('task-title-field'),
                  controller: _titleController,
                  autofocus: true,
                  maxLength: 80,
                  decoration: const InputDecoration(
                    labelText: 'Task title',
                    hintText: 'What needs to get done?',
                    counterText: '',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter a task title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 13),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 2,
                  maxLength: 180,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Add a little more detail',
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: const [
                    DropdownMenuItem(value: 'Work', child: Text('Work')),
                    DropdownMenuItem(
                      value: 'Personal',
                      child: Text('Personal'),
                    ),
                    DropdownMenuItem(value: 'Study', child: Text('Study')),
                    DropdownMenuItem(value: 'Health', child: Text('Health')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _category = value);
                  },
                ),
                const SizedBox(height: 13),
                DropdownButtonFormField<TaskPriority>(
                  initialValue: _priority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: const [
                    DropdownMenuItem(
                      value: TaskPriority.low,
                      child: Text('Low'),
                    ),
                    DropdownMenuItem(
                      value: TaskPriority.medium,
                      child: Text('Medium'),
                    ),
                    DropdownMenuItem(
                      value: TaskPriority.high,
                      child: Text('High'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _priority = value);
                  },
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: _chooseDate,
                  icon: const Icon(Icons.calendar_today_outlined, size: 17),
                  label: Text(
                    'Due ${MaterialLocalizations.of(context).formatMediumDate(_dueDate)}',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('save-task-button'),
          onPressed: _submit,
          child: Text(editing ? 'Save changes' : 'Add task'),
        ),
      ],
    );
  }
}
