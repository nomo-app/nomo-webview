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
        windowId: nomoController.windowId,
        keepAlive: nomoController.keepAlive,
        initialUrlRequest: nomoController.initialUrlRequest,
        initialFile: nomoController.initialFile,
        initialData: nomoController.initialData,
        initialSettings: nomoController.initialSettings,
        initialUserScripts: nomoController.initialUserScripts,
        pullToRefreshController: nomoController.pullToRefreshController,
        findInteractionController: nomoController.findInteractionController,
        contextMenu: nomoController.contextMenu,
        layoutDirection: nomoController.layoutDirection,
        onWebViewCreated: nomoController.onWebViewCreated,
        onLoadStart: nomoController.onLoadStart,
        onLoadStop: nomoController.onLoadStop,
        onReceivedError: nomoController.onReceivedError,
        onReceivedHttpError: nomoController.onReceivedHttpError,
        onConsoleMessage: nomoController.onConsoleMessage,
        onProgressChanged: nomoController.onProgressChanged,
        shouldOverrideUrlLoading: nomoController.shouldOverrideUrlLoading,
        onLoadResource: nomoController.onLoadResource,
        onScrollChanged: nomoController.onScrollChanged,
        onDownloadStartRequest: nomoController.onDownloadStartRequest,
        onLoadResourceWithCustomScheme:
            nomoController.onLoadResourceWithCustomScheme,
        onCreateWindow: nomoController.onCreateWindow,
        onCloseWindow: nomoController.onCloseWindow,
        onJsAlert: nomoController.onJsAlert,
        onJsConfirm: nomoController.onJsConfirm,
        onJsPrompt: nomoController.onJsPrompt,
        onReceivedHttpAuthRequest: nomoController.onReceivedHttpAuthRequest,
        onReceivedServerTrustAuthRequest:
            nomoController.onReceivedServerTrustAuthRequest,
        onReceivedClientCertRequest: nomoController.onReceivedClientCertRequest,
        shouldInterceptAjaxRequest: nomoController.shouldInterceptAjaxRequest,
        onAjaxReadyStateChange: nomoController.onAjaxReadyStateChange,
        onAjaxProgress: nomoController.onAjaxProgress,
        shouldInterceptFetchRequest: nomoController.shouldInterceptFetchRequest,
        onUpdateVisitedHistory: nomoController.onUpdateVisitedHistory,
        onPrintRequest: nomoController.onPrintRequest,
        onLongPressHitTestResult: nomoController.onLongPressHitTestResult,
        onEnterFullscreen: nomoController.onEnterFullscreen,
        onExitFullscreen: nomoController.onExitFullscreen,
        onPageCommitVisible: nomoController.onPageCommitVisible,
        onTitleChanged: nomoController.onTitleChanged,
        onWindowFocus: nomoController.onWindowFocus,
        onWindowBlur: nomoController.onWindowBlur,
        onOverScrolled: nomoController.onOverScrolled,
        onZoomScaleChanged: nomoController.onZoomScaleChanged,
        onSafeBrowsingHit: nomoController.onSafeBrowsingHit,
        onPermissionRequest: nomoController.onPermissionRequest,
        onGeolocationPermissionsShowPrompt:
            nomoController.onGeolocationPermissionsShowPrompt,
        onGeolocationPermissionsHidePrompt:
            nomoController.onGeolocationPermissionsHidePrompt,
        shouldInterceptRequest: nomoController.shouldInterceptRequest,
        onRenderProcessGone: nomoController.onRenderProcessGone,
        onRenderProcessResponsive: nomoController.onRenderProcessResponsive,
        onRenderProcessUnresponsive: nomoController.onRenderProcessUnresponsive,
        onFormResubmission: nomoController.onFormResubmission,
        onReceivedIcon: nomoController.onReceivedIcon,
        onReceivedTouchIconUrl: nomoController.onReceivedTouchIconUrl,
        onReceivedLoginRequest: nomoController.onReceivedLoginRequest,
        onPermissionRequestCanceled: nomoController.onPermissionRequestCanceled,
        onRequestFocus: nomoController.onRequestFocus,
        onWebContentProcessDidTerminate:
            nomoController.onWebContentProcessDidTerminate,
        onDidReceiveServerRedirectForProvisionalNavigation:
            nomoController.onDidReceiveServerRedirectForProvisionalNavigation,
        onNavigationResponse: nomoController.onNavigationResponse,
        shouldAllowDeprecatedTLS: nomoController.shouldAllowDeprecatedTLS,
        onCameraCaptureStateChanged: nomoController.onCameraCaptureStateChanged,
        onMicrophoneCaptureStateChanged:
            nomoController.onMicrophoneCaptureStateChanged,
        onContentSizeChanged: nomoController.onContentSizeChanged,
        gestureRecognizers: nomoController.gestureRecognizers,
        headlessWebView: nomoController.headlessWebView,
        preventGestureDelay: nomoController.preventGestureDelay);
  }
}


/*
  Future<String> get tRexRunnerHtml => throw UnimplementedError(
      'tRexRunnerHtml is not implemented on the current platform');

  Future<String> get tRexRunnerCss => throw UnimplementedError(
      'tRexRunnerCss is not implemented on the current platform');
        */
