import Foundation
import WebKit

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

import FlutterEngine
import webview_flutter_wkwebview

public class NomoWebView {
    private Int64 webViewId;
    private FlutterPluginRegistry registry;

    public NomoWebView(viewId: Int64, byMessenger: FlutterPluginRegistry) {
        registry = byMessenger
        webViewId = viewId
    }

    public takeScreenShot() -> [UInt8] {
        WKWebView webView = FWFWebViewFlutterWKWebViewExternalAPI.webView(idnetifier: webViewId, registry: byMessenger);
        if (webView != null) {
            var imageData: Data? = nil
            webView.takeSnapshot(with: nil, completitionHandler: {(image, error) -> Void in
            if let screenshot = image {
                if let with = with {
                    switch with["compressFormat"] as! String {
                    case "JPEG":
                        let quality = Float(with["quality"] as! Int) / 100
                        imageData = screenshot.jpegData(compressionQuality: CGFloat(quality))
                        break
                    case "PNG":
                        imageData = screenshot.pngData()
                        break
                    default:
                        imageData = screenshot.pngData()
                    }
                }
                else {
                    imageData = screenshot.pngData()
                }
            }
        })
        }
        return imageData;
    }
}