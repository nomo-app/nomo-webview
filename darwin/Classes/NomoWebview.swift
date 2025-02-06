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
        if (registry == nil) {
            completionHandler(nil)
        }
        let webView = FWFWebViewFlutterWKWebViewExternalAPI.webView(forIdentifier: webViewId, with: registry!);
        if (webView != nil) {
            webView?.takeSnapshot(with: nil, completionHandler: {(image, error) -> Void in
                var imageData: Data? = nil
                if let screenshot = image {
                    imageData = screenshot.pngData()
                }
                completionHandler(imageData)
            })
        }
    }
}
