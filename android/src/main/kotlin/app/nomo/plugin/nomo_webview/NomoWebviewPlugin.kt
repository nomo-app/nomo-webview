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

class NomoWebviewPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var engine : FlutterEngine

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "app.nomo.plugin/nomo_webview")
    channel.setMethodCallHandler(this)
    val cachedEngine = FlutterEngineCache.getInstance().get("nomo_webview_engine_cached")
    if (cachedEngine == null) {
        Log.e("NomoWebviewPlugin", "Failed to get cached engine")
        return
    }
    engine = cachedEngine
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "takeScreenshot") {
      try {
          val args = call.arguments() as? Map<String?, Any?>
          val viewID = args?.get("viewID") as? Int
          if (viewID == null) {
              result.error("INVALID_ARGUMENTS", "Missing or invalid viewID", null)
              return
          }
          result.success(takeScreenShot(viewID))
      } catch (e: Exception) {
          result.error("INVALID_ARGUMENTS", "Failed to parse arguments", e.message)
      }
    } else if (call.method == "setDownloadListener") {
      try {
        val args = call.arguments() as? Map<String?, Any?>
        val viewID = args?.get("viewID") as? Int
        if (viewID == null) {
            result.error("INVALID_ARGUMENTS", "Missing or invalid viewID", null)
            return
        }
        result.success(setDownloadListener(viewID))
      } catch (e: Exception) {
          result.error("INVALID_ARGUMENTS", "Failed to parse arguments", e.message)
      }
    } else if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else {
      result.notImplemented()
    }
  }

  private fun takeScreenShot(webViewId: Int): ByteArray {
    if (!this::engine.isInitialized) {
        Log.e("NomoWebviewPlugin", "Engine not initialized")
        throw IllegalStateException("Engine not initialized")
    }
    val view = NomoWebview(webViewId, engine)
    return view.takeScreenShot()
  }

  private fun setDownloadListener(webViewId: Int): Void? {
    if (!this::engine.isInitialized) {
        Log.e("NomoWebviewPlugin", "Engine not initialized")
        throw IllegalStateException("Engine not initialized")
    }
    val view = NomoWebview(webViewId, engine)
    view.setDownloadListener({webViewId, url, userAgent, contentDisposition, mimeType, guessedFileName, contentLength ->
      channel.invokeMethod("onDownloadStart", mapOf(
        "webViewId" to webViewId,
        "url" to url,
        "userAgent" to userAgent,
        "contentDisposition" to contentDisposition,
        "mimeType" to mimeType,
        "guessedFileName" to guessedFileName,
        "contentLength" to contentLength,
      ))
    return null;
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
