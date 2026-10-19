import AVFoundation
import CallKit
import UIKit

/// CallKit integration. UUIDs are internal; Dart only knows `callKey`
/// (the engine call id as a string).
final class CallKitManager: NSObject, CXProviderDelegate {
  /// kind: answer|decline|end|hold|unhold|mute|unmute, callKey
  var onAction: ((String, String) -> Void)?
  var onAudioSession: ((Bool) -> Void)?
  /// callKey, digits
  var onDTMF: ((String, String) -> Void)?

  private let provider: CXProvider
  private let controller = CXCallController()
  private let audio: AudioRouteManager

  private var uuidByKey: [String: UUID] = [:]
  private var keyByUUID: [UUID: String] = [:]
  private var incomingPending = Set<UUID>()  // ringing, not yet answered
  private var outgoing = Set<UUID>()
  private var silentAnswer = Set<UUID>()  // answer requested by the app itself

  init(audio: AudioRouteManager) {
    self.audio = audio
    let cfg = CXProviderConfiguration(localizedName: "SoftphonePro")
    cfg.supportsVideo = false
    cfg.maximumCallGroups = 2
    cfg.maximumCallsPerCallGroup = 5
    cfg.supportedHandleTypes = [.generic, .phoneNumber]
    cfg.includesCallsInRecents = true
    cfg.iconTemplateImageData = CallKitManager.iconData()
    provider = CXProvider(configuration: cfg)
    super.init()
    provider.setDelegate(self, queue: nil)
  }

  /// Monochrome 40x40 template glyph shown on the system call screen.
  private static func iconData() -> Data? {
    let size = CGSize(width: 40, height: 40)
    guard let glyph = UIImage(systemName: "phone.fill") else { return nil }
    let img = UIGraphicsImageRenderer(size: size).image { _ in
      let g = glyph.withTintColor(.black, renderingMode: .alwaysOriginal)
      let r = AVMakeRect(
        aspectRatio: g.size, insideRect: CGRect(origin: .zero, size: size).insetBy(dx: 4, dy: 4))
      g.draw(in: r)
    }
    return img.pngData()
  }

  // MARK: mapping

  private func register(_ key: String) -> UUID {
    if let u = uuidByKey[key] { return u }
    let u = UUID()
    uuidByKey[key] = u
    keyByUUID[u] = key
    return u
  }

  private func forget(_ u: UUID) {
    if let k = keyByUUID.removeValue(forKey: u) { uuidByKey.removeValue(forKey: k) }
    incomingPending.remove(u)
    outgoing.remove(u)
    silentAnswer.remove(u)
  }

  private func makeHandle(_ handle: String) -> CXHandle {
    let isNumber = !handle.isEmpty && handle.allSatisfy { "+*#0123456789".contains($0) }
    return CXHandle(type: isNumber ? .phoneNumber : .generic, value: handle)
  }

  // MARK: Dart -> CallKit

  func reportIncoming(
    key: String, handle: String, name: String, completion: @escaping (Error?) -> Void
  ) {
    if uuidByKey[key] != nil { completion(nil); return }
    let u = register(key)
    incomingPending.insert(u)
    let upd = CXCallUpdate()
    upd.remoteHandle = makeHandle(handle)
    upd.localizedCallerName = name.isEmpty ? handle : name
    upd.hasVideo = false
    upd.supportsHolding = true
    upd.supportsGrouping = false
    upd.supportsUngrouping = false
    upd.supportsDTMF = true
    audio.configureSession()
    provider.reportNewIncomingCall(with: u, update: upd) { [weak self] err in
      if err != nil { self?.forget(u) }
      completion(err)
    }
  }

  func reportOutgoing(
    key: String, handle: String, name: String, completion: @escaping (Error?) -> Void
  ) {
    if uuidByKey[key] != nil { completion(nil); return }
    let u = register(key)
    outgoing.insert(u)
    audio.configureSession()
    let action = CXStartCallAction(call: u, handle: makeHandle(handle))
    action.contactIdentifier = name.isEmpty ? nil : name
    controller.request(CXTransaction(action: action)) { [weak self] err in
      if err != nil { self?.forget(u) }
      completion(err)
    }
  }

  func reportConnected(key: String) {
    guard let u = uuidByKey[key] else { return }
    if outgoing.contains(u) {
      provider.reportOutgoingCall(with: u, connectedAt: nil)
    } else if incomingPending.contains(u) {
      // Answered from the app UI: tell CallKit (this activates the audio session).
      silentAnswer.insert(u)
      controller.request(CXTransaction(action: CXAnswerCallAction(call: u))) { [weak self] err in
        if err != nil { self?.silentAnswer.remove(u) }
      }
    }
  }

  func reportEnded(key: String, reason: String) {
    guard let u = uuidByKey[key] else { return }
    let r: CXCallEndedReason
    switch reason {
    case "failed", "error": r = .failed
    case "unanswered", "missed", "noAnswer": r = .unanswered
    case "answeredElsewhere": r = .answeredElsewhere
    case "declinedElsewhere": r = .declinedElsewhere
    default: r = .remoteEnded
    }
    provider.reportCall(with: u, endedAt: Date(), reason: r)
    forget(u)
  }

  // MARK: CXProviderDelegate

  func providerDidReset(_ provider: CXProvider) {
    for (_, k) in keyByUUID { onAction?("end", k) }
    uuidByKey.removeAll()
    keyByUUID.removeAll()
    incomingPending.removeAll()
    outgoing.removeAll()
    silentAnswer.removeAll()
  }

  func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
    audio.configureSession()
    provider.reportOutgoingCall(with: action.callUUID, startedConnectingAt: nil)
    action.fulfill()
  }

  func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
    audio.configureSession()
    incomingPending.remove(action.callUUID)
    if silentAnswer.remove(action.callUUID) == nil, let k = keyByUUID[action.callUUID] {
      onAction?("answer", k)
    }
    action.fulfill()
  }

  func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
    if let k = keyByUUID[action.callUUID] {
      onAction?(incomingPending.contains(action.callUUID) ? "decline" : "end", k)
    }
    forget(action.callUUID)
    action.fulfill()
  }

  func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
    if let k = keyByUUID[action.callUUID] { onAction?(action.isOnHold ? "hold" : "unhold", k) }
    action.fulfill()
  }

  func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
    if let k = keyByUUID[action.callUUID] { onAction?(action.isMuted ? "mute" : "unmute", k) }
    action.fulfill()
  }

  func provider(_ provider: CXProvider, perform action: CXPlayDTMFCallAction) {
    if let k = keyByUUID[action.callUUID] { onDTMF?(k, action.digits) }
    action.fulfill()
  }

  func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {
    action.fail()
  }

  func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
    onAudioSession?(true)
  }

  func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
    onAudioSession?(false)
  }
}
