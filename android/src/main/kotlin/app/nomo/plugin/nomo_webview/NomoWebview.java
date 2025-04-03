package app.nomo.plugin.nomo_webview;

import android.webkit.DownloadListener;
import android.webkit.URLUtil;
import android.webkit.WebSettings;
import android.webkit.WebView;
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
import java.util.function.Function;

interface OnDownloadStart {
    void onDownload(int webViewId, String url, String userAgent, String contentDisposition, String mimeType, String guessedFileName, long contentLength);
}

public class NomoWebview {
    private int webViewId;
    private FlutterEngine engine;
    public NomoWebview(@NonNull int viewId, @NonNull FlutterEngine flutterEngine) {
        webViewId = viewId;
        engine = flutterEngine;
    }
    class DownloadStartListener implements DownloadListener {

        private final OnDownloadStart downloadStart;
        private final int webViewId;

        public DownloadStartListener(int webViewId, OnDownloadStart onDownloadStart) {
            this.webViewId = webViewId;
            this.downloadStart = onDownloadStart;
        }

        @Override
        public void onDownloadStart(String url, String userAgent, String contentDisposition, String mimeType, long contentLength) {

            if (downloadStart != null) {
                downloadStart.onDownload(this.webViewId, url, userAgent, contentDisposition, mimeType, URLUtil.guessFileName(url, contentDisposition, mimeType), contentLength);
            }
        }
    }

    public byte[] takeScreenShot() {
        WebView webView = WebViewFlutterAndroidExternalApi.getWebView(engine, webViewId);
        Bitmap bitmap = null;
        ByteArrayOutputStream stream = null;
        if (webView != null) {
            int width = webView.getWidth();
            int height = webView.getHeight();
            bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
            Canvas canvas = new Canvas(bitmap);
            webView.draw(canvas);
            stream = new ByteArrayOutputStream();
            final boolean compressed = bitmap.compress(
                Bitmap.CompressFormat.PNG,
                100,
                stream);
            if (!compressed) {
                Log.e("nomo webview", "Failed to compress bitmap");
                if (stream != null) {
                    try {
                        stream.close();
                    } catch (IOException e) {
                        Log.e("nomo webview", "", e);
                    }
                }
                if (bitmap != null) {
                    bitmap.recycle();
                }
                return null;
            }
            if (bitmap != null) {
                bitmap.recycle();
            }
            return stream.toByteArray();
        }
        return null;
    }

    public void setDownloadListener(OnDownloadStart onDownloadStart) {
        WebView webView = WebViewFlutterAndroidExternalApi.getWebView(engine, webViewId);
        if(webView != null) {
            webView.setDownloadListener(new DownloadStartListener(webViewId, onDownloadStart));
        }
    }
}