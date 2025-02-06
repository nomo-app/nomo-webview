import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'nomo_webview_platform_interface.dart';

/// An implementation of [NomoWebviewPlatform] that uses method channels.
class MethodChannelNomoWebview extends NomoWebviewPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('app.nomo.plugin/nomo_webview');

  @override
  Future<Uint8List?> takeScreenshot(int viewID) async {
    final canvas = await methodChannel
        .invokeMethod<Uint8List?>('takeScreenshot', {'viewID': viewID});
    return canvas;
  }

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
