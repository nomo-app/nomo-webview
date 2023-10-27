import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:nomo_webview/nomo_webview.dart';

void initController(Uri uri) async {
  final c = WebViewController();
  c.nomoInitJsBridge(jsHandler: myJsHandler);

  // further configurations are possible below...
  await c.setJavaScriptMode(JavaScriptMode.unrestricted);
  await c.loadRequest(uri);
}

Future<Map<String, dynamic>> myJsHandler({
  required String functionName,
  required Map<String, dynamic> argsFromJS,
  dynamic argsFromDart,
  BuildContext? context,
}) async {
  // argsFromDart can be anything
  if (argsFromDart is String) {
    print("argsFromDart: $argsFromDart");
  }
  if (functionName == "doSomething") {
    final dynamic x = argsFromJS["x"];
    final dynamic y = argsFromJS["y"];
    return {"result": x + y};
  } else if (functionName == "doSomethingElse") {
    return {};
  } else {
    throw KnownJsHandlerError("Unknown function $functionName");
  }
}
