import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

import '../models/task.dart';
import '../utils/theme.dart';

class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({super.key});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();
  bool _isRecurring = false;
  String _recurringFrequency = 'daily';
  static const platform = MethodChannel('com.mobile.taskmanagment/native');

  late AnimationController _dialogController;
  late AnimationController _formController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _dialogController = AnimationController(
      duration: AppTheme.defaultAnimationDuration,
      vsync: this,
    );
    _formController = AnimationController(
      duration: AppTheme.slowAnimationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _dialogController,
      curve: AppTheme.bounceCurve,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: AppTheme.defaultAnimationCurve,
    ));

    _dialogController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _formController.forward();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dialogController.dispose();
    _formController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    try {
      final result = await platform.invokeMethod<Map>('pickDate', {
        'initialYear': _selectedDateTime.year,
        'initialMonth': _selectedDateTime.month,
        'initialDay': _selectedDateTime.day,
      });
      if (result != null) {
        setState(() {
          _selectedDateTime = DateTime(
            result['year'] as int,
            (result['month'] as int) + 1,
            result['day'] as int,
            _selectedDateTime.hour,
            _selectedDateTime.minute,
          );
        });
      }
    } on PlatformException catch (e) {
      if (e.code != 'CANCELLED') {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _selectedDateTime,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) {
          setState(() {
            _selectedDateTime = DateTime(
              picked.year,
              picked.month,
              picked.day,
              _selectedDateTime.hour,
              _selectedDateTime.minute,
            );
          });
        }
      }
    }
  }

  Future<void> _selectTime() async {
    try {
      final result = await platform.invokeMethod<Map>('pickTime', {
        'initialHour': _selectedDateTime.hour,
        'initialMinute': _selectedDateTime.minute,
      });
      if (result != null) {
        setState(() {
          _selectedDateTime = DateTime(
            _selectedDateTime.year,
            _selectedDateTime.month,
            _selectedDateTime.day,
            result['hour'] as int,
            result['minute'] as int,
          );
        });
      }
    } on PlatformException catch (e) {
      if (e.code != 'CANCELLED') {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
        );
        if (picked != null) {
          setState(() {
            _selectedDateTime = DateTime(
              _selectedDateTime.year,
              _selectedDateTime.month,
              _selectedDateTime.day,
              picked.hour,
              picked.minute,
            );
          });
        }
      }
    }
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

    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 400,
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(theme),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildForm(theme),
                  ),
                ),
                const SizedBox(height: 24),
                _buildActions(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.add_task,
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
                'Add New Task',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Create a new task with reminder',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
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

  Widget _buildForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTitleField(theme),
          const SizedBox(height: 20),
          _buildDescriptionField(theme),
          const SizedBox(height: 20),
          _buildDateTimeSection(theme),
          const SizedBox(height: 20),
          _buildRecurringSection(theme),
        ],
      ),
    );
  }

  Widget _buildTitleField(ThemeData theme) {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'Task Title',
        hintText: 'Enter a descriptive title',
        prefixIcon: const Icon(Icons.title),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a title';
        }
        return null;
      },
      style: theme.textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildDescriptionField(ThemeData theme) {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: 'Description (Optional)',
        hintText: 'Add details about your task',
        prefixIcon: const Icon(Icons.description),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
      ),
      maxLines: 3,
      style: theme.textTheme.bodyMedium,
    );
  }

  Widget _buildDateTimeSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reminder Time',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDateTimeButton(
                theme,
                icon: Icons.calendar_today,
                label: DateFormat('MMM d, yyyy').format(_selectedDateTime),
                onPressed: _selectDate,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateTimeButton(
                theme,
                icon: Icons.access_time,
                label: DateFormat('h:mm a').format(_selectedDateTime),
                onPressed: _selectTime,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateTimeButton(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
      ),
    );
  }

  Widget _buildRecurringSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Recurring Task',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const Spacer(),
            Switch(
              value: _isRecurring,
              onChanged: (value) => setState(() => _isRecurring = value),
              activeColor: AppTheme.primaryColor,
            ),
          ],
        ),
        if (_isRecurring) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.2),
              ),
            ),
            child: DropdownButtonFormField<String>(
              value: _recurringFrequency,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Frequency',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              items: const [
                DropdownMenuItem(
                  value: 'daily',
                  child: Row(
                    children: [
                      Icon(Icons.repeat, size: 20),
                      SizedBox(width: 8),
                      Text('Daily'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'weekly',
                  child: Row(
                    children: [
                      Icon(Icons.repeat_one, size: 20),
                      SizedBox(width: 8),
                      Text('Weekly'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'monthly',
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month, size: 20),
                      SizedBox(width: 8),
                      Text('Monthly'),
                    ],
                  ),
                ),
              ],
              onChanged: (String? value) {
                setState(() {
                  _recurringFrequency = value!;
                });
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActions(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              side: BorderSide(color: theme.colorScheme.outline),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _saveTask,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text(
              'Create Task',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  void _saveTask() async {
    if (_formKey.currentState!.validate()) {
      final task = Task(
        id: DateTime.now().toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        reminderTime: _selectedDateTime,
        isRecurring: _isRecurring,
        recurringFrequency: _recurringFrequency,
      );

      await _triggerHaptic();

      if (mounted) {
        Navigator.pop(context, task);
      }
    }
  }
}
