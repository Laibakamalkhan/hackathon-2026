import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class AiOrbLogo extends StatelessWidget {
  const AiOrbLogo({super.key, this.size = 100});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.orbGradient,
        boxShadow: [
          BoxShadow(
            color: Color(0x73BAC8E0),
            blurRadius: 32,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _RobotFacePainter(faceSize: size * 0.6),
      ),
    );
  }
}

class _RobotFacePainter extends CustomPainter {
  _RobotFacePainter({required this.faceSize});

  final double faceSize;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..color = AppColors.textPrimary;
    canvas.drawCircle(center + Offset(-faceSize * 0.17, -faceSize * 0.08),
        faceSize * 0.05, paint);
    canvas.drawCircle(center + Offset(faceSize * 0.17, -faceSize * 0.08),
        faceSize * 0.05, paint);

    final smile = Path()
      ..moveTo(center.dx - faceSize * 0.2, center.dy + faceSize * 0.12)
      ..quadraticBezierTo(
        center.dx,
        center.dy + faceSize * 0.25,
        center.dx + faceSize * 0.2,
        center.dy + faceSize * 0.12,
      );
    canvas.drawPath(
      smile,
      Paint()
        ..color = AppColors.textPrimary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
