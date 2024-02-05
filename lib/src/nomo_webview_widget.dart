import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomo_app/features/webons/manifest/nomo_manifest.dart';
import 'package:nomo_router/nomo_router.dart';
import 'package:nomo_webview/nomo_webview.dart';
import 'package:webview_flutter/webview_flutter.dart';

final activeWebViewProvider =
    StateProvider.family<Key?, NomoManifest>((ref, _) {
  return null;
});

/// NomoWebViewWidget attempts to refresh a valid BuildContext for usage by JavaScript invocations.
class NomoWebViewWidget extends WebViewWidget {
  final WebViewController controller;
  final NomoManifest? manifest;

  NomoWebViewWidget({
    Key? key,
    required this.controller,
    required this.manifest,
  }) : super(controller: controller, key: key);

  @override
  Widget build(BuildContext context) {
    final key = RouteInfoProvider.of(context).route.key;

    final webview = super.build(context);

    return Consumer(
      builder: (context, ref, child) {
        /// Dev Mode
        if (manifest == null) return child!;

        final activeKey = ref.watch(activeWebViewProvider(manifest!));

        if (activeKey == null) {
          return Center(child: CircularProgressIndicator());
        }

        if (activeKey != key) {
          return SizedBox.shrink();
        }

        controller.updateBuildContext(context);
        return child!;
      },
      child: webview,
    );
  }
}
