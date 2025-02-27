import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// generic_js_bridge.dart does not depend on any particular WebView implementation.

class KnownJsHandlerError extends Error implements UnsupportedError {
  final String message;

  KnownJsHandlerError(this.message);

  String toString() {
    return message;
  }
}

/// A JsHandler takes arguments from both Dart and JavaScript and returns a Map that gets returned to JavaScript.
/// Moreover, a JsHandler takes a "functionName" from JavaScript.
/// The contents of the returned map must be serializable to JSON.
/// A JsHandler must not silent-catch errors, otherwise the JavaScript code could not handle errors!
/// If a JsHandler catches an internal error, it should be rethrown such that JavaScript can handle the error.
typedef JsHandler = Future<Map<String, dynamic>> Function({
  required String functionName,
  required Map<String, dynamic> argsFromJS,
  required dynamic argsFromDart,
  BuildContext? context,
});

/// A JsInjector takes a String of JavaScript-code and injects it into a WebView.
/// This package provides a default implementation of JsInjector.
typedef JsInjector = Future<void> Function(String jsCode);

Future<void> handleMessageFromJavaScript({
  required String messageFromJs,
  required dynamic argsFromDart,
  required JsHandler jsHandler,
  required JsInjector jsInjector,
  BuildContext? context,
  String? callBackFunctionName,
}) async {
  if (kDebugMode) {
    // message can be a string of multiple megabytes; therefore do not print it in production!
    debugPrint("handleMessageFromJavaScript: $messageFromJs");
  }

  Map<String, dynamic> obj = {};
  try {
    obj = jsonDecode(messageFromJs);
  } catch (e) {
    messageFromJs = messageFromJs.replaceAll("\"\"", "\"");
    messageFromJs = messageFromJs.replaceAll("\"{", "{");
    messageFromJs = messageFromJs.replaceAll("}\"", "}");

    try {
      obj = jsonDecode(messageFromJs);
    } catch (e, s) {
      final resultError = jsonEncode({
        "exception": e.toString(),
        "dartStackTrace": s.toString(),
      });

      //try to extract invocationID to show better error
      String? invocationID = messageFromJs.substring(
          messageFromJs.indexOf("invocationID") + "invocationID".length + 3,
          messageFromJs.indexOf(
              "\"",
              messageFromJs.indexOf("invocationID") +
                  "invocationID".length +
                  3));

      await _sendResultToJavaScript(
        result: resultError,
        promiseStatus: "reject",
        invocationID: invocationID.isEmpty ? "-1" : invocationID,
        jsInjector: jsInjector,
        callBackFunctionName: callBackFunctionName,
      );
      return;
    }
  }
  final String invocationID = obj["invocationID"];
  final String functionName = obj["functionName"];
  Map<String, dynamic>? argsFromJs = obj["args"];
  try {
    final Map<String, dynamic> result = await jsHandler(
        functionName: functionName,
        argsFromJS: argsFromJs ?? {},
        argsFromDart: argsFromDart,
        context: context);
    await _sendResultToJavaScript(
      result: result,
      promiseStatus: "resolve",
      invocationID: invocationID,
      jsInjector: jsInjector,
      callBackFunctionName: callBackFunctionName,
    );
  } catch (e, s) {
    final String
        resultError; // give errors as raw string instead of objects to make console.error work in JavaScript
    if (e is KnownJsHandlerError) {
      // known error cases like "user errors": give a simple error message to JavaScript, without any stackTrace
      resultError = jsonEncode({
        functionName: e.toString(),
      });
    } else {
      // those are unknown(!) errors: give a stackTrace to JavaScript to enable debugging
      resultError = jsonEncode({
        "exception": e.toString(),
        "dartStackTrace": s.toString(),
      });
    }
    await _sendResultToJavaScript(
      result: resultError,
      promiseStatus: "reject",
      invocationID: invocationID,
      jsInjector: jsInjector,
      callBackFunctionName: callBackFunctionName,
    );
  }
}

Future<void> _sendResultToJavaScript({
  required dynamic result,
  required String promiseStatus,
  required String invocationID,
  required JsInjector jsInjector,
  String? callBackFunctionName,
}) async {
  final Map<String, dynamic> resultMap = {
    "status": promiseStatus,
    "invocationID": invocationID,
    "result": result,
  };
  final responseJson = jsonEncode(resultMap);
  final responseBytes = utf8.encode(responseJson);
  final responseBase64 = base64.encode(responseBytes);

  final returnForJs =
      '${callBackFunctionName ?? "fulfillPromiseFromFlutter"}(\'$responseBase64\')';

  await jsInjector(returnForJs);
}
