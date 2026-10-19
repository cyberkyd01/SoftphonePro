import AVFoundation
import Contacts
import Flutter
import Intents
import UIKit
import UserNotifications

/// Method/event channel endpoint for the Dart `IosPlatformServices`.
///
/// Channels (see app/lib/platform/ios/ios_platform_services.dart):
///   MethodChannel "softphonepro/platform"
///   EventChannel  "softphonepro/platform/events"  -> maps with a "type" key:
///     audioSession {active}, route {route}, callAction {kind, callKey},
///     dtmf {callKey, digits}, link {url}
final class PlatformBridge: NSObject, FlutterStreamHandler {
  static let shared = PlatformBridge()

  private let audio = AudioRouteManager()
  private lazy var callKit = CallKitManager(audio: audio)
  private var sink: FlutterEventSink?
  private var pendingInitialLink: String?
  private var linksDelivered = false

  func register(messenger: FlutterBinaryMessenger) {
    let ch = FlutterMethodChannel(name: "softphonepro/platform", binaryMessenger: messenger)
    ch.setMethodCallHandler { [weak self] call, result in self?.handle(call, result) }
    FlutterEventChannel(name: "softphonepro/platform/events", binaryMessenger: messenger)
      .setStreamHandler(self)

    audio.onRouteChanged = { [weak self] r in self?.emit(["type": "route", "route": r]) }
    callKit.onAction = { [weak self] kind, key in
      self?.emit(["type": "callAction", "kind": kind, "callKey": key])
    }
    callKit.onDTMF = { [weak self] key, digits in
      self?.emit(["type": "dtmf", "callKey": key, "digits": digits])
    }
    callKit.onAudioSession = { [weak self] on in
      self?.emit(["type": "audioSession", "active": on])
    }
  }

