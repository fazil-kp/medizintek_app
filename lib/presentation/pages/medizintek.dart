import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:medizintek_app/services/connectivity_service.dart';
import 'package:medizintek_app/presentation/widgets/offline_screen.dart';
import 'package:medizintek_app/presentation/widgets/error_screen.dart';
import 'package:medizintek_app/presentation/widgets/loading_indicator.dart';
import 'package:medizintek_app/presentation/widgets/exit_confirmation_dialog.dart';

class Medizintek extends StatefulWidget {
  const Medizintek({super.key});

  @override
  State<Medizintek> createState() => _MedizintekState();
}

class _MedizintekState extends State<Medizintek> with WidgetsBindingObserver {
  late final WebViewController _controller;
  final ConnectivityService _connectivityService = ConnectivityService();

  // App configuration
  static const String _allowedDomain = 'medizintek.com';
  static const String _homeUrl = 'https://www.medizintek.com';

  // State management
  bool _isConnected = true;
  bool _isLoading = true;
  bool _hasError = false;
  bool _controllerInitialized = false;
  int _loadingProgress = 0;
  String? _errorMessage;
  bool _canGoBack = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivityService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkConnectivityAndReload();
    }
  }

  Future<void> _initializeApp() async {
    await _connectivityService.initialize();
    _setupConnectivityListener();
    await _initializeWebView();
  }

  void _setupConnectivityListener() {
    _connectivityService.connectionStatus.listen((isConnected) {
      if (mounted) {
        setState(() => _isConnected = isConnected);
        if (isConnected && _hasError) {
          _reloadWebView();
        }
      }
    });
  }

  Future<void> _initializeWebView() async {
    late final PlatformWebViewControllerCreationParams params;

    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(allowsInlineMediaPlayback: true, mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{});
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller = WebViewController.fromPlatformCreationParams(params);

    await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    await controller.setBackgroundColor(const Color(0x00000000));

    // Configure navigation delegate with domain restrictions
    await controller.setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          if (mounted) {
            setState(() {
              _loadingProgress = progress;
              _isLoading = progress < 100;
            });
          }
        },
        onPageStarted: (String url) {
          debugPrint('Page started loading: $url');
          if (mounted) {
            setState(() {
              _hasError = false;
              _errorMessage = null;
              _isLoading = true;
            });
          }
        },
        onPageFinished: (String url) async {
          debugPrint('Page finished loading: $url');
          if (mounted) {
            setState(() {
              _isLoading = false;
              _loadingProgress = 100;
            });
            // Update back navigation capability
            _updateBackButtonState();
          }
        },
        onWebResourceError: (WebResourceError error) {
          debugPrint('WebView Error: ${error.description}');
          if (mounted) {
            setState(() {
              _hasError = true;
              _errorMessage = error.description;
              _isLoading = false;
            });
          }
        },
        onNavigationRequest: (NavigationRequest request) {
          return _handleNavigationRequest(request);
        },
      ),
    );

    // Configure Android-specific settings for security
    if (controller.platform is AndroidWebViewController) {
      final androidController = controller.platform as AndroidWebViewController;

      // Security settings
      await androidController.setMediaPlaybackRequiresUserGesture(false);
      await androidController.setGeolocationEnabled(false);
      await androidController.setAllowFileAccess(false);
    }

    // Load initial URL
    await controller.loadRequest(Uri.parse(_homeUrl));

    setState(() {
      _controller = controller;
      _controllerInitialized = true;
    });
  }

  NavigationDecision _handleNavigationRequest(NavigationRequest request) {
    final uri = Uri.parse(request.url);

    // Allow navigation within the allowed domain
    if (uri.host == _allowedDomain || uri.host == 'www.$_allowedDomain') {
      return NavigationDecision.navigate;
    }

    // Handle external URLs - open in external browser
    if (_isExternalUrl(uri)) {
      _launchExternalUrl(request.url);
      return NavigationDecision.prevent;
    }

    // Block navigation to unauthorized domains
    debugPrint('Blocked navigation to: ${request.url}');
    return NavigationDecision.prevent;
  }

  bool _isExternalUrl(Uri uri) {
    // Define what constitutes external URLs that should open in browser
    final externalSchemes = ['tel:', 'mailto:', 'https:', 'http:'];

    // Check for external schemes
    if (externalSchemes.contains(uri.scheme)) {
      // Allow tel: and mailto: always
      if (uri.scheme == 'tel:' || uri.scheme == 'mailto:') {
        return true;
      }

      // For https/http, check if it's not our domain and is likely an external link
      if (uri.host != _allowedDomain && uri.host != 'www.$_allowedDomain') {
        // Common external domains (social media, payment processors, etc.)
        final externalHosts = ['facebook.com', 'twitter.com', 'instagram.com', 'linkedin.com', 'youtube.com', 'whatsapp.com', 'telegram.org', 'paypal.com', 'stripe.com', 'google.com', 'maps.google.com', 'play.google.com', 'apps.apple.com'];

        // Check if it's a known external host or has common external patterns
        if (externalHosts.contains(uri.host) || uri.host.contains('facebook') || uri.host.contains('google') || uri.host.contains('whatsapp') || uri.host.contains('telegram')) {
          return true;
        }
      }
    }

    return false;
  }

  Future<void> _launchExternalUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching external URL: $e');
    }
  }

  Future<void> _updateBackButtonState() async {
    try {
      final canGoBack = await _controller.canGoBack();
      if (mounted) {
        setState(() => _canGoBack = canGoBack);
      }
    } catch (e) {
      debugPrint('Error checking back navigation: $e');
    }
  }

  Future<void> _checkConnectivityAndReload() async {
    final isConnected = await _connectivityService.checkConnection();
    if (isConnected && _hasError) {
      _reloadWebView();
    }
  }

  Future<void> _reloadWebView() async {
    setState(() {
      _hasError = false;
      _errorMessage = null;
    });
    await _controller.reload();
  }

  Future<bool> _handleBackPress() async {
    if (_canGoBack) {
      await _controller.goBack();
      await _updateBackButtonState();
      return false; // Don't exit app
    }
    // Show exit confirmation dialog when at root
    return await ExitConfirmationDialog.show(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent default back behavior
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        final shouldPop = await _handleBackPress();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              if (!_isConnected) OfflineScreen(onRetry: _checkConnectivityAndReload) else if (_hasError) ErrorScreen(errorMessage: _errorMessage, onRetry: _reloadWebView) else if (_controllerInitialized) WebViewWidget(controller: _controller) else const Center(child: CircularProgressIndicator()),

              // Loading indicator overlay
              LoadingIndicator(progress: _loadingProgress.toDouble(), isLoading: _isLoading),
            ],
          ),
        ),
      ),
    );
  }
}
