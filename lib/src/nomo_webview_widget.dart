import 'package:flutter/widgets.dart';
import 'package:nomo_webview/nomo_webview.dart';

import 'package:flutter/material.dart';

/// NomoWebViewWidget attempts to refresh a valid BuildContext for usage by JavaScript invocations.

class NomoWebViewWidget extends StatelessWidget {
  final NomoController nomoController;

  const NomoWebViewWidget({Key? key, required this.nomoController});

  @override
  Widget build(BuildContext context) {
    // we assume that WebViewControllers are "long-lived" whereas WebViewWidgets are "short-lived"
    nomoController.updateBuildContext(context);
    return InAppWebView(
      key: key,
      keepAlive: nomoController.keepAlive,
      initialUrlRequest: nomoController.initialUrlRequest,
      initialSettings: nomoController.initialSettings,
      initialUserScripts: nomoController.initialUserScripts,
      onWebViewCreated: nomoController.onWebViewCreated,
      onReceivedHttpError: nomoController.onReceivedHttpError,
      onConsoleMessage: nomoController.onConsoleMessage,
      shouldOverrideUrlLoading: nomoController.shouldOverrideUrlLoading,
      onDownloadStartRequest: nomoController.onDownloadStartRequest,
      onLoadResourceWithCustomScheme:
          nomoController.onLoadResourceWithCustomScheme,
      onPermissionRequest: nomoController.onPermissionRequest,
    );
  }
}
