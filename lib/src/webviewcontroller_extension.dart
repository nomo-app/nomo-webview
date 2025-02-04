import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:nomo_webview/nomo_webview.dart';
import 'package:flutter/material.dart';

import 'nomo_webview_platform_interface.dart';

import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

final Map<NomoController, BuildContext> _contextMap = {};

class NomoController {
  WebViewController c;
  int? localServerPort;
  int? viewID;

  NomoController({
    required this.c,
  }) {
    if (Platform.isAndroid) {
      final platform = c.platform as AndroidWebViewController;
      viewID = platform.webViewIdentifier;
    } else if (Platform.isIOS || Platform.isMacOS) {
      final platform = c.platform as WebKitWebViewController;
      viewID = platform.webViewIdentifier;
    } else {
      throw "Nomo Controller not implemented for this platform";
    }
  }

  Future<dynamic> evaluateJavascript({required String source}) {
    return c.runJavaScript(source);
  }

  void updateBuildContext(BuildContext context) {
    _contextMap[this] = context;
  }

  /// We recommend to use "NomoWebViewWidget" to always get a fresh BuildContext
  BuildContext? getBuildContext() {
    final context = _contextMap[this];
    return context;
  }

  /// Creates a JavaScript/Dart bridge on a WebViewController.
  ///
  /// @param jsHandler The function that should process invocations from JavaScript.
  /// @param argsFromDart Optional arguments that can be processed by "jsHandler"
  /// @param context An optional BuildContext that gets passed to "jsHandler"
  /// @param rawMessageHandler An optional handler for processing raw messages from JavaScript
  void nomoInitJsBridge({
    required JsHandler jsHandler,
    dynamic argsFromDart,
    void Function(String)? rawMessageHandler,
    BuildContext? context,
  }) async {
    if (_contextMap[this] == null && context != null) {
      updateBuildContext(context);
    }
    Future<void> jsInjector(String jsCode) async {
      await evaluateJavascript(source: jsCode);
    }

    c.addJavaScriptChannel('NOMOJSChannel', onMessageReceived: (message) async {
      // https://stackoverflow.com/questions/53689662/flutter-webview-two-way-communication-with-javascript
      final messageFromJs = message.message;
      if (rawMessageHandler != null) {
        rawMessageHandler(messageFromJs);
      }
      handleMessageFromJavaScript(
        messageFromJs: messageFromJs,
        argsFromDart: argsFromDart,
        jsHandler: jsHandler,
        jsInjector: jsInjector,
        // we prefer the context from the last build because we assume it is more likely to be valid
        context: getBuildContext(),
      );
    });
  }

  Future<Uint8List?> takeScreenshot() {
    return NomoWebviewPlatform.instance.takeScreenshot(viewID!);
  }

  Future<String?> getPlatformVersion() {
    return NomoWebviewPlatform.instance.getPlatformVersion();
  }

  Future<dynamic> runJavaScript(String code) async {
    return await evaluateJavascript(source: code);
  }
}
