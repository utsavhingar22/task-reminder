import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../utils/theme.dart';

class TaskList extends ConsumerStatefulWidget {
  final List<Task> tasks;

  const TaskList({super.key, required this.tasks});

  @override
  ConsumerState<TaskList> createState() => _TaskListState();
}

class _TaskListState extends ConsumerState<TaskList>
    with TickerProviderStateMixin {
  static const platform = MethodChannel('com.mobile.taskmanagment/native');
  late AnimationController _listController;
  late Animation<double> _listAnimation;

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(
      duration: AppTheme.defaultAnimationDuration,
      vsync: this,
    );
    _listAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _listController,
      curve: AppTheme.defaultAnimationCurve,
    ));
    _listController.forward();
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  Future<void> _triggerHaptic() async {
    try {
      await platform.invokeMethod('haptic');
    } catch (_) {
      // Haptic feedback is optional, so we don't show errors
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _listAnimation,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: widget.tasks.length,
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final task = widget.tasks[index];
          return _buildTaskCard(theme, task, index);
        },
      ),
    );
  }

  Widget _buildTaskCard(ThemeData theme, Task task, int index) {
    return AnimatedBuilder(
      animation: _listAnimation,
      builder: (context, child) {
        final animationValue = _listAnimation.value;
        final delay = index * 0.1;
        final itemAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: AlwaysStoppedAnimation(
            (animationValue - delay).clamp(0.0, 1.0),
          ),
          curve: AppTheme.bounceCurve,
        ));

        return Transform.translate(
          offset: Offset(0, 50 * (1 - itemAnimation.value)),
          child: Opacity(
            opacity: itemAnimation.value,
            child: Dismissible(
              key: Key(task.id),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                ref.read(taskProvider.notifier).deleteTask(task.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Task "${task.title}" deleted'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        ref.read(taskProvider.notifier).addTask(task);
                      },
                    ),
                  ),
                );
              },
              background: _buildDismissBackground(theme),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: _buildTaskItem(theme, task),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDismissBackground(ThemeData theme) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      decoration: BoxDecoration(
        color: AppTheme.errorColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(
        Icons.delete,
        color: Colors.white,
        size: 32,
      ),
    );
  }

  Widget _buildTaskItem(ThemeData theme, Task task) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showTaskDetails(theme, task),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              _buildTaskCheckbox(theme, task),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTaskContent(theme, task),
              ),
              _buildTaskActions(theme, task),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCheckbox(ThemeData theme, Task task) {
    return GestureDetector(
      onTap: () async {
        if (!task.isCompleted) {
          await _triggerHaptic();
          ref.read(taskProvider.notifier).markTaskCompleted(task);
        }
      },
      child: AnimatedContainer(
        duration: AppTheme.defaultAnimationDuration,
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: task.isCompleted
              ? AppTheme.successColor.withOpacity(0.1)
              : AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: task.isCompleted
                ? AppTheme.successColor.withOpacity(0.3)
                : AppTheme.primaryColor.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: AppTheme.fastAnimationDuration,
            child: Icon(
              task.isCompleted ? Icons.check : Icons.circle_outlined,
              key: ValueKey(task.isCompleted),
              size: 24,
              color: task.isCompleted
                  ? AppTheme.successColor
                  : AppTheme.primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskContent(ThemeData theme, Task task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          task.title,
          style: theme.textTheme.titleLarge?.copyWith(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted
                ? theme.colorScheme.onSurface.withOpacity(0.6)
                : theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (task.description.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            task.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            _buildTimeChip(theme, task),
            if (task.isRecurring) ...[
              const SizedBox(width: 8),
              _buildRecurringChip(theme, task),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildTimeChip(ThemeData theme, Task task) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule,
            size: 16,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            '${task.formattedDate} at ${task.formattedTime}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecurringChip(ThemeData theme, Task task) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.repeat,
            size: 12,
            color: AppTheme.accentColor,
          ),
          const SizedBox(width: 2),
          Text(
            task.recurringFrequency ?? 'recurring',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppTheme.accentColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskActions(ThemeData theme, Task task) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () => _showTaskDetails(theme, task),
          icon: Icon(
            Icons.info_outline,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  void _showTaskDetails(ThemeData theme, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.task_alt,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                task.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty) ...[
              Text(
                'Description',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                task.description,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
            ],
            _buildDetailRow(
              theme,
              Icons.schedule,
              'Reminder Time',
              '${task.formattedDate} at ${task.formattedTime}',
            ),
            if (task.isRecurring) ...[
              const SizedBox(height: 12),
              _buildDetailRow(
                theme,
                Icons.repeat,
                'Recurring',
                task.recurringFrequency ?? 'Unknown',
              ),
            ],
            if (task.isCompleted) ...[
              const SizedBox(height: 12),
              _buildDetailRow(
                theme,
                Icons.check_circle,
                'Completed',
                task.completedAt != null
                    ? DateFormat('MMM d, yyyy at h:mm a')
                        .format(task.completedAt!)
                    : 'Unknown time',
                color: AppTheme.successColor,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    ThemeData theme,
    IconData icon,
    String label,
    String value, {
    Color? color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: color ?? theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color ?? theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
