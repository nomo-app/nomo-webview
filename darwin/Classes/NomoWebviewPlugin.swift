
#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

public class NomoWebviewPlugin: NSObject, FlutterPlugin {

    public static weak var registry: FlutterPluginRegistry?
    
    deinit {
        //NSLog("deinit")
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "app.nomo.plugin/nomo_webview", binaryMessenger: registrar.messenger())
        let instance = NomoWebviewPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
            case "takeScreenshot":
                guard let args = call.arguments as? NSDictionary,
                      let viewID = args["viewID"] as? Int else {
                    result(FlutterError(code: "INVALID_ARGUMENTS",
                                      message: "Missing or invalid viewID",
                                      details: nil))
                    return
                }
                guard let registry = NomoWebviewPlugin.registry else {
                    result(FlutterError(code: "NO_REGISTRY",
                                      message: "Registry not set",
                                      details: nil))
                    return
                }
                let view = NomoWebView(viewId: viewID, registry: registry)
                view.takeScreenShot(completionHandler: { screenshot in
                    result(screenshot)
                })
            case "getPlatformVersion":
              result("iOS " + UIDevice.current.systemVersion)
            default:
              result(FlutterMethodNotImplemented)
        }
    }
}

public func setNomoWebviewRegistry(registry: FlutterPluginRegistry?) {
    if (registry != nil) {
        NomoWebviewPlugin.registry = registry
    }
}
