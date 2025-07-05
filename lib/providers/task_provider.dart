import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:convert';
import '../models/task.dart';

class TaskProvider extends StateNotifier<List<Task>> {
  final Ref ref;
  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  final SharedPreferences _prefs;

  TaskProvider(this.ref, this._notificationsPlugin, this._prefs) : super([]) {
    _loadTasks();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
  }

  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    final taskId = response.payload;
    if (taskId != null) {
      if (response.actionId == 'done') {
        final task = state.firstWhere((t) => t.id == taskId);
        markTaskCompleted(task);
      } else if (response.actionId == 'snooze') {
        final task = state.firstWhere((t) => t.id == taskId);
        _snoozeTask(task);
      }
    }
  }

  Future<void> _loadTasks() async {
    final tasksJson = _prefs.getStringList('tasks') ?? [];
    final tasks =
        tasksJson.map((json) => Task.fromJson(jsonDecode(json))).toList();
    state = tasks;
  }

  Future<void> saveTasks() async {
    final tasksJson = state.map((task) => jsonEncode(task.toJson())).toList();
    await _prefs.setStringList('tasks', tasksJson);
  }

  Future<void> addTask(Task task) async {
    state = [...state, task];
    await saveTasks();
    await _scheduleNotification(task);
  }

  Future<void> _scheduleNotification(Task task) async {
    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'reminder_channel',
        'Task Reminders',
        channelDescription: 'Notifications for task reminders',
        importance: Importance.high,
        priority: Priority.high,
        enableLights: true,
        enableVibration: true,
        ongoing: true,
        autoCancel: false,
        actions: [
          AndroidNotificationAction(
            'done',
            'Mark as Done',
            showsUserInterface: true,
          ),
          AndroidNotificationAction(
            'snooze',
            'Snooze 10min',
            showsUserInterface: true,
          ),
        ],
      ),
      iOS: DarwinNotificationDetails(
        subtitle: task.description,
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        categoryIdentifier: 'task_reminder',
        threadIdentifier: 'task_reminders',
      ),
    );

    if (task.isRecurring) {
      // Handle recurring notifications
      await _notificationsPlugin.zonedSchedule(
        task.id.hashCode,
        task.title,
        '${task.title}: ${task.description}',
        _getNextReminderTime(task),
        notificationDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: task.id,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } else {
      await _notificationsPlugin.zonedSchedule(
        task.id.hashCode,
        task.title,
        '${task.title}: ${task.description}',
        tz.TZDateTime.from(task.reminderTime, tz.local),
        notificationDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: task.id,
      );
    }
  }

  tz.TZDateTime _getNextReminderTime(Task task) {
    final now = tz.TZDateTime.now(tz.local);
    final reminderTime = tz.TZDateTime.from(task.reminderTime, tz.local);

    switch (task.recurringFrequency) {
      case 'daily':
        return reminderTime.isBefore(now)
            ? reminderTime.add(const Duration(days: 1))
            : reminderTime;
      case 'weekly':
        return reminderTime.isBefore(now)
            ? reminderTime.add(const Duration(days: 7))
            : reminderTime;
      case 'monthly':
        return reminderTime.isBefore(now)
            ? tz.TZDateTime(
                tz.local,
                now.year,
                now.month + 1,
                reminderTime.day,
                reminderTime.hour,
                reminderTime.minute,
              )
            : reminderTime;
      default:
        return reminderTime;
    }
  }

  void markTaskCompleted(Task task) {
    final updatedTask = task.copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
    );
    state = [
      for (final t in state)
        if (t.id == task.id) updatedTask else t
    ];
    saveTasks();
    // Cancel the notification when task is completed
    _notificationsPlugin.cancel(task.id.hashCode);
  }

  Future<void> deleteTask(String taskId) async {
    // Cancel the notification before deleting the task
    await _notificationsPlugin.cancel(taskId.hashCode);
    state = state.where((task) => task.id != taskId).toList();
    await saveTasks();
  }

  List<Task> get completedTasks =>
      state.where((task) => task.isCompleted).toList();
  List<Task> get activeTasks =>
      state.where((task) => !task.isCompleted).toList();

  Future<void> _snoozeTask(Task task) async {
    final snoozeTime = DateTime.now().add(const Duration(minutes: 10));
    final snoozedTask = task.copyWith(reminderTime: snoozeTime);

    // Cancel the original notification
    await _notificationsPlugin.cancel(task.id.hashCode);

    // Schedule a new notification for the snoozed time
    final snoozeNotificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'reminder_channel',
        'Task Reminders',
        channelDescription: 'Notifications for task reminders',
        importance: Importance.high,
        priority: Priority.high,
        enableLights: true,
        enableVibration: true,
        ongoing: true,
        autoCancel: false,
        actions: [
          AndroidNotificationAction(
            'done',
            'Mark as Done',
            showsUserInterface: true,
          ),
          AndroidNotificationAction(
            'snooze',
            'Snooze 10min',
            showsUserInterface: true,
          ),
        ],
      ),
      iOS: DarwinNotificationDetails(
        subtitle: '${task.description} (Snoozed)',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        categoryIdentifier: 'task_reminder',
        threadIdentifier: 'task_reminders',
      ),
    );

    await _notificationsPlugin.zonedSchedule(
      snoozedTask.id.hashCode,
      snoozedTask.title,
      '${snoozedTask.title}: ${snoozedTask.description} (Snoozed)',
      tz.TZDateTime.from(snoozeTime, tz.local),
      snoozeNotificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: snoozedTask.id,
    );

    // Update the task in the state
    state = [
      for (final t in state)
        if (t.id == task.id) snoozedTask else t
    ];
    await saveTasks();
  }
}

final taskProvider = StateNotifierProvider<TaskProvider, List<Task>>((ref) {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();
  return TaskProvider(
    ref,
    notificationsPlugin,
    ref.watch(sharedPreferencesProvider),
  );
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});
