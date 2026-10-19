import AVFoundation
import Cocoa
import Contacts
import CoreServices
import FlutterMacOS
import MediaPlayer
import ServiceManagement

/// Receives sip:/tel:/callto:/softphonepro: links (GetURL Apple events) and
/// buffers them until Dart has called `ready`; afterwards forwards them live.
///
/// The handler must be installed in applicationDidFinishLaunching or later:
/// NSApplication installs its own kAEGetURL handler while it finishes
/// launching and replaces one registered earlier (for example from a window's
/// awakeFromNib), which silently dropped links sent to the running app.
final class LinkBuffer: NSObject {
  static let shared = LinkBuffer()
  var channel: FlutterMethodChannel?
  private var ready = false
  private var pending: [String] = []
  private var installed = false

  func install() {
    if installed { return }
    installed = true
    NSAppleEventManager.shared().setEventHandler(
      self,
      andSelector: #selector(handleGetURL(_:withReplyEvent:)),
      forEventClass: AEEventClass(kInternetEventClass),
      andEventID: AEEventID(kAEGetURL))
    NSLog("SoftphonePro: GetURL handler installed")
  }

  @objc func handleGetURL(_ event: NSAppleEventDescriptor, withReplyEvent reply: NSAppleEventDescriptor) {
    guard let s = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue else {
      NSLog("SoftphonePro: GetURL event without a URL")
      return
    }
    deliver(s)
  }

  func deliver(_ link: String) {
    NSLog("SoftphonePro: link received %@ (dartReady=%@)", link, ready ? "yes" : "no")
    if ready, let ch = channel {
      ch.invokeMethod("onLink", arguments: link)
    } else {
      pending.append(link)
    }
  }

  /// Called when Dart is ready; returns the links that arrived before.
  func markReady() -> [String] {
    ready = true
    let p = pending
    pending = []
    return p
  }
}

class MainFlutterWindow: NSWindow {
  private var channel: FlutterMethodChannel?
  private var launchedAtLogin = false
  private var mediaKeyTargets: [Any] = []
  private let startTime = Date()

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    // Quiet title bar: no title text, transparent bar (content stays below it).
    self.titleVisibility = .hidden
    self.titlebarAppearsTransparent = true

    RegisterGeneratedPlugins(registry: flutterViewController)
    setUpDesktopChannel(flutterViewController)

