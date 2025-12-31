import 'package:flutter/material.dart';

class LoadingIndicator extends StatefulWidget {
  final double progress;
  final bool isLoading;

  const LoadingIndicator({super.key, required this.progress, required this.isLoading});

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return const SizedBox.shrink();

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: 4,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.white.withOpacity(0.95), Colors.white.withOpacity(0.85)]),
          boxShadow: [
            BoxShadow(color: const Color(0xFF129247).withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2)),
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 1)),
          ],
        ),
        child: Stack(
          children: [
            // Background subtle pattern
            Container(
              decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.grey[100]!.withOpacity(0.3), Colors.grey[50]!.withOpacity(0.1)])),
            ),

            // Main progress bar with gradient
            ClipRRect(
              child: AnimatedBuilder(
                animation: _shimmerController,
                builder: (context, child) {
                  return LinearProgressIndicator(value: widget.progress > 0 ? widget.progress / 100 : null, backgroundColor: Colors.transparent, valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF129247)));
                },
              ),
            ),

            // Shimmer effect overlay
            if (widget.progress > 0 && widget.progress < 100)
              AnimatedBuilder(
                animation: _shimmerController,
                builder: (context, child) {
                  return FractionallySizedBox(
                    widthFactor: widget.progress / 100,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Colors.transparent, Colors.white.withOpacity(0.4 * (0.5 + 0.5 * _shimmerController.value)), Colors.transparent], stops: [_shimmerController.value - 0.3, _shimmerController.value, _shimmerController.value + 0.3].map((e) => e.clamp(0.0, 1.0)).toList()),
                      ),
                    ),
                  );
                },
              ),

            // Glowing edge effect
            if (widget.progress > 0 && widget.progress < 100)
              Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: widget.progress / 100,
                  child: Container(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 3,
                      height: 4,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(color: Colors.white.withOpacity(0.8), blurRadius: 4, spreadRadius: 1),
                          BoxShadow(color: const Color(0xFF129247).withOpacity(0.6), blurRadius: 6, spreadRadius: 2),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
