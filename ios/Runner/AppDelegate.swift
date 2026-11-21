import Flutter
import UIKit
import UniformTypeIdentifiers

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "EndeleaFiles") {
      FilesBridge.register(with: registrar)
    }
  }
}

/// The "endelea/files" channel used by the JSON export and import: share a
/// file through the share sheet, and pick a JSON document.
final class FilesBridge: NSObject, FlutterPlugin, UIDocumentPickerDelegate {
  private var pendingOpen: FlutterResult?

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "endelea/files", binaryMessenger: registrar.messenger())
    let instance = FilesBridge()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "shareFile":
      guard let args = call.arguments as? [String: Any],
        let path = args["path"] as? String
      else {
        result(FlutterError(code: "bad_args", message: "path is required", details: nil))
        return
      }
      share(URL(fileURLWithPath: path))
      result(nil)
    case "openDocument":
      openDocument(result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private var topController: UIViewController? {
    let scene = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .first { $0.activationState == .foregroundActive }
    var controller = scene?.windows.first { $0.isKeyWindow }?.rootViewController
    while let presented = controller?.presentedViewController {
      controller = presented
    }
    return controller
  }

  private func share(_ url: URL) {
    guard let controller = topController else { return }
    let sheet = UIActivityViewController(activityItems: [url], applicationActivities: nil)
    sheet.popoverPresentationController?.sourceView = controller.view
    controller.present(sheet, animated: true)
  }

  private func openDocument(_ result: @escaping FlutterResult) {
    guard let controller = topController else {
      result(nil)
      return
    }
    pendingOpen?(nil)
    pendingOpen = result
    let picker = UIDocumentPickerViewController(
      forOpeningContentTypes: [.json, .plainText], asCopy: true)
    picker.delegate = self
    controller.present(picker, animated: true)
  }

  func documentPicker(
    _ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]
  ) {
    let result = pendingOpen
    pendingOpen = nil
    guard let url = urls.first else {
      result?(nil)
      return
    }
    result?(try? String(contentsOf: url, encoding: .utf8))
  }

  func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    pendingOpen?(nil)
    pendingOpen = nil
  }
}
