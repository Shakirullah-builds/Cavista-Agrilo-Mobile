import 'package:flutter/material.dart';
import 'package:impulse_mobile/core/constants/colors.dart';

// Wave Animation Widget
class AnalyzingWave extends StatefulWidget {
  final Color color;
  final double size;
  
  const AnalyzingWave({
    super.key,
    this.color = AppColors.primaryColor,
    this.size = 60,
  });

  @override
  State<AnalyzingWave> createState() => _AnalyzingWaveState();
}

class _AnalyzingWaveState extends State<AnalyzingWave>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: WavePainter(
            progress: _controller.value,
            color: widget.color,
          ),
        );
      },
    );
  }
}

class WavePainter extends CustomPainter {
  final double progress;
  final Color color;

  WavePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;

    // Draw multiple expanding circles
    for (int i = 0; i < 3; i++) {
      final offsetProgress = (progress + i * 0.33) % 1.0;
      final currentRadius = radius + (radius * offsetProgress);
      final opacity = 1.0 - offsetProgress;
      
      paint.color = color.withValues(alpha: opacity);
      canvas.drawCircle(center, currentRadius, paint);
    }
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}