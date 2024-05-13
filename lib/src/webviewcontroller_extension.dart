import 'package:flutter/widgets.dart';
import 'package:nomo_webview/nomo_webview.dart';
import 'package:nomo_webview/src/generic_js_bridge.dart';
import 'package:webview_flutter/webview_flutter.dart';

final Map<WebViewController, BuildContext> _contextMap = {};

extension NomoExt on WebViewController {
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
    if (context != null) {
      updateBuildContext(context);
    }
    Future<void> jsInjector(String jsCode) async {
      await runJavaScriptReturningResult(jsCode);
    }

    addJavaScriptChannel('NOMOJSChannel', onMessageReceived: (message) async {
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
