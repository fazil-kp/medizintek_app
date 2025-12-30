import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final int loadingProgress;
  final int elapsedSeconds;

  const LoadingWidget({super.key, required this.loadingProgress, required this.elapsedSeconds});

  @override
  Widget build(BuildContext context) {
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
              child: LinearProgressIndicator(value: loadingProgress / 100, backgroundColor: Colors.green.shade100, valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600), minHeight: 8, borderRadius: BorderRadius.circular(4)),
            ),
            const SizedBox(height: 20),
            // Progress text
            Text(
              '${loadingProgress}%',
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
                    '${elapsedSeconds}s',
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
