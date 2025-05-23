import 'dart:io';

// Import for Android features.
// ignore: depend_on_referenced_packages
import 'package:webview_flutter_android/webview_flutter_android.dart';

// Import for iOS features.
//import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

bool _remoteDebuggingEnabled = false;

void enableMobileRemoteDebugging() {
  if (_remoteDebuggingEnabled) {
    return;
  }
  _remoteDebuggingEnabled = true;

  if (Platform.isAndroid) {
    AndroidWebViewController.enableDebugging(true);
  }
}
