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
    // Needed to learn that a reminder was tapped, including at cold start.
    UNUserNotificationCenter.current().delegate = self
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /// A tapped reminder opens that day's activity (see GentleHomePage).
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    if response.notification.request.identifier.hasPrefix(GoldenMomentsNative.reminderPrefix) {
      GoldenMomentsNative.reminderTapped()
    }
    super.userNotificationCenter(
      center, didReceive: response, withCompletionHandler: completionHandler)
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

  /// The channel, once Flutter is running, to tell it about a tap.
  static var channel: FlutterMethodChannel?
  /// A tap that Flutter has not collected yet (a cold start, for example).
  static var pendingTap = false

  static func reminderTapped() {
    pendingTap = true
    channel?.invokeMethod("reminderTapped", arguments: nil)
  }

  static func register(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: "golden_moments/native", binaryMessenger: messenger)
    Self.channel = channel
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
      case "scheduleDatedReminders":
        scheduleDatedReminders(call.arguments as? [String: Any], result: result)
      case "takeReminderTap":
        result(pendingTap)
        pendingTap = false
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

  /// Replaces our reminders with one-off reminders on the given dates. Each
  /// arrives as a local wall-clock time (year, month, day, hour, minute) with
  /// its own words, so the app can vary them and plan around the days it is
  /// used. No time zone is attached: a reminder keeps its hour if the device
  /// moves to another zone or the clocks change.
  static func scheduleDatedReminders(_ args: [String: Any]?, result: @escaping FlutterResult) {
    guard let list = args?["reminders"] as? [[String: Any]], list.count <= 60 else {
      result(false)
      return
    }
    var requests: [UNNotificationRequest] = []
    for item in list {
      guard
        let year = item["year"] as? Int,
        let month = item["month"] as? Int, (1...12).contains(month),
        let day = item["day"] as? Int, (1...31).contains(day),
        let hour = item["hour"] as? Int, (0...23).contains(hour),
        let minute = item["minute"] as? Int, (0...59).contains(minute),
        let title = item["title"] as? String, !title.isEmpty,
        let body = item["body"] as? String, !body.isEmpty
      else {
        result(false)
        return
      }
      var when = DateComponents()
      when.year = year
      when.month = month
      when.day = day
      when.hour = hour
      when.minute = minute
      let content = UNMutableNotificationContent()
      content.title = title
      content.body = body
      content.sound = .default
      requests.append(
        UNNotificationRequest(
          identifier: "\(reminderPrefix)\(year)-\(month)-\(day)",
          content: content,
          trigger: UNCalendarNotificationTrigger(dateMatching: when, repeats: false)))
    }
    cancelReminders {
      let center = UNUserNotificationCenter.current()
      let group = DispatchGroup()
      var failed = false
      let lock = NSLock()
      for request in requests {
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
