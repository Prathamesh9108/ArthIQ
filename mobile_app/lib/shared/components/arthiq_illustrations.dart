import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Vector illustrations painted dynamically with high fidelity
class ArthIqLogoWidget extends StatelessWidget {
  final double size;
  final bool withBackground;

  const ArthIqLogoWidget({
    super.key,
    this.size = 80,
    this.withBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: withBackground ? const Color(0xFF0F1E2E) : Colors.transparent,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: withBackground
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ]
            : null,
      ),
      child: CustomPaint(
        painter: _ArthIqLogoPainter(),
      ),
    );
  }
}

class _ArthIqLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Draw stylized 'A' checkmark & arrow in emerald green & teal
    final strokeWidth = w * 0.14;

    final paint1 = Paint()
      ..color = const Color(0xFF65E6B4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final paint2 = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Main left-to-top slash
    final path1 = Path();
    path1.moveTo(w * 0.26, h * 0.72);
    path1.lineTo(w * 0.52, h * 0.28);
    path1.lineTo(w * 0.76, h * 0.68);
    canvas.drawPath(path1, paint1);

    // Dynamic horizontal & upward arrow slash
    final path2 = Path();
    path2.moveTo(w * 0.38, h * 0.56);
    path2.lineTo(w * 0.74, h * 0.56);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Onboarding 1: Track expenses illustration
class TrackExpensesIllustration extends StatelessWidget {
  final double size;
  const TrackExpensesIllustration({super.key, this.size = 240});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TrackExpensesPainter(),
      ),
    );
  }
}

class _TrackExpensesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Soft mint circle background
    final bgPaint = Paint()..color = const Color(0xFFE8F9F3);
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.44, bgPaint);

    // Decorative floating leaves / coin
    final leafPaint = Paint()..color = const Color(0xFF65E6B4);
    canvas.drawCircle(Offset(w * 0.8, h * 0.28), 12, leafPaint);
    canvas.drawCircle(Offset(w * 0.2, h * 0.7), 8, leafPaint);

    // Smartphone
    final phoneRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.54, h * 0.52), width: w * 0.42, height: h * 0.64),
      const Radius.circular(18),
    );
    final phonePaint = Paint()..color = const Color(0xFF101A2C);
    canvas.drawRRect(phoneRect, phonePaint);

    // Phone screen
    final screenRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.54, h * 0.52), width: w * 0.36, height: h * 0.58),
      const Radius.circular(14),
    );
    final screenPaint = Paint()..color = Colors.white;
    canvas.drawRRect(screenRect, screenPaint);

    // Graphs inside screen
    final barPaint = Paint()..color = const Color(0xFF65E6B4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.40, h * 0.45, w * 0.05, h * 0.15), const Radius.circular(4)),
      barPaint,
    );
    final barPaint2 = Paint()..color = const Color(0xFF54A0FF);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.48, h * 0.38, w * 0.05, h * 0.22), const Radius.circular(4)),
      barPaint2,
    );
    final barPaint3 = Paint()..color = const Color(0xFFFF9F43);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.56, h * 0.48, w * 0.05, h * 0.12), const Radius.circular(4)),
      barPaint3,
    );

    // Person holding phone silhouette
    final personPaint = Paint()..color = const Color(0xFF2C3E50);
    canvas.drawCircle(Offset(w * 0.28, h * 0.36), 22, personPaint); // head
    final bodyPath = Path()
      ..moveTo(w * 0.2, h * 0.75)
      ..quadraticBezierTo(w * 0.28, h * 0.48, w * 0.38, h * 0.75)
      ..close();
    final bodyPaint = Paint()..color = const Color(0xFF10B981);
    canvas.drawPath(bodyPath, bodyPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Onboarding 2: Savings Piggy Bank illustration
class SavingsPiggyIllustration extends StatelessWidget {
  final double size;
  const SavingsPiggyIllustration({super.key, this.size = 240});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SavingsPiggyPainter(),
      ),
    );
  }
}

