import 'package:flutter/widgets.dart';
import 'package:nomo_webview/nomo_webview.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// NomoWebViewWidget attempts to refresh a valid BuildContext for usage by JavaScript invocations.
class NomoWebViewWidget extends WebViewWidget {
  final WebViewController controller;

  NomoWebViewWidget({Key? key, required this.controller})
      : super(controller: controller, key: key);

  @override
  Widget build(BuildContext context) {
    // we assume that WebViewControllers are "long-lived" whereas WebViewWidgets are "short-lived"
    controller.updateBuildContext(context);
    return super.build(context);
  }
}
