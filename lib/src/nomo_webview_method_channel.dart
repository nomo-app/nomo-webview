import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:nomo_webview/nomo_webview.dart';

import 'nomo_webview_platform_interface.dart';

/// An implementation of [NomoWebviewPlatform] that uses method channels.
class MethodChannelNomoWebview extends NomoWebviewPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = MethodChannel('app.nomo.plugin/nomo_webview');

  @override
  void init() {
    methodChannel.setMethodCallHandler((call) async {
      try {
        return await _handleMethodCall(call);
      } catch (e, s) {
        print("$e, $s");
      }
    });
  }

  @override
  Future<Uint8List?> takeScreenshot(int viewID) async {
    final canvas = await methodChannel
        .invokeMethod<Uint8List?>('takeScreenshot', {'viewID': viewID});
    return canvas;
  }

  @override
  Future<void> setDownloadListener(
      int viewID, DownloadStartCb onDownloadStart) async {
    downloadListener = onDownloadStart;
    await methodChannel
        .invokeMethod<void>('setDownloadListener', {'viewID': viewID});
    return;
  }

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  DownloadStartCb? downloadListener;

  Future<dynamic> _handleMethodCall(MethodCall call) {
    switch (call.method) {
      case "onDownloadStart":
        downloadListener!(
          call.arguments["webViewId"],
          call.arguments["url"],
          call.arguments["userAgent"],
          call.arguments["contentDisposition"],
          call.arguments["mimeType"],
          call.arguments["guessedFileName"],
          call.arguments["contentLength"],
        );
        break;
    }
    return Future(() => null);
  }
}
