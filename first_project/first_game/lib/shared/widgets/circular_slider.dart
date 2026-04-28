import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:first_game/core/constants/app_colors.dart';

class CircularSlider extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final String label;
  final ValueChanged<double> onChanged;
  final Color color;

  const CircularSlider({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 100,
    required this.label,
    required this.onChanged,
    this.color = AppColors.primary,
  });

  @override
  State<CircularSlider> createState() => _CircularSliderState();
}

class _CircularSliderState extends State<CircularSlider> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight);
        return GestureDetector(
          onPanUpdate: (details) {
            final RenderBox box = context.findRenderObject() as RenderBox;
            final center = box.size.center(Offset.zero);
            final position = details.localPosition - center;
            final angle = math.atan2(position.dy, position.dx);
            
            // Normalize angle to 0..2PI
            double normalized = angle + math.pi / 2;
            if (normalized < 0) normalized += 2 * math.pi;
            
            // Map angle to value
            final percentage = normalized / (2 * math.pi);
            final newValue = widget.min + (widget.max - widget.min) * percentage;
            widget.onChanged(newValue.clamp(widget.min, widget.max));
          },
          child: CustomPaint(
            size: Size(size, size),
            painter: _SliderPainter(
              value: widget.value,
              min: widget.min,
              max: widget.max,
              color: widget.color,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.label,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.value.toStringAsFixed(1),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SliderPainter extends CustomPainter {
  final double value;
  final double min;
  final double max;
  final Color color;

  _SliderPainter({
    required this.value,
    required this.min,
    required this.max,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 20;
    
    // Background Track
    final trackPaint = Paint()
      ..color = AppColors.surfaceVariant.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    
    canvas.drawCircle(center, radius, trackPaint);
    
    // Active Progress
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [color, color.withOpacity(0.5)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    
    final sweepAngle = ((value - min) / (max - min)) * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
    
    // Handle (Thumb)
    final handleAngle = -math.pi / 2 + sweepAngle;
    final handleOffset = Offset(
      center.dx + radius * math.cos(handleAngle),
      center.dy + radius * math.sin(handleAngle),
    );
    
    final handlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(handleOffset, 12, handlePaint);
    canvas.drawCircle(
      handleOffset,
      12,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant _SliderPainter oldDelegate) =>
      oldDelegate.value != value || oldDelegate.color != color;
}
