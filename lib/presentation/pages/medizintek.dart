import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class Medizintek extends StatefulWidget {
  const Medizintek({super.key});

  @override
  State<Medizintek> createState() => _MedizintekState();
}

class _MedizintekState extends State<Medizintek> {
  late final WebViewController _controller;
  bool _isLoading = true;
  int _loadingProgress = 0;
  Stopwatch _loadingTimer = Stopwatch();

  @override
  void initState() {
    super.initState();
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(allowsInlineMediaPlayback: true, mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{});
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller = WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _loadingProgress = progress;
            });
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _loadingProgress = 0;
            });
            _loadingTimer.reset();
            _loadingTimer.start();
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            _loadingTimer.stop();
            setState(() {
              _isLoading = false;
            });
            debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            _loadingTimer.stop();
            setState(() {
              _isLoading = false;
            });
            debugPrint('Error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://www.medizintek.com'));

    if (controller.platform is AndroidWebViewController) {
      (controller.platform as AndroidWebViewController).setMediaPlaybackRequiresUserGesture(false);
    }

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading) _buildLoadingUI(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingUI() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated logo or icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [Colors.green.shade300, Colors.green.shade600], begin: Alignment.topLeft, end: Alignment.bottomRight),
                boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), spreadRadius: 5, blurRadius: 15, offset: const Offset(0, 3))],
              ),
              child: Icon(Icons.healing, color: Colors.white, size: 60),
            ),
            const SizedBox(height: 30),
            // Progress indicator
            Container(
              width: 200,
              child: LinearProgressIndicator(value: _loadingProgress / 100, backgroundColor: Colors.green.shade100, valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600), minHeight: 8, borderRadius: BorderRadius.circular(4)),
            ),
            const SizedBox(height: 20),
            // Progress text
            Text(
              '${_loadingProgress}%',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green.shade700),
            ),
            const SizedBox(height: 10),
            // Loading text with animation
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1500),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Text(
                    'Loading Medizintek...',
                    style: TextStyle(fontSize: 18, color: Colors.green.shade600, fontWeight: FontWeight.w500),
                  ),
                );
              },
            ),
            const SizedBox(height: 15),
            // Delay time display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.access_time, size: 20, color: Colors.green.shade600),
                  const SizedBox(width: 8),
                  Text(
                    '${_loadingTimer.elapsed.inSeconds}s',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.green.shade700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
