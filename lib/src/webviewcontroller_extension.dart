import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:nomo_webview/nomo_webview.dart';
import 'package:flutter/material.dart';

final Map<NomoController, BuildContext> _contextMap = {};

class NomoController {
  WebViewController c;
  int? localServerPort;

  NomoController({
    required this.c,
  });

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

  Future<dynamic> runJavaScript(String code) async {
    return await evaluateJavascript(source: code);
  }
}
