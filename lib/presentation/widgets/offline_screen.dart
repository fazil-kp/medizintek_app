import 'package:flutter/material.dart';
import 'package:medizintek_app/services/connectivity_service.dart';

class OfflineScreen extends StatefulWidget {
  final VoidCallback? onRetry;

  const OfflineScreen({super.key, this.onRetry});

  @override
  State<OfflineScreen> createState() => _OfflineScreenState();
}

class _OfflineScreenState extends State<OfflineScreen> {
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    // Auto-retry when connectivity is restored
    _connectivityService.connectionStatus.listen((isConnected) {
      if (isConnected && mounted) {
        widget.onRetry?.call();
      }
    });
  }

  Future<void> _retryConnection() async {
    setState(() => _isRetrying = true);
    await Future.delayed(const Duration(seconds: 1)); // Small delay for UX
    final isConnected = await _connectivityService.checkConnection();
    setState(() => _isRetrying = false);

    if (isConnected) {
      widget.onRetry?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 24),
                Text(
                  'No Internet Connection',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Please check your internet connection and try again.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isRetrying ? null : _retryConnection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF129247),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isRetrying ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))) : const Text('Try Again', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
