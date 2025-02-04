package app.nomo.plugin.nomo_webview

import androidx.annotation.NonNull
import androidx.annotation.Nullable;

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.util.Log

import android.graphics.Bitmap
import android.graphics.Canvas
import android.webkit.WebView
import android.webkit.WebSettings
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugins.webviewflutter.WebViewFlutterPlugin

class NomoWebViewPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "app.nomo.plugin/nomo_webview")
    channel.setMethodCallHandler(this)
    engine = flutterPluginBinding.getFlutterEngine()
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "takeScreenshot") {
      val args = call.arguments() as Map<String?, Any?>?
      val viewID = args?.get("viewID") as Int
      result.success(takeScreenShot(viewID));
    } else if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else {
      result.notImplemented()
    }
  }

  private fun takeScreenShot(webViewId: Int): ByteArray {
    val view = NomoWebView(webViewId)
    return view.takeScreenShot()
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
