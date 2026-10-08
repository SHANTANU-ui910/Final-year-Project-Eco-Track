import 'package:flutter/material.dart';

/// Bespoke duotone vector vehicle icon set matching the kinematic vehicle art style.
class VehicleIcon extends StatelessWidget {
  final String modeKey;
  final double size;
  final Color primaryColor;
  final Color secondaryColor;
  final bool isSelected;

  const VehicleIcon({
    super.key,
    required this.modeKey,
    this.size = 28.0,
    required this.primaryColor,
    required this.secondaryColor,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _VehicleIconPainter(
        modeKey: modeKey.toLowerCase(),
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
        isSelected: isSelected,
      ),
    );
  }
}

class _VehicleIconPainter extends CustomPainter {
  final String modeKey;
  final Color primaryColor;
  final Color secondaryColor;
  final bool isSelected;

  _VehicleIconPainter({
    required this.modeKey,
    required this.primaryColor,
    required this.secondaryColor,
    required this.isSelected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bodyPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final accentPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;

    final wheelPaint = Paint()
      ..color = isSelected ? primaryColor : const Color(0xFF64748B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    switch (modeKey) {
      case 'scooty':
        _paintScooty(canvas, w, h, bodyPaint, accentPaint, wheelPaint);
        break;
      case 'bike':
        _paintBike(canvas, w, h, bodyPaint, accentPaint, wheelPaint);
        break;
      case 'bus':
        _paintBus(canvas, w, h, bodyPaint, accentPaint, wheelPaint);
        break;
      case 'car':
      default:
        _paintCar(canvas, w, h, bodyPaint, accentPaint, wheelPaint);
        break;
    }
  }

  void _paintScooty(Canvas canvas, double w, double h, Paint body, Paint accent, Paint wheel) {
    // Wheels
    canvas.drawCircle(Offset(w * 0.22, h * 0.76), w * 0.14, wheel);
    canvas.drawCircle(Offset(w * 0.78, h * 0.76), w * 0.14, wheel);

    // Step-through chassis
    final path = Path()
      ..moveTo(w * 0.22, h * 0.65)
      ..lineTo(w * 0.44, h * 0.65) // low deck
      ..lineTo(w * 0.62, h * 0.36) // front steering stem
      ..lineTo(w * 0.75, h * 0.36) // handlebar
      ..lineTo(w * 0.75, h * 0.44)
      ..lineTo(w * 0.68, h * 0.65)
      ..lineTo(w * 0.78, h * 0.65)
      ..lineTo(w * 0.50, h * 0.72)
      ..close();
    canvas.drawPath(path, body);

    // Seat contour
    final seat = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.20, h * 0.45, w * 0.26, h * 0.12),
      const Radius.circular(3),
    );
    canvas.drawRRect(seat, accent);
  }

  void _paintBike(Canvas canvas, double w, double h, Paint body, Paint accent, Paint wheel) {
    // Wheels
    canvas.drawCircle(Offset(w * 0.20, h * 0.74), w * 0.15, wheel);
    canvas.drawCircle(Offset(w * 0.80, h * 0.74), w * 0.15, wheel);

    // Trellis Frame & Tank
    final frame = Path()
      ..moveTo(w * 0.20, h * 0.74)
      ..lineTo(w * 0.42, h * 0.52) // seat/subframe
      ..lineTo(w * 0.68, h * 0.38) // headstock
      ..lineTo(w * 0.80, h * 0.74) // front fork
      ..lineTo(w * 0.52, h * 0.70) // engine cradle
      ..close();
    canvas.drawPath(frame, body);

    // Sculpted Fuel Tank
    final tank = Path()
      ..moveTo(w * 0.42, h * 0.50)
      ..cubicTo(w * 0.48, h * 0.34, w * 0.62, h * 0.34, w * 0.68, h * 0.42)
      ..lineTo(w * 0.50, h * 0.54)
      ..close();
    canvas.drawPath(tank, accent);
  }

  void _paintCar(Canvas canvas, double w, double h, Paint body, Paint accent, Paint wheel) {
    // Wheels
    canvas.drawCircle(Offset(w * 0.25, h * 0.75), w * 0.13, wheel);
    canvas.drawCircle(Offset(w * 0.75, h * 0.75), w * 0.13, wheel);

    // Aerodynamic Body
    final bodyPath = Path()
      ..moveTo(w * 0.08, h * 0.68)
      ..lineTo(w * 0.12, h * 0.54)
      ..lineTo(w * 0.30, h * 0.50) // hood
      ..lineTo(w * 0.44, h * 0.32) // windshield
      ..lineTo(w * 0.68, h * 0.32) // roof
      ..lineTo(w * 0.86, h * 0.52) // rear glass
      ..lineTo(w * 0.94, h * 0.60) // boot
      ..lineTo(w * 0.94, h * 0.68)
      ..close();
    canvas.drawPath(bodyPath, body);

    // Cabin Glass
    final glass = Path()
      ..moveTo(w * 0.33, h * 0.50)
      ..lineTo(w * 0.45, h * 0.36)
      ..lineTo(w * 0.66, h * 0.36)
      ..lineTo(w * 0.80, h * 0.50)
      ..close();
    canvas.drawPath(glass, accent);
  }

  void _paintBus(Canvas canvas, double w, double h, Paint body, Paint accent, Paint wheel) {
    // Wheels
    canvas.drawCircle(Offset(w * 0.22, h * 0.78), w * 0.12, wheel);
    canvas.drawCircle(Offset(w * 0.78, h * 0.78), w * 0.12, wheel);

    // Rectangular Coach Body with rounded front
    final bodyRRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(w * 0.06, h * 0.24, w * 0.88, h * 0.50),
      topLeft: const Radius.circular(5),
      topRight: const Radius.circular(5),
      bottomLeft: const Radius.circular(2),
      bottomRight: const Radius.circular(2),
    );
    canvas.drawRRect(bodyRRect, body);

    // Panoramic window ribbon
    final glassRibbon = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.10, h * 0.30, w * 0.80, h * 0.18),
      const Radius.circular(2),
    );
    canvas.drawRRect(glassRibbon, accent);
  }

  @override
  bool shouldRepaint(covariant _VehicleIconPainter oldDelegate) =>
      oldDelegate.modeKey != modeKey ||
      oldDelegate.primaryColor != primaryColor ||
      oldDelegate.isSelected != isSelected;
}

