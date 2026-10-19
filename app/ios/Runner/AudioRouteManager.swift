import AVFoundation
import UIKit

/// AVAudioSession configuration, route queries/overrides and proximity.
///
/// The session is never activated here: with CallKit the system activates it
/// (provider(_:didActivate:)) and the engine (sndMode "manual") opens its
/// devices only then.
final class AudioRouteManager {
  var onRouteChanged: ((String) -> Void)?

  private var proximityWanted = false
  private var observer: NSObjectProtocol?

  init() {
    observer = NotificationCenter.default.addObserver(
      forName: AVAudioSession.routeChangeNotification, object: nil, queue: .main
    ) { [weak self] _ in
      guard let self = self else { return }
      self.updateProximity()
      self.onRouteChanged?(self.currentRoute())
    }
  }

  deinit {
    if let o = observer { NotificationCenter.default.removeObserver(o) }
  }

  func configureSession() {
    let s = AVAudioSession.sharedInstance()
    do {
      try s.setCategory(
        .playAndRecord, mode: .voiceChat,
        options: [.allowBluetooth, .allowBluetoothA2DP])
    } catch {
      NSLog("SoftphonePro: setCategory failed: \(error)")
    }
  }

  // MARK: routes

  func currentRoute() -> String {
    let outs = AVAudioSession.sharedInstance().currentRoute.outputs
    guard let o = outs.first else { return "earpiece" }
    return AudioRouteManager.routeName(for: o.portType)
  }

  static func routeName(for t: AVAudioSession.Port) -> String {
    switch t {
    case .builtInReceiver: return "earpiece"
    case .builtInSpeaker: return "speaker"
    case .bluetoothHFP, .bluetoothA2DP, .bluetoothLE: return "bluetooth"
    case .headphones, .headsetMic, .usbAudio, .lineOut: return "wired"
    default: return "earpiece"
    }
  }

  func availableRoutes() -> [String] {
    let s = AVAudioSession.sharedInstance()
    var r: Set<String> = ["speaker"]
    if UIDevice.current.userInterfaceIdiom == .phone { r.insert("earpiece") }
    for i in s.availableInputs ?? [] {
      let n = AudioRouteManager.routeName(for: i.portType)
      if n == "bluetooth" || n == "wired" { r.insert(n) }
    }
    for o in s.currentRoute.outputs {
      let n = AudioRouteManager.routeName(for: o.portType)
      if n == "bluetooth" || n == "wired" { r.insert(n) }
    }
    return Array(r)
  }

  func setRoute(_ route: String) throws {
    let s = AVAudioSession.sharedInstance()
    switch route {
    case "speaker":
      try s.overrideOutputAudioPort(.speaker)
    case "bluetooth", "wired", "earpiece":
      try s.overrideOutputAudioPort(.none)
      let input = (s.availableInputs ?? []).first { port in
        if route == "earpiece" { return port.portType == .builtInMic }
        return AudioRouteManager.routeName(for: port.portType) == route
      }
      try s.setPreferredInput(input)
    default:
      break
    }
    updateProximity()
  }

  // MARK: proximity / screen

  func setProximity(_ on: Bool) {
    proximityWanted = on
    updateProximity()
  }

  private func updateProximity() {
    let device = UIDevice.current
    let wantOn = proximityWanted && currentRoute() == "earpiece"
    if device.isProximityMonitoringEnabled != wantOn {
      device.isProximityMonitoringEnabled = wantOn
    }
  }

  func setKeepScreenOn(_ on: Bool) {
    UIApplication.shared.isIdleTimerDisabled = on
  }
}
