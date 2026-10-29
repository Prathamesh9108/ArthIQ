import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SpendingCategoryData {
  final String label;
  final double percentage; // 0 to 100
  final Color color;

  const SpendingCategoryData({
    required this.label,
    required this.percentage,
    required this.color,
  });
}

class SpendingDonutChart extends StatelessWidget {
  final List<SpendingCategoryData> data;
  final double size;
  final double strokeWidth;

  const SpendingDonutChart({
    super.key,
    required this.data,
    this.size = 140,
    this.strokeWidth = 22,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        // Donut Chart Canvas
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _DonutChartPainter(
              data: data,
              strokeWidth: strokeWidth,
            ),
          ),
        ),
        const SizedBox(width: 24),
        // Legend List
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: item.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                        ),
                      ),
                    ),
                    Text(
                      '${item.percentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.textLightPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<SpendingCategoryData> data;
  final double strokeWidth;

  _DonutChartPainter({
    required this.data,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) - strokeWidth) / 2;

    double startAngle = -pi / 2;
    final totalPercentage = data.fold(0.0, (sum, item) => sum + item.percentage);

    for (final item in data) {
      final sweepAngle = (item.percentage / totalPercentage) * 2 * pi;

      final paint = Paint()
        ..color = item.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + 0.03, // Small gap for segment separation
        sweepAngle - 0.06,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) => true;
}
