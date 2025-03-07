# Nomo WebView

Nomo WebView is an extension of `webview_flutter` to enable web-based experiences in Flutter apps.

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
    shelf: ^1.4.1 # optional
    shelf_static: ^1.1.2 # optional
```

Afterwards, you can call `nomoInitJsBridge` to enable a bridge between Dart and JavaScript.
See the example functions below:

```
import 'package:flutter/widgets.dart';
import 'package:nomo_webview/nomo_webview.dart';

void initController(Uri uri) async {
  final internalController = WebViewController();
  final c = NomoController(c: internalController);
  c.nomoInitJsBridge(jsHandler: myJsHandler);

  // further configurations are possible below...
  await c.c.setJavaScriptMode(JavaScriptMode.unrestricted);
  await c.c.loadRequest(uri);
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
## iOS setup

We need an instance of the FlutterPluginRegistry on ios to access the native webview of the underlying
webview_flutter package.
Add the following code to your iOS AppDelegate.swift:

```
    .
    .
    .

    GeneratedPluginRegistrant.register(with: self)

    // make sure you have not already defined controller
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    // make sure this call happens after registering the plugins
    setNomoWebviewRegistry(registry: controller.pluginRegistry())
```
## Android setup

We need an instance of FlutterEngine on android to access the native webview of the underlying
webview_flutter package.
Add the following code to youre MainActivity.kt:

```
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        // make sure the next line is called before registering the plugins
        FlutterEngineCache.getInstance().put("nomo_webview_engine_cached", flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        .
        .
        .
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

## How to serve web-assets

NomoWebView works out of the box for remote URLs.
However, additional code is needed for local assets.
Similar to [CapacitorJS](https://github.com/ionic-team/capacitor/blob/5.x/android/capacitor/src/main/java/com/getcapacitor/WebViewLocalServer.java), a localhost-server is needed for serving local assets offline.

We recommend the packages https://pub.dev/packages/shelf and https://pub.dev/packages/shelf_static for launching a localhost-server.
Depending on the use case, a customized shelf handler may be needed.

For example, the following function launches a localhost-server to serve web-assets from an appdata directory:

```
import 'dart:async';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf/shelf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shelf_static/shelf_static.dart';

Future<void> startLocalHostServer() async {
  final documentsDirectory = await getApplicationDocumentsDirectory();
  final webAssetsPath = '${documentsDirectory.path}/my_webassets/';

  final int port = 8080;
  final handler = const Pipeline().addMiddleware(logRequests()).addHandler(
      createStaticHandler(webAssetsPath, defaultDocument: 'index.html'));
  await shelf_io.serve(handler, '0.0.0.0', port, shared: true);
}
```

## Does it support Desktop apps?

At the moment, this package only supports Android/iOS since the underlying `webview_flutter` does
not support Windows/Linux/macOS in embedded form.
There exist alternative WebViews that support Desktop platforms.