  // MARK: events

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    sink = events
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    sink = nil
    return nil
  }

  private func emit(_ m: [String: Any]) {
    DispatchQueue.main.async { self.sink?(m) }
  }

  /// URL opened by the system (sip:, tel:, ...). Before Dart asked for the
  /// initial link it is kept for `initialLink`; afterwards streamed.
  func deliverLink(_ url: URL) {
    if !linksDelivered {
      pendingInitialLink = url.absoluteString
    } else {
      emit(["type": "link", "url": url.absoluteString])
    }
  }

  // MARK: methods

  private func handle(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    let a = call.arguments as? [String: Any] ?? [:]
    func s(_ k: String) -> String { (a[k] as? String) ?? "" }
    switch call.method {
    case "init":
      audio.configureSession()
      result(nil)
    case "requestPermissions":
      requestPermissions(result)
    case "requestContactsPermission":
      requestContactsAccess { result($0) }
    case "readContacts":
      readContacts { result($0) }
    case "showNotification":
      showNotification(
        id: s("id"), title: s("title"), body: s("body"), payload: a["payload"] as? String)
      result(nil)
    case "reportIncomingCall":
      callKit.reportIncoming(key: s("callKey"), handle: s("handle"), name: s("displayName")) {
        err in
        DispatchQueue.main.async {
          if let e = err {
            result(FlutterError(code: "callkit", message: e.localizedDescription, details: nil))
          } else {
            result(nil)
          }
        }
      }
    case "reportOutgoingCall":
      callKit.reportOutgoing(key: s("callKey"), handle: s("handle"), name: s("displayName")) {
        err in
        DispatchQueue.main.async {
          if let e = err {
            result(FlutterError(code: "callkit", message: e.localizedDescription, details: nil))
          } else {
            result(nil)
          }
        }
      }
    case "reportCallConnected":
      callKit.reportConnected(key: s("callKey"))
      result(nil)
    case "reportCallEnded":
      callKit.reportEnded(key: s("callKey"), reason: s("reason"))
      result(nil)
    case "availableAudioRoutes":
      result(audio.availableRoutes())
    case "getAudioRoute":
      result(audio.currentRoute())
    case "setAudioRoute":
      do {
        try audio.setRoute(s("route"))
        result(nil)
      } catch {
        result(FlutterError(code: "route", message: error.localizedDescription, details: nil))
      }
    case "setProximityEnabled":
      audio.setProximity((a["enabled"] as? Bool) ?? false)
      result(nil)
    case "setKeepScreenOn":
      audio.setKeepScreenOn((a["keepOn"] as? Bool) ?? false)
      result(nil)
    case "updateBadge":
      setBadge((a["count"] as? Int) ?? 0)
      result(nil)
    case "initialLink":
      linksDelivered = true
      let l = pendingInitialLink
      pendingInitialLink = nil
      result(l)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: permissions

  private func requestPermissions(_ result: @escaping FlutterResult) {
    var out: [String: String] = [:]
    let q = DispatchQueue(label: "softphonepro.perm")
    func put(_ k: String, _ v: String) { q.sync { out[k] = v } }
    let group = DispatchGroup()

    group.enter()
    requestMicrophone { put("microphone", $0); group.leave() }

    group.enter()
    UNUserNotificationCenter.current().getNotificationSettings { st in
      switch st.authorizationStatus {
      case .authorized, .provisional, .ephemeral:
        put("notifications", "granted")
        group.leave()
      case .denied:
        put("notifications", "permanentlyDenied")
        group.leave()
      default:
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {
          ok, _ in
          put("notifications", ok ? "granted" : "permanentlyDenied")
          group.leave()
        }
      }
    }

    group.enter()
    switch CNContactStore.authorizationStatus(for: .contacts) {
    case .authorized:
      put("contacts", "granted")
      group.leave()
    case .denied, .restricted:
      put("contacts", "permanentlyDenied")
      group.leave()
    default:
      CNContactStore().requestAccess(for: .contacts) { ok, _ in
        put("contacts", ok ? "granted" : "permanentlyDenied")
        group.leave()
      }
    }

    group.notify(queue: .main) { result(q.sync { out }) }
  }

  // MARK: device contacts (CNContactStore)

  private func requestContactsAccess(_ done: @escaping (String) -> Void) {
    switch CNContactStore.authorizationStatus(for: .contacts) {
    case .authorized: done("granted")
    case .denied, .restricted: done("permanentlyDenied")
    default:
      CNContactStore().requestAccess(for: .contacts) { ok, _ in
        DispatchQueue.main.async { done(ok ? "granted" : "permanentlyDenied") }
      }
    }
  }

  /// Name + phone numbers + emails of every contact; empty when not authorised.
  private func readContacts(_ done: @escaping ([[String: Any]]) -> Void) {
    DispatchQueue.global(qos: .userInitiated).async {
      var out: [[String: Any]] = []
      if CNContactStore.authorizationStatus(for: .contacts) == .authorized {
        let keys: [CNKeyDescriptor] = [
          CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
          CNContactPhoneNumbersKey as CNKeyDescriptor,
          CNContactEmailAddressesKey as CNKeyDescriptor,
        ]
        let req = CNContactFetchRequest(keysToFetch: keys)
        try? CNContactStore().enumerateContacts(with: req) { c, _ in
          let name = CNContactFormatter.string(from: c, style: .fullName) ?? ""
          let numbers: [[String: String]] = c.phoneNumbers.map {
            [
              "label": CNLabeledValue<NSString>.localizedString(forLabel: $0.label ?? "other"),
              "number": $0.value.stringValue,
            ]
          }
          let emails = c.emailAddresses.map { $0.value as String }
          if !numbers.isEmpty || !emails.isEmpty {
            out.append(["id": c.identifier, "name": name, "numbers": numbers, "emails": emails])
          }
        }
      }
      DispatchQueue.main.async { done(out) }
    }
  }

  private func requestMicrophone(_ done: @escaping (String) -> Void) {
    if #available(iOS 17.0, *) {
      switch AVAudioApplication.shared.recordPermission {
      case .granted: done("granted")
      case .denied: done("permanentlyDenied")
      default:
        AVAudioApplication.requestRecordPermission { ok in
          done(ok ? "granted" : "permanentlyDenied")
        }
      }
    } else {
      let s = AVAudioSession.sharedInstance()
      switch s.recordPermission {
      case .granted: done("granted")
      case .denied: done("permanentlyDenied")
      default:
        s.requestRecordPermission { ok in done(ok ? "granted" : "permanentlyDenied") }
      }
    }
  }

  // MARK: notifications / badge

  private func showNotification(id: String, title: String, body: String, payload: String?) {
    let c = UNMutableNotificationContent()
    c.title = title
    c.body = body
    c.sound = .default
    if let p = payload { c.userInfo = ["payload": p] }
    let req = UNNotificationRequest(identifier: id, content: c, trigger: nil)
    UNUserNotificationCenter.current().add(req) { err in
      if let e = err { NSLog("SoftphonePro: notification failed: \(e)") }
    }
  }

  private func setBadge(_ n: Int) {
    DispatchQueue.main.async {
      if #available(iOS 16.0, *) {
        UNUserNotificationCenter.current().setBadgeCount(n) { _ in }
      } else {
        UIApplication.shared.applicationIconBadgeNumber = n
      }
    }
  }
}