class _SavingsPiggyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background circle
    final bgPaint = Paint()..color = const Color(0xFFE6FAF3);
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.44, bgPaint);

    // Golden falling coins
    final coinPaint = Paint()..color = const Color(0xFFFFC048);
    final coinBorder = Paint()
      ..color = const Color(0xFFFFA801)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawCircle(Offset(w * 0.48, h * 0.22), 16, coinPaint);
    canvas.drawCircle(Offset(w * 0.48, h * 0.22), 16, coinBorder);

    canvas.drawCircle(Offset(w * 0.68, h * 0.18), 11, coinPaint);
    canvas.drawCircle(Offset(w * 0.68, h * 0.18), 11, coinBorder);

    // Pink/Coral Piggy Body
    final piggyPaint = Paint()..color = const Color(0xFFFF9EA6);
    final piggyBody = Rect.fromCenter(center: Offset(w * 0.5, h * 0.58), width: w * 0.52, height: h * 0.42);
    canvas.drawOval(piggyBody, piggyPaint);

    // Piggy Snout
    final snoutPaint = Paint()..color = const Color(0xFFFF7A88);
    final snoutRect = Rect.fromCenter(center: Offset(w * 0.28, h * 0.60), width: w * 0.16, height: h * 0.22);
    canvas.drawOval(snoutRect, snoutPaint);

    // Nostrils
    final nostrilPaint = Paint()..color = const Color(0xFFD63031);
    canvas.drawCircle(Offset(w * 0.26, h * 0.59), 3, nostrilPaint);
    canvas.drawCircle(Offset(w * 0.26, h * 0.64), 3, nostrilPaint);

    // Eye
    final eyePaint = Paint()..color = const Color(0xFF2D3436);
    canvas.drawCircle(Offset(w * 0.42, h * 0.50), 4.5, eyePaint);

    // Ear
    final earPath = Path()
      ..moveTo(w * 0.48, h * 0.42)
      ..lineTo(w * 0.42, h * 0.32)
      ..lineTo(w * 0.54, h * 0.36)
      ..close();
    canvas.drawPath(earPath, snoutPaint);

    // Coin slot
    final slotPaint = Paint()..color = const Color(0xFFD63031);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(w * 0.54, h * 0.38), width: 24, height: 6), const Radius.circular(3)),
      slotPaint,
    );

    // Little Legs
    final legPaint = Paint()..color = const Color(0xFFFF7A88);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.40, h * 0.74, 18, 20), const Radius.circular(6)), legPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.58, h * 0.74, 18, 20), const Radius.circular(6)), legPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Onboarding 3: AI Financial Robot illustration
class AiRobotIllustration extends StatelessWidget {
  final double size;
  const AiRobotIllustration({super.key, this.size = 240});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _AiRobotPainter(),
      ),
    );
  }
}

class _AiRobotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background circle
    final bgPaint = Paint()..color = const Color(0xFFE8F9F3);
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.44, bgPaint);

    // Robot Antenna
    final antennaPaint = Paint()
      ..color = const Color(0xFF101A2C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawLine(Offset(w * 0.5, h * 0.32), Offset(w * 0.5, h * 0.22), antennaPaint);
    final bulbPaint = Paint()..color = const Color(0xFF65E6B4);
    canvas.drawCircle(Offset(w * 0.5, h * 0.20), 8, bulbPaint);

    // Floating speech bubbles
    final bubblePaint = Paint()..color = const Color(0xFF65E6B4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.68, h * 0.24, 38, 26), const Radius.circular(8)),
      bubblePaint,
    );

    // Robot Head
    final headRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.44), width: w * 0.44, height: h * 0.32),
      const Radius.circular(24),
    );
    final headPaint = Paint()..color = Colors.white;
    final headBorder = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRRect(headRect, headPaint);
    canvas.drawRRect(headRect, headBorder);

    // Visor / Screen
    final visorRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.44), width: w * 0.34, height: h * 0.20),
      const Radius.circular(16),
    );
    final visorPaint = Paint()..color = const Color(0xFF101A2C);
    canvas.drawRRect(visorRect, visorPaint);

    // Glowing Cyan / Mint Eyes
    final eyePaint = Paint()..color = const Color(0xFF65E6B4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.40, h * 0.40, 14, 20), const Radius.circular(7)),
      eyePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.54, h * 0.40, 14, 20), const Radius.circular(7)),
      eyePaint,
    );

    // Robot Body
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.70), width: w * 0.34, height: h * 0.24),
      const Radius.circular(16),
    );
    canvas.drawRRect(bodyRect, headPaint);
    canvas.drawRRect(bodyRect, headBorder);

    // Body chest light
    final chestPaint = Paint()..color = const Color(0xFF65E6B4);
    canvas.drawCircle(Offset(w * 0.5, h * 0.68), 9, chestPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
