import Flutter
import UIKit

public class NomoWebviewPlugin: NSObject, FlutterPlugin {

  let byMessenger = nil;
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "app.nomo.plugin/nomo_webview", binaryMessenger: registrar.messenger())
    let instance = NomoWebviewPlugin()
    byMessenger = registrar.messenger()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "takeScreenshot":
      let args = call.arguments
      result(takeScreenshot(viewID, byMessenger))
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func takeScreenshot(viewID: viewID) -> [UInt8] {
    let view = NomoWebView(viewID, byMessenger)
    return view.takeScreenshot()
  }
}