    super.awakeFromNib()
  }

  // MARK: - softphonepro/desktop channel

  private func setUpDesktopChannel(_ controller: FlutterViewController) {
    let ch = FlutterMethodChannel(
      name: "softphonepro/desktop", binaryMessenger: controller.engine.binaryMessenger)
    channel = ch
    LinkBuffer.shared.channel = ch
    ch.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { return result(FlutterMethodNotImplemented) }
      switch call.method {
      case "ready":
        let pending = LinkBuffer.shared.markReady()
        result(["pending": pending, "launchedAtLogin": self.launchedAtLogin])
      case "setLoginItem":
        let enable = (call.arguments as? Bool) ?? false
        result(self.setLoginItem(enable))
      case "loginItemEnabled":
        result(self.loginItemEnabled())
      case "requestContactsPermission":
        self.requestContactsAccess { result($0) }
      case "readContacts":
        self.readContacts { result($0) }
      case "showMicrophoneModes":
        if #available(macOS 12.0, *) {
          AVCaptureDevice.showSystemUserInterface(.microphoneModes)
          result(true)
        } else {
          result(false)
        }
      case "defaultHandlers":
        result(self.defaultHandlers())
      case "setDefaultHandler":
        self.setDefaultHandler { result($0) }
      case "setMediaKeys":
        self.setMediaKeysActive((call.arguments as? Bool) ?? false)
        result(true)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    NotificationCenter.default.addObserver(
      forName: NSApplication.didFinishLaunchingNotification, object: nil, queue: nil
    ) { [weak self] _ in
      guard let self = self else { return }
      // sip:, sips:, tel:, callto:, softphonepro: (CFBundleURLTypes) arrive as
      // a GetURL Apple event, also when the app was launched by the link.
      LinkBuffer.shared.install()
      if let ev = NSAppleEventManager.shared().currentAppleEvent,
        ev.eventID == AEEventID(kAEOpenApplication),
        let d = ev.paramDescriptor(forKeyword: AEKeyword(keyAEPropData)),
        d.enumCodeValue == OSType(keyAELaunchedAsLogInItem)
      {
        self.launchedAtLogin = true
      }
    }

    // Clicking the Dock icon while the window is hidden (close-to-tray)
    // activates the app: bring the window back.
    NotificationCenter.default.addObserver(
      forName: NSApplication.didBecomeActiveNotification, object: nil, queue: .main
    ) { [weak self] _ in
      guard let self = self else { return }
      if !self.isVisible && !self.isMiniaturized
        && Date().timeIntervalSince(self.startTime) > 3
      {
        self.makeKeyAndOrderFront(nil)
      }
    }
  }

  // MARK: - headset / media keys (MPRemoteCommandCenter)

  /// Claims the play/pause media keys (and headset buttons) only while Dart
  /// asks for it, i.e. while a call is ringing or active, so music apps keep
  /// the keys the rest of the time. Presses are forwarded as `onMediaKey`.
  private func setMediaKeysActive(_ on: Bool) {
    let center = MPRemoteCommandCenter.shared()
    let commands: [MPRemoteCommand] = [
      center.togglePlayPauseCommand, center.playCommand, center.pauseCommand,
    ]
    if on {
      if !mediaKeyTargets.isEmpty { return }
      for command in commands {
        command.isEnabled = true
        let token = command.addTarget { [weak self] _ in
          self?.channel?.invokeMethod("onMediaKey", arguments: nil)
          return .success
        }
        mediaKeyTargets.append(token)
      }
      MPNowPlayingInfoCenter.default().nowPlayingInfo = [
        MPMediaItemPropertyTitle: "SoftphonePro call"
      ]
      MPNowPlayingInfoCenter.default().playbackState = .playing
    } else {
      for (command, token) in zip(commands, mediaKeyTargets) {
        command.removeTarget(token)
        command.isEnabled = false
      }
      mediaKeyTargets.removeAll()
      MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
      MPNowPlayingInfoCenter.default().playbackState = .stopped
    }
  }

  // MARK: - device contacts (Contacts framework)

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

  // MARK: - default handler for sip:, tel:, callto:

  private static let handlerSchemes = ["sip", "tel", "callto"]

  /// Current handler of each scheme: `{scheme: {name, bundleId, isSelf}}`.
  /// Read only; never changes the user's configuration.
  private func defaultHandlers() -> [String: [String: Any]] {
    var out: [String: [String: Any]] = [:]
    let me = Bundle.main.bundleIdentifier ?? ""
    for scheme in MainFlutterWindow.handlerSchemes {
      var entry: [String: Any] = ["name": "", "bundleId": "", "isSelf": false]
      var bundleId = ""
      if let url = URL(string: "\(scheme):0"),
        let app = NSWorkspace.shared.urlForApplication(toOpen: url)
      {
        var name = FileManager.default.displayName(atPath: app.path)
        if name.hasSuffix(".app") { name = String(name.dropLast(4)) }
        entry["name"] = name
        bundleId = Bundle(url: app)?.bundleIdentifier ?? ""
      }
      if bundleId.isEmpty,
        let h = LSCopyDefaultHandlerForURLScheme(scheme as CFString)?.takeRetainedValue() as String?
      {
        bundleId = h
      }
      entry["bundleId"] = bundleId
      entry["isSelf"] = !me.isEmpty && bundleId.caseInsensitiveCompare(me) == .orderedSame
      out[scheme] = entry
    }
    return out
  }

  /// Makes this app the default handler of sip:, tel: and callto:. macOS may
  /// ask the user to confirm. Completes with `{ok, failed: [schemes]}`.
  private func setDefaultHandler(_ done: @escaping ([String: Any]) -> Void) {
    let schemes = MainFlutterWindow.handlerSchemes
    var failed: [String] = []
    let group = DispatchGroup()
    for scheme in schemes {
      if #available(macOS 12.0, *) {
        group.enter()
        NSWorkspace.shared.setDefaultApplication(
          at: Bundle.main.bundleURL, toOpenURLsWithScheme: scheme
        ) { error in
          if let error = error {
            NSLog("SoftphonePro: default handler for %@ failed: %@", scheme, "\(error)")
            DispatchQueue.main.async { failed.append(scheme) }
          }
          group.leave()
        }
      } else if let id = Bundle.main.bundleIdentifier {
        let rc = LSSetDefaultHandlerForURLScheme(scheme as CFString, id as CFString)
        if rc != noErr { failed.append(scheme) }
      } else {
        failed.append(scheme)
      }
    }
    group.notify(queue: .main) { done(["ok": failed.isEmpty, "failed": failed]) }
  }

  // MARK: - login item (SMAppService, works inside the sandbox)

  private func setLoginItem(_ enable: Bool) -> Bool {
    if #available(macOS 13.0, *) {
      do {
        if enable {
          if SMAppService.mainApp.status != .enabled { try SMAppService.mainApp.register() }
        } else {
          if SMAppService.mainApp.status == .enabled { try SMAppService.mainApp.unregister() }
        }
        return true
      } catch {
        NSLog("SoftphonePro: login item change failed: \(error)")
        return false
      }
    }
    return false
  }

  private func loginItemEnabled() -> Bool {
    if #available(macOS 13.0, *) {
      return SMAppService.mainApp.status == .enabled
    }
    return false
  }
}
