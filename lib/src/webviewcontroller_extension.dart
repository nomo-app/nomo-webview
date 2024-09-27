import 'dart:async';
import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:nomo_webview/nomo_webview.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';

final Map<NomoController, BuildContext> _contextMap = {};

class NomoController {
  InAppWebViewController? inAppController;
  int? localServerPort;

  NomoController({
    this.initialSettings,
    this.initialUrlRequest,
    this.initialUserScripts,
    this.onWebviewInit,
    this.onDownloadStartRequest,
    this.onReceivedHttpError,
    this.onLoadResourceWithCustomScheme,
    this.onLoadStopInternal,
    this.shouldOverrideUrlLoadingInternal,
  });

  final keepAlive = InAppWebViewKeepAlive();
  //InAppWebViewKeepAlive? keepAlive;
  void onWebViewCreated(controller) {
    inAppController = controller;
    if (onWebviewInit != null) {
      onWebviewInit!(this);
    }
  }

  Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;
  int? windowId;
  HeadlessInAppWebView? headlessWebView;
  bool? preventGestureDelay;
  TextDirection? layoutDirection;
  InAppWebViewInitialData? initialData;
  String? initialFile;

  URLRequest? initialUrlRequest;
  UnmodifiableListView<UserScript>? initialUserScripts;

  PullToRefreshController?
      pullToRefreshController /* = kIsWeb ||
          ![TargetPlatform.iOS, TargetPlatform.android]
              .contains(defaultTargetPlatform)
      ? null
      : PullToRefreshController(
          settings: PullToRefreshSettings(
            color: Colors.blue,
          ),
          onRefresh: () async {
            if (defaultTargetPlatform == TargetPlatform.android) {
              reload();
            } else if (defaultTargetPlatform == TargetPlatform.iOS ||
                defaultTargetPlatform == TargetPlatform.macOS) {
              loadUrl(
                  urlRequest: URLRequest(url: await getUrl()));
            }
          },
        )*/
      ;

  InAppWebViewSettings? initialSettings;
  void Function(NomoController nomoControl)? onWebviewInit;
  FindInteractionController? findInteractionController;
  ContextMenu? contextMenu;
  void Function(InAppWebViewController controller, WebUri? url)?
      onPageCommitVisible;
  void Function(InAppWebViewController controller, String? title)?
      onTitleChanged;
  Future<AjaxRequestAction> Function(
          InAppWebViewController controller, AjaxRequest ajaxRequest)?
      onAjaxProgress;
  Future<AjaxRequestAction?> Function(
          InAppWebViewController controller, AjaxRequest ajaxRequest)?
      onAjaxReadyStateChange;

  void onConsoleMessage(
      InAppWebViewController controller, ConsoleMessage consoleMessage) {
    print(consoleMessage);
  }

  Future<bool?> Function(InAppWebViewController controller,
      CreateWindowAction createWindowAction)? onCreateWindow;
  void Function(InAppWebViewController controller)? onCloseWindow;
  void Function(InAppWebViewController controller)? onWindowFocus;
  void Function(InAppWebViewController controller)? onWindowBlur;
  void Function(InAppWebViewController controller,
      DownloadStartRequest downloadStartRequest)? onDownloadStartRequest;
  Future<JsAlertResponse?> Function(
          InAppWebViewController controller, JsAlertRequest jsAlertRequest)?
      onJsAlert;
  Future<JsConfirmResponse?> Function(
          InAppWebViewController controller, JsConfirmRequest jsConfirmRequest)?
      onJsConfirm;
  Future<JsPromptResponse?> Function(
          InAppWebViewController controller, JsPromptRequest jsPromptRequest)?
      onJsPrompt;
  void Function(InAppWebViewController controller, WebResourceRequest request,
      WebResourceError error)? onReceivedError;
  void Function(InAppWebViewController controller, WebResourceRequest request,
      WebResourceResponse errorResponse)? onReceivedHttpError;
  void Function(InAppWebViewController controller, LoadedResource resource)?
      onLoadResource;
  Future<CustomSchemeResponse?> Function(
          InAppWebViewController controller, WebResourceRequest request)?
      onLoadResourceWithCustomScheme;

  void onLoadStart(InAppWebViewController controller, WebUri? url) {
    if (onLoadStartInternal != null) {
      onLoadStartInternal!(this, controller, url);
    }
  }

  void onLoadStop(InAppWebViewController controller, WebUri? url) {
    if (onLoadStopInternal != null) {
      onLoadStopInternal!(this, controller, url);
    }
  }

  void Function(NomoController nomoControl, InAppWebViewController controller,
      WebUri? url)? onLoadStopInternal;

