package app.nomo.plugin.nomo_webview;

import android.webkit.WebView;
import android.webkit.WebSettings;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.webviewflutter.WebViewFlutterAndroidExternalApi;
import io.flutter.embedding.engine.FlutterEngineCache;
import java.io.ByteArrayOutputStream;
import java.io.IOException;

public class NomoWebView {
    private final FlutterEngine engine = FlutterEngineCache.getInstance().get("engine_cache");
    private int webViewId;
    public NomoWebView(@NonNull int viewId) {
        webViewId = viewId;
    }

    public byte[] takeScreenShot() {
        WebView webView = WebViewFlutterAndroidExternalApi.getWebView(engine, webViewId);
        if (webView != null) {
            int width = webView.getWidth();
            int height = webView.getHeight();
            Bitmap bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
            Canvas canvas = new Canvas(bitmap);
            webView.draw(canvas);
            ByteArrayOutputStream stream = new ByteArrayOutputStream();
            final boolean compressed = bitmap.compress(
                Bitmap.CompressFormat.PNG,
                100,
                stream);
            try {
                stream.close();
            } catch (IOException e) {
                Log.e("nomo webview", "", e);
            }
            bitmap.recycle();

            return stream.toByteArray();
        }
        return null;
    }
}