import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  private var securityScopedUrls: [String: URL] = [:]

  override func applicationDidFinishLaunching(_ notification: Notification) {
    super.applicationDidFinishLaunching(notification)

    guard let controller = mainFlutterWindow?.contentViewController as? FlutterViewController else {
      return
    }

    let channel = FlutterMethodChannel(
      name: "markweft/security_scoped_bookmarks",
      binaryMessenger: controller.engine.binaryMessenger
    )

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(FlutterError(code: "unavailable", message: "App delegate unavailable.", details: nil))
        return
      }

      switch call.method {
      case "createBookmark":
        self.createBookmark(call: call, result: result)
      case "resolveBookmark":
        self.resolveBookmark(call: call, result: result)
      case "stopAccessing":
        self.stopAccessing(call: call, result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func createBookmark(call: FlutterMethodCall, result: FlutterResult) {
    guard
      let arguments = call.arguments as? [String: Any],
      let path = arguments["path"] as? String
    else {
      result(FlutterError(code: "invalid_arguments", message: "Missing file path.", details: nil))
      return
    }

    do {
      let url = URL(fileURLWithPath: path)
      let data = try url.bookmarkData(
        options: [.withSecurityScope],
        includingResourceValuesForKeys: nil,
        relativeTo: nil
      )
      result(FlutterStandardTypedData(bytes: data))
    } catch {
      result(
        FlutterError(
          code: "bookmark_create_failed",
          message: error.localizedDescription,
          details: path
        )
      )
    }
  }

  private func resolveBookmark(call: FlutterMethodCall, result: FlutterResult) {
    guard
      let arguments = call.arguments as? [String: Any],
      let typedData = arguments["bookmark"] as? FlutterStandardTypedData
    else {
      result(FlutterError(code: "invalid_arguments", message: "Missing bookmark data.", details: nil))
      return
    }

    do {
      var isStale = false
      let url = try URL(
        resolvingBookmarkData: typedData.data,
        options: [.withSecurityScope],
        relativeTo: nil,
        bookmarkDataIsStale: &isStale
      )

      guard url.startAccessingSecurityScopedResource() else {
        result(
          FlutterError(
            code: "bookmark_access_denied",
            message: "macOS denied access to the saved book location.",
            details: url.path
          )
        )
        return
      }

      securityScopedUrls[url.path] = url
      result(url.path)
    } catch {
      result(
        FlutterError(
          code: "bookmark_resolve_failed",
          message: error.localizedDescription,
          details: nil
        )
      )
    }
  }

  private func stopAccessing(call: FlutterMethodCall, result: FlutterResult) {
    guard
      let arguments = call.arguments as? [String: Any],
      let path = arguments["path"] as? String
    else {
      result(FlutterError(code: "invalid_arguments", message: "Missing file path.", details: nil))
      return
    }

    if let url = securityScopedUrls.removeValue(forKey: path) {
      url.stopAccessingSecurityScopedResource()
    }

    result(nil)
  }

  override func applicationWillTerminate(_ notification: Notification) {
    for url in securityScopedUrls.values {
      url.stopAccessingSecurityScopedResource()
    }
    securityScopedUrls.removeAll()
    super.applicationWillTerminate(notification)
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
