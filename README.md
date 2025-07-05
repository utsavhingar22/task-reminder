# Task Reminder App

A modern, cross-platform task reminder application built with Flutter that showcases native platform features for both iOS and Android.

## 🚀 Features

### Core Features
- ✅ **Add Tasks**: Create tasks with title, description, and reminder time
- ✅ **View Tasks**: Beautiful list view of all tasks with their schedules
- ✅ **Schedule Notifications**: Native platform notifications with custom messages
- ✅ **Date & Time Selection**: Native platform date and time pickers
- ✅ **Task Completion & History**: Mark tasks as completed and view history
- ✅ **Recurring Tasks**: Support for daily, weekly, and monthly recurring tasks
- ✅ **Dark Mode**: Auto-adapts to system-wide theme
- ✅ **Notification Actions**: Mark tasks complete or snooze directly from notifications

### Platform-Specific Features

#### iOS
- 🍎 **Native iOS Date/Time Pickers**: Uses UIDatePicker with wheel style
- 🍎 **iOS Haptic Feedback**: UIImpactFeedbackGenerator for tactile responses
- 🍎 **Custom Notification Messages**: Task title and description in notifications
- 🍎 **iOS Notification Categories**: Proper notification threading and categorization

#### Android
- 🤖 **Native Android Date/Time Pickers**: Uses DatePickerDialog and TimePickerDialog
- 🤖 **Android Haptic Feedback**: VibrationEffect for tactile responses
- 🤖 **Persistent Notifications**: Notifications persist after app closure and device reboot
- 🤖 **Notification Action Buttons**: "Mark as Done" and "Snooze 10min" actions
- 🤖 **High Priority Notifications**: Ongoing notifications with lights and vibration

## 📱 Screenshots

*[Add screenshots here after testing on real devices]*

## 🛠️ Setup and Installation

### Prerequisites
- Flutter SDK (>=3.0.6)
- Dart SDK (>=3.0.6)
- Android Studio / Xcode
- iOS Simulator / Android Emulator or physical device

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd taskmanagement
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Platform-specific setup**

   **For Android:**
   - Ensure Android SDK is properly configured
   - Enable developer options and USB debugging on your device
   - The app uses native Android APIs for date/time pickers and haptics

   **For iOS:**
   - Ensure Xcode is properly configured
   - The app uses native iOS APIs for date/time pickers and haptics
   - Notification permissions are requested automatically

4. **Run the app**
   ```bash
   flutter run
   ```

## 🏗️ Architecture

### Project Structure
```
lib/
├── main.dart                 # App entry point with theme configuration
├── models/
│   └── task.dart            # Task data model with JSON serialization
├── providers/
│   └── task_provider.dart   # State management with Riverpod
├── screens/
│   └── home_screen.dart     # Main screen with task list and completed tasks
├── utils/
│   └── theme.dart           # Material 3 theme configuration
└── widgets/
    ├── add_task_dialog.dart # Task creation dialog with native pickers
    └── task_list.dart       # Reusable task list component
```

### Key Technologies
- **Flutter**: Cross-platform UI framework
- **Riverpod**: State management
- **SharedPreferences**: Local data persistence
- **flutter_local_notifications**: Platform-specific notifications
- **timezone**: Timezone-aware scheduling
- **intl**: Internationalization and date formatting

## 🔧 Platform-Specific Implementations

### Native Method Channels

The app uses Flutter's method channels to access native platform APIs:

**Channel Name**: `com.mobile.taskmanagment/native`

**Available Methods**:
- `pickDate`: Opens native date picker
- `pickTime`: Opens native time picker  
- `haptic`: Triggers platform-specific haptic feedback

### Android Implementation
```kotlin
// MainActivity.kt
class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.mobile.taskmanagment/native"
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "pickDate" -> showDatePicker(result)
                    "pickTime" -> showTimePicker(result)
                    "haptic" -> triggerHapticFeedback()
                }
            }
    }
}
```

### iOS Implementation
```swift
// AppDelegate.swift
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let channel = FlutterMethodChannel(
            name: "com.mobile.taskmanagment/native", 
            binaryMessenger: controller.binaryMessenger
        )
        
        channel.setMethodCallHandler { [weak self] (call, result) in
            switch call.method {
            case "pickDate": self?.showDatePicker(result: result)
            case "pickTime": self?.showTimePicker(result: result)
            case "haptic": self?.triggerHapticFeedback()
            default: result(FlutterMethodNotImplemented)
            }
        }
    }
}
```

## 🧪 Testing

### Testing Environment
- **iOS**: Tested on iOS Simulator and physical iPhone device
- **Android**: Tested on Android Emulator and physical Android device
- **Real Device Testing**: Essential for validating haptics and notification persistence

### Test Scenarios
1. **Task Creation**: Verify native date/time pickers work correctly
2. **Notifications**: Test notification scheduling and action buttons
3. **Haptic Feedback**: Verify tactile responses on both platforms
4. **Dark Mode**: Test theme switching and UI adaptation
5. **Recurring Tasks**: Validate daily/weekly/monthly scheduling
6. **Task Completion**: Test completion flow and history tracking

## 🎯 Challenges and Trade-offs

### Challenges Faced
1. **Platform-Specific APIs**: Implementing different native APIs for iOS and Android
2. **Notification Persistence**: Ensuring Android notifications persist after app closure
3. **Haptic Feedback**: Different implementation approaches for iOS vs Android
4. **Date/Time Picker Integration**: Handling platform-specific picker behaviors
5. **State Management**: Coordinating between Flutter and native code

### Trade-offs Made
1. **Fallback Mechanisms**: Flutter pickers as fallback when native pickers fail
2. **Error Handling**: Graceful degradation for optional features like haptics
3. **UI Consistency**: Balancing platform-specific design with cross-platform consistency
4. **Performance**: Using method channels efficiently to avoid blocking UI

## 📋 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.3.9          # State management
  flutter_local_notifications: ^16.0.0  # Platform notifications
  shared_preferences: ^2.2.2        # Local storage
  timezone: ^0.9.2                  # Timezone handling
  intl: ^0.18.1                     # Date formatting
  cupertino_icons: ^1.0.2           # iOS icons
  google_fonts: ^6.1.0              # Typography
```

## 🚀 Future Enhancements

- [ ] **Cloud Sync**: Sync tasks across devices
- [ ] **Categories**: Organize tasks by categories
- [ ] **Priority Levels**: Add task priority system
- [ ] **Location-Based Reminders**: Remind based on location
- [ ] **Voice Commands**: Add voice input for task creation
- [ ] **Widgets**: Home screen widgets for quick task access
- [ ] **Export/Import**: Backup and restore functionality

## 📄 License

This project is created for educational and demonstration purposes.

## 👨‍💻 Developer

Built with ❤️ using Flutter and native platform APIs.

---

**Note**: This app demonstrates advanced Flutter development techniques including native platform integration, state management, and modern UI design principles.
