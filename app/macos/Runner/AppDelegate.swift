import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  // Closing the window hides it to the menu bar (see DesktopShell); the app
  // quits via the tray menu / Cmd+Q.
  // Fallback: if the system hands links to the delegate instead of the
  // GetURL handler installed by MainFlutterWindow (LinkBuffer), forward them
  // the same way. Dart drops a duplicate that arrives within a second.
  func application(_ application: NSApplication, open urls: [URL]) {
    for u in urls { LinkBuffer.shared.deliver(u.absoluteString) }
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return false
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
