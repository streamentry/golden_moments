import Flutter
import StoreKit
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    GoldenMomentsNative.register(
      messenger: engineBridge.applicationRegistrar.messenger())
  }
}

/// The channel behind lib/shared/native/gm_native.dart: Apple's rating
/// prompt and local reminders. Nothing here uses the network.
enum GoldenMomentsNative {
  /// Every reminder this app schedules starts with this, so cancelling never
  /// touches anything else.
  static let reminderPrefix = "golden-moments-reminder-"

  static func register(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: "golden_moments/native", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "requestReview":
        // Platform channel handlers run on the main thread.
        MainActor.assumeIsolated { requestReview() }
        result(nil)
      case "reminderPermission":
        UNUserNotificationCenter.current().getNotificationSettings { settings in
          DispatchQueue.main.async { result(describe(settings.authorizationStatus)) }
        }
      case "requestReminderPermission":
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) {
          granted, _ in
          DispatchQueue.main.async { result(granted ? "granted" : "denied") }
        }
      case "scheduleReminders":
        scheduleReminders(call.arguments as? [String: Any], result: result)
      case "cancelReminders":
        cancelReminders { DispatchQueue.main.async { result(nil) } }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  /// The system decides whether the prompt actually appears.
  @MainActor static func requestReview() {
    guard
      let scene = UIApplication.shared.connectedScenes
        .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
    else { return }
    if #available(iOS 16.0, *) {
      AppStore.requestReview(in: scene)
    } else {
      SKStoreReviewController.requestReview(in: scene)
    }
  }

  static func describe(_ status: UNAuthorizationStatus) -> String {
    switch status {
    case .authorized, .provisional, .ephemeral: return "granted"
    case .notDetermined: return "notDetermined"
    default: return "denied"
    }
  }

  static func cancelReminders(then done: @escaping () -> Void) {
    let center = UNUserNotificationCenter.current()
    center.getPendingNotificationRequests { requests in
      let ids = requests.map(\.identifier).filter { $0.hasPrefix(reminderPrefix) }
      center.removePendingNotificationRequests(withIdentifiers: ids)
      done()
    }
  }

  /// Replaces our reminders with one repeating reminder per chosen weekday.
  /// Weekdays arrive as 1 (Monday) to 7 (Sunday), like Dart's DateTime.
  static func scheduleReminders(_ args: [String: Any]?, result: @escaping FlutterResult) {
    guard
      let args = args,
      let weekdays = args["weekdays"] as? [Int],
      let hour = args["hour"] as? Int, (0...23).contains(hour),
      let minute = args["minute"] as? Int, (0...59).contains(minute),
      let title = args["title"] as? String,
      let body = args["body"] as? String,
      !weekdays.isEmpty, weekdays.allSatisfy({ (1...7).contains($0) })
    else {
      result(false)
      return
    }
    cancelReminders {
      let center = UNUserNotificationCenter.current()
      let group = DispatchGroup()
      var failed = false
      let lock = NSLock()
      for weekday in Set(weekdays) {
        var when = DateComponents()
        // Calendar weekdays run 1 (Sunday) to 7 (Saturday).
        when.weekday = weekday % 7 + 1
        when.hour = hour
        when.minute = minute
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let request = UNNotificationRequest(
          identifier: "\(reminderPrefix)\(weekday)",
          content: content,
          trigger: UNCalendarNotificationTrigger(dateMatching: when, repeats: true))
        group.enter()
        center.add(request) { error in
          if error != nil {
            lock.lock()
            failed = true
            lock.unlock()
          }
          group.leave()
        }
      }
      group.notify(queue: .main) { result(!failed) }
    }
  }
}
