import Foundation
import WebKit

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

import webview_flutter_wkwebview

public class NomoWebView {
    
    var webViewId: Int
    weak var registry: FlutterPluginRegistry?
    
    init(viewId: Int, registry: FlutterPluginRegistry) {
        self.registry = registry
        self.webViewId = viewId
    }
    
    deinit {
        //NSLog("deinit NomoWebview")
    }

    public func takeScreenShot(completionHandler: @escaping(_ screenshot: Data?) -> Void) {
        guard let registry = registry else {
            NSLog("Registry is nil")
            completionHandler(nil)
            return
        }
        guard let webView = FWFWebViewFlutterWKWebViewExternalAPI.webView(forIdentifier: Int64(webViewId), withPluginRegistry: registry) else {
            NSLog("WebView not found for ID: \(webViewId)")
            completionHandler(nil)
            return
         }
        webView.takeSnapshot(with: Optional<WKSnapshotConfiguration>.none, completionHandler: {(image, error) -> Void in
            if let error = error {
                NSLog("Screenshot failed: \(error.localizedDescription)")
                completionHandler(nil)
                return
            }
            guard let screenshot = image else {
                NSLog("Screenshot image is nil")
                completionHandler(nil)
                return
            }
            completionHandler(screenshot.pngData())
        })
    }
}
