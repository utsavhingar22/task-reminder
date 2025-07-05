import UIKit
import Flutter
import UserNotifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // Request notification permissions
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
      if granted {
        print("Notification permission granted")
      } else {
        print("Notification permission denied")
      }
    }
    
    // Set up method channel
    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "com.mobile.taskmanagment/native", binaryMessenger: controller.binaryMessenger)
    
    channel.setMethodCallHandler { [weak self] (call, result) in
      switch call.method {
      case "pickDate":
        self?.showDatePicker(result: result)
      case "pickTime":
        self?.showTimePicker(result: result)
      case "haptic":
        self?.triggerHapticFeedback()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func showDatePicker(result: @escaping FlutterResult) {
    let datePicker = UIDatePicker()
    datePicker.datePickerMode = .date
    datePicker.preferredDatePickerStyle = .wheels
    
    let alert = UIAlertController(title: "Select Date", message: nil, preferredStyle: .actionSheet)
    
    let pickerView = UIDatePicker()
    pickerView.datePickerMode = .date
    pickerView.preferredDatePickerStyle = .wheels
    
    alert.view.addSubview(pickerView)
    pickerView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      pickerView.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
      pickerView.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 20),
      pickerView.bottomAnchor.constraint(equalTo: alert.view.bottomAnchor, constant: -60)
    ])
    
    let doneAction = UIAlertAction(title: "Done", style: .default) { _ in
      let calendar = Calendar.current
      let components = calendar.dateComponents([.year, .month, .day], from: pickerView.date)
      
      let resultMap: [String: Any] = [
        "year": components.year ?? 0,
        "month": (components.month ?? 1) - 1, // iOS months are 1-based, we need 0-based
        "day": components.day ?? 1
      ]
      result(resultMap)
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
      result(FlutterError(code: "CANCELLED", message: "Date picker cancelled", details: nil))
    }
    
    alert.addAction(doneAction)
    alert.addAction(cancelAction)
    
    window?.rootViewController?.present(alert, animated: true)
  }
  
  private func showTimePicker(result: @escaping FlutterResult) {
    let timePicker = UIDatePicker()
    timePicker.datePickerMode = .time
    timePicker.preferredDatePickerStyle = .wheels
    
    let alert = UIAlertController(title: "Select Time", message: nil, preferredStyle: .actionSheet)
    
    let pickerView = UIDatePicker()
    pickerView.datePickerMode = .time
    pickerView.preferredDatePickerStyle = .wheels
    
    alert.view.addSubview(pickerView)
    pickerView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      pickerView.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
      pickerView.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 20),
      pickerView.bottomAnchor.constraint(equalTo: alert.view.bottomAnchor, constant: -60)
    ])
    
    let doneAction = UIAlertAction(title: "Done", style: .default) { _ in
      let calendar = Calendar.current
      let components = calendar.dateComponents([.hour, .minute], from: pickerView.date)
      
      let resultMap: [String: Any] = [
        "hour": components.hour ?? 0,
        "minute": components.minute ?? 0
      ]
      result(resultMap)
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
      result(FlutterError(code: "CANCELLED", message: "Time picker cancelled", details: nil))
    }
    
    alert.addAction(doneAction)
    alert.addAction(cancelAction)
    
    window?.rootViewController?.present(alert, animated: true)
  }
  
  private func triggerHapticFeedback() {
    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    impactFeedback.impactOccurred()
  }
}
