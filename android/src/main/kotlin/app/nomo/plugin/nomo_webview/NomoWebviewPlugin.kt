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
import android.os.Looper
import android.os.Handler
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugins.webviewflutter.WebViewFlutterPlugin

import android.webkit.JavascriptInterface

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
    } else if (call.method == "addJavaScriptChannel") {
      try {
        val args = call.arguments() as? Map<String?, Any?>
        val viewID = args?.get("viewID") as? Int
        if (viewID == null) {
            result.error("INVALID_ARGUMENTS", "Missing or invalid viewID", null)
            return
        }
        val channelName = args?.get("channelName") as? String
        if (channelName == null) {
          result.error("INVALID_ARGUMENTS", "Missing JS channel name", null)
          return
        }
        val jsChannel = JavaScriptChannel(channel, viewID, channelName)
        addJSInterface(jsChannel)

        result.success(channelName)
      } catch (e: Exception) {
          result.error("INVALID_ARGUMENTS", "Failed to parse arguments", e.message)
      }
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
      })
    return null;
  }

  class JavaScriptChannel(val methodChannel: MethodChannel, val webViewId: Int, val channelName: String) {

    @SuppressWarnings("unused")
    @JavascriptInterface
    fun postMessage(message: String){
      Handler(Looper.getMainLooper()).post {
      methodChannel.invokeMethod("onJSMessage", mapOf(
          "webViewId" to webViewId,
          "message" to message,
          "channelName" to channelName,
        )
      )}
    }
  }
/***
  Compatibility note. Applications targeting Build.VERSION_CODES.N or later, JavaScript state from an empty WebView is no longer persisted across navigations like loadUrl(String). For example, global variables and functions defined before calling loadUrl(String) will not exist in the loaded page. Applications should use addJavascriptInterface(Object, String) instead to persist JavaScript objects across navigations.
  https://developer.android.com/reference/android/webkit/WebView#evaluateJavascript(java.lang.String,%20android.webkit.ValueCallback%3Cjava.lang.String%3E)
***/

// ^ should we run in any issues regarding js channels
  private fun addJSInterface(jsChannel: JavaScriptChannel): Void? {
    if (!this::engine.isInitialized) {
        Log.e("NomoWebviewPlugin", "Engine not initialized")
        throw IllegalStateException("Engine not initialized")
    }
    val view = NomoWebview(jsChannel.webViewId, engine)
    view.addJSInterface(jsChannel, jsChannel.channelName)
    return null;
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
