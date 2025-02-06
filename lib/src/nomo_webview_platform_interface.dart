import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'nomo_webview_method_channel.dart';

abstract class NomoWebviewPlatform extends PlatformInterface {
  /// Constructs a TestPackagePlatform.
  NomoWebviewPlatform() : super(token: _token);

  static final Object _token = Object();

  static NomoWebviewPlatform _instance = MethodChannelNomoWebview();

  /// The default instance of [NomoWebviewPlatform] to use.
  ///
  /// Defaults to [MethodChannelNomoWebview].
  static NomoWebviewPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NomoWebviewPlatform] when
  /// they register themselves.
  static set instance(NomoWebviewPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<Uint8List?> takeScreenshot(int viewID) {
    throw UnimplementedError('takeScreenshot() has not been implemented.');
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
