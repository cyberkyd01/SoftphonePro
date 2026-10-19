import Flutter
import Intents
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if let reg = self.registrar(forPlugin: "SoftphoneProPlatform") {
      PlatformBridge.shared.register(messenger: reg.messenger())
    }
    UNUserNotificationCenter.current().delegate = self
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // sip:, sips:, tel:, callto:, softphonepro:
  override func application(
    _ app: UIApplication, open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    PlatformBridge.shared.deliverLink(url)
    return true
  }

  // Call-back from the system Phone/Recents list (INStartCallIntent).
  override func application(
    _ application: UIApplication, continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    if let intent = userActivity.interaction?.intent as? INStartCallIntent,
      let value = intent.contacts?.first?.personHandle?.value, !value.isEmpty
    {
      let enc = value.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? value
      if let url = URL(string: "tel:" + enc) {
        PlatformBridge.shared.deliverLink(url)
        return true
      }
    }
    return super.application(
      application, continue: userActivity, restorationHandler: restorationHandler)
  }

  // Show missed-call / message banners while the app is in the foreground.
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter, willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    if #available(iOS 14.0, *) {
      completionHandler([.banner, .list, .sound])
    } else {
      completionHandler([.alert, .sound])
    }
  }
}