  void Function(NomoController nomoControl, InAppWebViewController controller,
      WebUri? url)? onLoadStartInternal;

  void Function(InAppWebViewController controller,
      InAppWebViewHitTestResult hitTestResult)? onLongPressHitTestResult;
  Future<bool?> Function(InAppWebViewController controller, WebUri? url,
      PlatformPrintJobController? printJobController)? onPrintRequest;
  void Function(InAppWebViewController controller, int progress)?
      onProgressChanged;
  Future<ClientCertResponse?> Function(InAppWebViewController controller,
      URLAuthenticationChallenge challenge)? onReceivedClientCertRequest;
  Future<HttpAuthResponse?> Function(InAppWebViewController controller,
      URLAuthenticationChallenge challenge)? onReceivedHttpAuthRequest;

  Future<ServerTrustAuthResponse?> Function(InAppWebViewController controller,
      URLAuthenticationChallenge challenge)? onReceivedServerTrustAuthRequest;
  void Function(InAppWebViewController controller, int x, int y)?
      onScrollChanged;
  void Function(InAppWebViewController controller, WebUri? url, bool? isReload)?
      onUpdateVisitedHistory;
  Future<AjaxRequest?> Function(
          InAppWebViewController controller, AjaxRequest ajaxRequest)?
      shouldInterceptAjaxRequest;
  Future<FetchRequest?> Function(
          InAppWebViewController controller, FetchRequest fetchRequest)?
      shouldInterceptFetchRequest;

  Future<NavigationActionPolicy?> Function(
      NomoController nomoControl,
      InAppWebViewController controller,
      NavigationAction navigationAction)? shouldOverrideUrlLoadingInternal;

  Future<NavigationActionPolicy?> shouldOverrideUrlLoading(
      InAppWebViewController controller,
      NavigationAction navigationAction) async {
    return shouldOverrideUrlLoadingInternal != null
        ? await shouldOverrideUrlLoadingInternal!(
            this, controller, navigationAction)
        : NavigationActionPolicy.ALLOW;
  }

  Future<PermissionResponse?> onPermissionRequest(
      InAppWebViewController controller,
      PermissionRequest permissionRequest) async {
    return PermissionResponse(
        resources: permissionRequest.resources,
        action: PermissionResponseAction.GRANT);
  }

  Future<void> Function(
    InAppWebViewController controller,
    MediaCaptureState? oldState,
    MediaCaptureState? newState,
  )? onMicrophoneCaptureStateChanged;
  void Function(InAppWebViewController controller, Size oldContentSize,
      Size newContentSize)? onContentSizeChanged;

  Future<dynamic> evaluateJavascript(
      {required String source, ContentWorld? contentWorld}) {
    return inAppController!
        .evaluateJavascript(source: source, contentWorld: contentWorld);
  }

  void addJavaScriptHandler(
      {required String handlerName,
      required JavaScriptHandlerCallback callback}) {
    return inAppController!
        .addJavaScriptHandler(handlerName: handlerName, callback: callback);
  }

  Future<void> setWebContentsDebuggingEnabled(bool debuggingEnabled) {
    return InAppWebViewController.setWebContentsDebuggingEnabled(
        debuggingEnabled);
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

    addJavaScriptHandler(
        handlerName: 'NOMOJSChannel',
        callback: (message) async {
          // https://stackoverflow.com/questions/53689662/flutter-webview-two-way-communication-with-javascript
          final raw = message.toString();
          final messageFromJs = raw.substring(1, raw.length - 1);
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
          return {'test': 'test_val'};
        });
  }

  Future<dynamic> runJavaScript(String code) async {
    return await evaluateJavascript(source: code);
  }

  void injectIpfsScheme() {
    runJavaScript("""
      function replaceWithIPFSGateway() {
          // Get all elements with src attribute
          var elements = document.querySelectorAll('[src]');
          
          // Loop through each element
          elements.forEach(function(element) {
              // Get the original source URL
              var originalSrc = element.getAttribute('src');
              
              // Check if the source URL starts with "ipfs://"
              if (originalSrc.startsWith('ipfs://')) {
                  // Extract the IPFS CID from the source URL
                  var ipfsCID = originalSrc.replace('ipfs://', '');
                  
                  // Construct the HTTP gateway URL
                  var gatewayURL = 'https://ipfs.io/ipfs/';
                  
                  // Construct the final URL by combining the gateway URL and the IPFS CID
                  var finalURL = gatewayURL + ipfsCID;
                  
                  // Replace the original source URL with the final URL
                  element.setAttribute('src', finalURL);
              }
          });
      }

      // Call the function to replace source URLs with IPFS gateway URLs when the page is loaded
      window.onload = replaceWithIPFSGateway;
      """);
  }
}
