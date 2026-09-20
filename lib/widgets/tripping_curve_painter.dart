import 'package:flutter/material.dart';
import '../models/short_circuit_model.dart';
import '../utils/app_theme.dart';

class TrippingCurvePainter extends CustomPainter {
  final TrippingCurve curve;
  final double ratedIn;
  final double iscMin;
  final bool isArabic;

  TrippingCurvePainter({
    required this.curve,
    required this.ratedIn,
    required this.iscMin,
    required this.isArabic,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // الخلفية وشبكة الإحداثيات
    final axisPaint = Paint()
      ..color = const Color(0xFF334155)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final double leftPadding = 45.0;
    final double bottomPadding = 30.0;
    final double rightPadding = 15.0;
    final double topPadding = 15.0;

    final double plotW = w - leftPadding - rightPadding;
    final double plotH = h - topPadding - bottomPadding;

    // رسم المحاور
    canvas.drawLine(
      Offset(leftPadding, topPadding),
      Offset(leftPadding, h - bottomPadding),
      axisPaint,
    );
    canvas.drawLine(
      Offset(leftPadding, h - bottomPadding),
      Offset(w - rightPadding, h - bottomPadding),
      axisPaint,
    );

    // نصوص المحاور
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    void drawText(String text, Offset offset, Color color, double fontSize, {bool isCenter = false}) {
      textPainter.text = TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.w600),
      );
      textPainter.layout();
      final pos = isCenter ? Offset(offset.dx - textPainter.width / 2, offset.dy) : offset;
      textPainter.paint(canvas, pos);
    }

    // تدريج المحور الرأسي (الزمن)
    drawText('1000s', Offset(5, topPadding), const Color(0xFF64748B), 9);
    drawText('1s', Offset(15, topPadding + plotH * 0.5), const Color(0xFF64748B), 9);
    drawText('0.01s', Offset(5, h - bottomPadding - 12), const Color(0xFF64748B), 9);

    // تدريج المحور الأفقي (التيار بمضاعفات In)
    final double xIn = leftPadding + plotW * 0.05;
    final double x3In = leftPadding + plotW * 0.25;
    final double x5In = leftPadding + plotW * 0.45;
    final double x10In = leftPadding + plotW * 0.70;
    final double x20In = leftPadding + plotW * 0.95;

    drawText('In', Offset(xIn, h - bottomPadding + 6), const Color(0xFF64748B), 9, isCenter: true);
    drawText('3In', Offset(x3In, h - bottomPadding + 6), const Color(0xFF64748B), 9, isCenter: true);
    drawText('5In', Offset(x5In, h - bottomPadding + 6), const Color(0xFF64748B), 9, isCenter: true);
    drawText('10In', Offset(x10In, h - bottomPadding + 6), const Color(0xFF64748B), 9, isCenter: true);
    drawText('20In', Offset(x20In, h - bottomPadding + 6), const Color(0xFF64748B), 9, isCenter: true);

    // 1. منطقة الفصل الحراري (Thermal Overload Zone)
    final thermalPath = Path();
    thermalPath.moveTo(leftPadding + plotW * 0.08, topPadding);
    thermalPath.quadraticBezierTo(
      leftPadding + plotW * 0.20,
      topPadding + plotH * 0.45,
      leftPadding + plotW * 0.45,
      topPadding + plotH * 0.60,
    );
    thermalPath.lineTo(leftPadding + plotW * 0.55, topPadding + plotH * 0.60);
    thermalPath.quadraticBezierTo(
      leftPadding + plotW * 0.30,
      topPadding + plotH * 0.45,
      leftPadding + plotW * 0.16,
      topPadding,
    );
    thermalPath.close();

    final thermalPaint = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    final thermalStroke = Paint()
      ..color = const Color(0xFFF59E0B)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawPath(thermalPath, thermalPaint);
    canvas.drawPath(thermalPath, thermalStroke);

    drawText(
      isArabic ? 'فصل حراري' : 'Thermal',
      Offset(leftPadding + plotW * 0.22, topPadding + plotH * 0.25),
      const Color(0xFFFBBF24),
      10,
    );

    // 2. منطقة الفصل المغناطيسي اللحظي حسب المنحنى
    double magStart = x5In;
    double magEnd = x10In;

    switch (curve) {
      case TrippingCurve.b:
        magStart = x3In;
        magEnd = x5In;
        break;
      case TrippingCurve.c:
        magStart = x5In;
        magEnd = x10In;
        break;
      case TrippingCurve.d:
        magStart = x10In;
        magEnd = x20In;
        break;
      case TrippingCurve.k:
        magStart = leftPadding + plotW * 0.60;
        magEnd = leftPadding + plotW * 0.80;
        break;
      case TrippingCurve.z:
        magStart = leftPadding + plotW * 0.15;
        magEnd = x3In;
        break;
    }

    final magRect = Rect.fromLTRB(
      magStart,
      topPadding + plotH * 0.60,
      magEnd,
      h - bottomPadding,
    );

    final magPaint = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    final magStroke = Paint()
      ..color = const Color(0xFF10B981)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawRect(magRect, magPaint);
    canvas.drawRect(magRect, magStroke);

    drawText(
      'Curve ${curve.code}',
      Offset((magStart + magEnd) / 2, topPadding + plotH * 0.75),
      const Color(0xFF34D399),
      9,
      isCenter: true,
    );

    // 3. نقطة تيار القصر الأدنى الفعلي (Operating Point)
    final double ratio = ratedIn > 0 ? (iscMin / ratedIn) : 0;
    double dotX = x10In;
    if (ratio <= 1.5) {
      dotX = xIn;
    } else if (ratio <= 3.0) {
      dotX = x3In;
    } else if (ratio <= 5.0) {
      dotX = x5In;
    } else if (ratio <= 10.0) {
      dotX = x10In;
    } else if (ratio <= 20.0) {
      dotX = x20In;
    } else {
      dotX = w - rightPadding - 5;
    }

    final double dotY = h - bottomPadding - 6;

    // خط عمودي متقطع للنقطة
    final pointLinePaint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(dotX, topPadding + 10),
      Offset(dotX, h - bottomPadding),
      pointLinePaint,
    );

    // النقطة
    final dotPaint = Paint()..color = Colors.red;
    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(Offset(dotX, dotY), 4.5, dotPaint);
    canvas.drawCircle(Offset(dotX, dotY), 4.5, dotBorderPaint);

    drawText(
      'Isc: ${iscMin.round()}A',
      Offset(dotX.clamp(leftPadding, w - rightPadding - 60), topPadding + 15),
      Colors.redAccent,
      9,
    );
  }

  @override
  bool shouldRepaint(covariant TrippingCurvePainter oldDelegate) {
    return oldDelegate.curve != curve ||
        oldDelegate.ratedIn != ratedIn ||
        oldDelegate.iscMin != iscMin ||
        oldDelegate.isArabic != isArabic;
  }
}
