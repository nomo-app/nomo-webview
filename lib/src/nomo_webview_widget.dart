import 'package:flutter/widgets.dart';
import 'package:nomo_webview/nomo_webview.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

/// NomoWebViewWidget attempts to refresh a valid BuildContext for usage by JavaScript invocations.
class NomoWebViewWidget extends WebViewWidget {
  final NomoController nomoController;

  NomoWebViewWidget({super.key, required this.nomoController})
      : super.fromPlatformCreationParams(
          params: PlatformWebViewWidgetCreationParams(
            controller: nomoController.c.platform,
            layoutDirection: TextDirection.ltr,
            gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
          ),
        );

  @override
  Widget build(BuildContext context) {
    // we assume that WebViewControllers are "long-lived" whereas WebViewWidgets are "short-lived"
    nomoController.updateBuildContext(context);
    return super.build(context);
  }
}
