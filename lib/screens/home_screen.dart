import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_provider.dart';
import '../utils/theme.dart';

import '../widgets/add_task_dialog.dart';
import '../models/task.dart';
import 'package:intl/intl.dart';
import '../widgets/task_list.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: AppTheme.defaultAnimationDuration,
      vsync: this,
    );
    _slideController = AnimationController(
      duration: AppTheme.defaultAnimationDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: AppTheme.defaultAnimationCurve,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: AppTheme.defaultAnimationCurve,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskProvider);
    final activeTasks = tasks.where((task) => !task.isCompleted).toList();
    final completedTasks = tasks.where((task) => task.isCompleted).toList();
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(theme, completedTasks),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(theme, activeTasks),
              Expanded(
                child: _buildBody(theme, activeTasks),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(theme),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, List<Task> completedTasks) {
    return AppBar(
      title: FadeTransition(
        opacity: _fadeAnimation,
        child: const Text(
          'Task Reminder',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 28,
          ),
        ),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      actions: [
        if (completedTasks.isNotEmpty)
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.history, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const CompletedTasksScreen(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(1.0, 0.0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme, List<Task> activeTasks) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Tasks',
                          style: theme.textTheme.displayLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          activeTasks.isEmpty
                              ? 'Start organizing your day'
                              : '${activeTasks.length} task${activeTasks.length == 1 ? '' : 's'} to complete',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildTaskCounter(theme, activeTasks),
                ],
              ),
              const SizedBox(height: 24),
              _buildMotivationalCard(theme, activeTasks),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCounter(ThemeData theme, List<Task> activeTasks) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${activeTasks.length}',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationalCard(ThemeData theme, List<Task> activeTasks) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              activeTasks.isEmpty ? Icons.rocket_launch : Icons.trending_up,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activeTasks.isEmpty ? 'Ready to get started?' : 'Keep going!',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activeTasks.isEmpty
                      ? 'Add your first task to begin organizing your day'
                      : 'You\'re making great progress',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ThemeData theme, List<Task> activeTasks) {
    if (activeTasks.isEmpty) {
      return _buildEmptyState(theme);
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        child: Column(
          children: [
            _buildTaskListHeader(theme, activeTasks),
            Expanded(
              child: TaskList(tasks: activeTasks),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskListHeader(ThemeData theme, List<Task> activeTasks) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.check_circle_outline,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Active Tasks',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${activeTasks.length}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.accentGradient,
                ),
                child: const Icon(
                  Icons.task_alt,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'No tasks yet',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Create your first task to get started',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _showAddTaskDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Your First Task'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(ThemeData theme) {
    return FloatingActionButton.extended(
      onPressed: _showAddTaskDialog,
      label: const Text(
        'Add Task',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      icon: const Icon(Icons.add),
      backgroundColor: Colors.white,
      foregroundColor: AppTheme.primaryColor,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  void _showAddTaskDialog() async {
    final result = await showDialog<Task>(
      context: context,
      builder: (context) => const AddTaskDialog(),
    );
    if (result != null && mounted) {
      ref.read(taskProvider.notifier).addTask(result);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task "${result.title}" added successfully!'),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}

class CompletedTasksScreen extends StatelessWidget {
  const CompletedTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer(
      builder: (context, ref, child) {
        final completedTasks =
            ref.watch(taskProvider).where((task) => task.isCompleted).toList();

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text(
              'Completed Tasks',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pop(context),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: completedTasks.isEmpty
              ? _buildEmptyCompletedState(theme)
              : _buildCompletedTasksList(theme, completedTasks),
        );
      },
    );
  }

  Widget _buildEmptyCompletedState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.successColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.task_alt,
              size: 50,
              color: AppTheme.successColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No completed tasks yet',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete some tasks to see them here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedTasksList(ThemeData theme, List<Task> completedTasks) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: completedTasks.length,
      itemBuilder: (context, index) {
        final task = completedTasks[index];
        return AnimatedContainer(
          duration: AppTheme.defaultAnimationDuration,
          margin: const EdgeInsets.only(bottom: 12),
          child: Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.successColor.withOpacity(0.1),
                child: Icon(
                  Icons.check_circle,
                  color: AppTheme.successColor,
                ),
              ),
              title: Text(
                task.title,
                style: TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (task.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        task.description,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: AppTheme.successColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${task.formattedDate} at ${task.formattedTime}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Completed',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.successColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (task.completedAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('h:mm a').format(task.completedAt!),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
