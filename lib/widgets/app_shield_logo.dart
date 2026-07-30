import 'package:flutter/material.dart';

class AppShieldLogo extends StatelessWidget {
  final double size;
  const AppShieldLogo({super.key, this.size = 40.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ShieldLogoPainter(),
      ),
    );
  }
}

class _ShieldLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Shield path
    final shieldPath = Path();
    shieldPath.moveTo(w * 0.5, h * 0.08);
    shieldPath.lineTo(w * 0.88, h * 0.22);
    shieldPath.cubicTo(w * 0.88, h * 0.65, w * 0.72, h * 0.88, w * 0.5, h * 0.96);
    shieldPath.cubicTo(w * 0.28, h * 0.88, w * 0.12, h * 0.65, w * 0.12, h * 0.22);
    shieldPath.close();

    // Fill left half slightly lighter red, right half slightly darker red for 3D effect
    final leftShieldPath = Path();
    leftShieldPath.moveTo(w * 0.5, h * 0.08);
    leftShieldPath.lineTo(w * 0.12, h * 0.22);
    leftShieldPath.cubicTo(w * 0.12, h * 0.65, w * 0.28, h * 0.88, w * 0.5, h * 0.96);
    leftShieldPath.close();

    final rightShieldPath = Path();
    rightShieldPath.moveTo(w * 0.5, h * 0.08);
    rightShieldPath.lineTo(w * 0.88, h * 0.22);
    rightShieldPath.cubicTo(w * 0.88, h * 0.65, w * 0.72, h * 0.88, w * 0.5, h * 0.96);
    rightShieldPath.close();

    final leftPaint = Paint()..color = const Color(0xFFED3847);
    final rightPaint = Paint()..color = const Color(0xFFC8212E);
    canvas.drawPath(leftShieldPath, leftPaint);
    canvas.drawPath(rightShieldPath, rightPaint);

    // White border outline around shield
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.05
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(shieldPath, borderPaint);

    // Eye / Magnifying reticle inside
    final center = Offset(w * 0.48, h * 0.48);
    final eyeRadius = w * 0.19;

    final whiteStroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.05;

    // Outer Circle
    canvas.drawCircle(center, eyeRadius, whiteStroke);

    // Eye outline path (almond shape)
    final eyePath = Path();
    eyePath.moveTo(center.dx - eyeRadius * 1.3, center.dy);
    eyePath.quadraticBezierTo(center.dx, center.dy - eyeRadius * 1.0, center.dx + eyeRadius * 1.3, center.dy);
    eyePath.quadraticBezierTo(center.dx, center.dy + eyeRadius * 1.0, center.dx - eyeRadius * 1.3, center.dy);
    canvas.drawPath(eyePath, whiteStroke);

    // Center Pupil (Filled white with small cut)
    final pupilPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, eyeRadius * 0.42, pupilPaint);
    
    // Pupil inner highlight dot (red)
    final innerDotPaint = Paint()..color = const Color(0xFFED3847);
    canvas.drawCircle(Offset(center.dx - eyeRadius * 0.12, center.dy - eyeRadius * 0.12), eyeRadius * 0.15, innerDotPaint);

    // Magnifying glass handle extending to bottom-right
    final handlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.055
      ..strokeCap = StrokeCap.round;
    
    canvas.drawLine(
      Offset(center.dx + eyeRadius * 0.7, center.dy + eyeRadius * 0.7),
      Offset(center.dx + eyeRadius * 1.5, center.dy + eyeRadius * 1.5),
      handlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
