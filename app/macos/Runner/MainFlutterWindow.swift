import Cocoa
import Contacts
import FlutterMacOS
import ServiceManagement

class MainFlutterWindow: NSWindow {
  private var channel: FlutterMethodChannel?
  private var dartReady = false
  private var pendingLinks: [String] = []
  private var launchedAtLogin = false
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
    ch.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { return result(FlutterMethodNotImplemented) }
      switch call.method {
      case "ready":
        self.dartReady = true
        let pending = self.pendingLinks
        self.pendingLinks = []
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
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    // sip:, sips:, tel:, callto:, softphonepro: (CFBundleURLTypes) arrive as a
    // GetURL Apple event, also when the app was launched by the link.
    NSAppleEventManager.shared().setEventHandler(
      self,
      andSelector: #selector(handleGetURL(_:withReplyEvent:)),
      forEventClass: AEEventClass(kInternetEventClass),
      andEventID: AEEventID(kAEGetURL))

    NotificationCenter.default.addObserver(
      forName: NSApplication.didFinishLaunchingNotification, object: nil, queue: nil
    ) { [weak self] _ in
      guard let self = self else { return }
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

  @objc func handleGetURL(_ event: NSAppleEventDescriptor, withReplyEvent reply: NSAppleEventDescriptor) {
    guard let s = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue else {
      return
    }
    if dartReady, let ch = channel {
      ch.invokeMethod("onLink", arguments: s)
    } else {
      pendingLinks.append(s)
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
