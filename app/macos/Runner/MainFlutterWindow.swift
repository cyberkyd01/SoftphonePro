import Cocoa
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
