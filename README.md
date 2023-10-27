# Nomo WebView

Nomo WebView is an extension of `flutter_webview` to enable web-based experiences in Flutter apps.

This package is inspired by CapacitorJS and Ionic Portals, but for Flutter apps instead of "native
apps" that are written in Java/Kotlin/Swift.

## Why Nomo WebView?

The vast majority of Flutter apps in the app stores need to integrate web assets for specific screens or
experiences.
It could be for registration forms, features such as decentralized apps, or to bring web experiences
to mobile without needing to port them to Flutter.

Despite how common this need is, bringing these web experiences to Flutter apps is not straightforward.
To integrate Flutter functionality in a safe and controlled way, it is often needed to expand stock WebViews.
Enter Nomo WebView, an extension of https://pub.dev/packages/webview_flutter.
With Nomo WebView, you can:

- Add web-based features and experiences to an existing Flutter app.
- Invoke Dart-functions from JavaScript and vice versa.
- Convert between JavaScript-Promises and Dart-Futures, such that async/await works seamless across
  language boundaries.

Internally, Nomo WebView is powering the WebOn-architecture of the [Nomo App](https://nomo.app).

## How to use in Dart/Flutter

First, add this package as a Git-submodule to your Flutter app by using Git-commands:

````
git submodule add https://github.com/nomo-app/nomo-webview.git packages/nomo-webview
````

Next, expand your pubspec.yaml accordingly:

```
dependencies:
    nomo_webview:
        path: packages/nomo-webview
```

Afterwards, you can call `nomoInitJsBridge` to enable a bridge between Dart and JavaScript.
See the example functions below:

```
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
```

## How to use in JavaScript

Once you have integrated this package within Dart/Flutter, you can invoke Dart-functions from
JavaScript.
For this, you will need a bridge-module in JavaScript.
See the following examples of bridge-modules:

- JavaScript to Dart
  bridge: https://github.com/nomo-app/nomo-webon-kit/blob/main/nomo-webon-kit/dist/dart_interface.js
- TypeScript to Dart
  bridge: https://github.com/nomo-app/nomo-webon-kit/blob/main/nomo-webon-kit/src/dart_interface.ts

See https://github.com/nomo-app/nomo-webon-kit/blob/main/README.md for documentation on how to use
those bridge-modules.
You can install the whole `nomo-webon-kit` or you can copy parts of it to suit your needs.

## Does it support Desktop apps?

At the moment, this package only supports Android/iOS since the underlying `webview_flutter` does
not support Windows/Linux/macOS.
See https://github.com/flutter/flutter/issues/41725 for more details about Desktop support.
There exist alternative WebViews that support Desktop platforms.
