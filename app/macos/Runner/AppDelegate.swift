import Cocoa
import FlutterMacOS
import GoogleSignIn

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  // Forward Google OAuth callback URLs back to GIDSignIn so the sign-in flow completes.
  override func application(_ application: NSApplication, open urls: [URL]) {
    for url in urls {
      GIDSignIn.sharedInstance.handle(url)
    }
  }
}
