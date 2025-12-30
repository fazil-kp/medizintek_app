import 'package:flutter/material.dart';
import 'dart:math' as math;

class LoadingWidget extends StatefulWidget {
  final int loadingProgress;
  final int elapsedSeconds;

  const LoadingWidget({super.key, required this.loadingProgress, required this.elapsedSeconds});

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat(reverse: true);

    _rotateController = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))..repeat();

    _shimmerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500))..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.green.shade50, Colors.white, Colors.teal.shade50]),
      ),
      child: Stack(
        children: [
          // Animated background particles
          ...List.generate(20, (index) => _buildFloatingParticle(index)),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated logo with multiple layers
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer rotating ring
                    AnimatedBuilder(
                      animation: _rotateController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotateController.value * 2 * math.pi,
                          child: Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.green.shade200.withOpacity(0.3), width: 2),
                            ),
                          ),
                        );
                      },
                    ),

                    // Pulsing glow effect
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          width: 140 + (_pulseController.value * 20),
                          height: 140 + (_pulseController.value * 20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(colors: [Colors.green.withOpacity(0.3 * (1 - _pulseController.value)), Colors.transparent]),
                          ),
                        );
                      },
                    ),

                    // Main logo container
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [Colors.green.shade400, Colors.teal.shade600], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.4), spreadRadius: 5, blurRadius: 20, offset: const Offset(0, 8))],
                      ),
                      child: const Icon(Icons.healing, color: Colors.white, size: 65),
                    ),
                  ],
                ),

                const SizedBox(height: 50),

                // App name with shimmer effect
                AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, child) {
                    return ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(colors: [Colors.green.shade700, Colors.green.shade300, Colors.green.shade700], stops: [_shimmerController.value - 0.3, _shimmerController.value, _shimmerController.value + 0.3], tileMode: TileMode.mirror).createShader(bounds);
                      },
                      child: const Text(
                        'Medizintek',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),

                Text(
                  'Healthcare Innovation',
                  style: TextStyle(fontSize: 14, color: Colors.green.shade600, fontWeight: FontWeight.w500, letterSpacing: 2),
                ),

                const SizedBox(height: 40),

                // Progress bar with gradient
                Container(
                  width: 280,
                  height: 12,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.green.shade50,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      children: [
                        // Progress fill
                        FractionallySizedBox(
                          widthFactor: widget.loadingProgress / 100,
                          child: Container(
                            decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.green.shade400, Colors.teal.shade500])),
                          ),
                        ),

                        // Shimmer effect on progress
                        AnimatedBuilder(
                          animation: _shimmerController,
                          builder: (context, child) {
                            return FractionallySizedBox(
                              widthFactor: widget.loadingProgress / 100,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Colors.transparent, Colors.white.withOpacity(0.3), Colors.transparent], stops: [_shimmerController.value - 0.2, _shimmerController.value, _shimmerController.value + 0.2]),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Progress percentage
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: widget.loadingProgress.toDouble()),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, value, child) {
                    return Text(
                      '${value.toInt()}%',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                    );
                  },
                ),

                const SizedBox(height: 25),

                // Loading status with dots animation
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Loading',
                      style: TextStyle(fontSize: 16, color: Colors.green.shade600, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 4),
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        int dots = (_pulseController.value * 3).floor() + 1;
                        return Text(
                          '.' * dots.clamp(1, 3),
                          style: TextStyle(fontSize: 16, color: Colors.green.shade600, fontWeight: FontWeight.w500),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Elapsed time badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.green.shade50, Colors.white]),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.green.shade200, width: 1.5),
                    boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule, size: 20, color: Colors.green.shade600),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.elapsedSeconds}s',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.green.shade700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingParticle(int index) {
    final random = math.Random(index);
    final size = 4.0 + random.nextDouble() * 6;
    final left = random.nextDouble();
    final animationDelay = random.nextDouble() * 2;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final progress = (_pulseController.value + animationDelay) % 1.0;
        return Positioned(
          left: MediaQuery.of(context).size.width * left,
          top: MediaQuery.of(context).size.height * progress,
          child: Opacity(
            opacity: (0.3 - (progress * 0.3)).clamp(0.0, 1.0),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index % 2 == 0 ? Colors.green.shade300 : Colors.teal.shade300,
                boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 4)],
              ),
            ),
          ),
        );
      },
    );
  }
}
