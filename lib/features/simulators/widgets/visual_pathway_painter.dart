import 'dart:math';
import 'package:flutter/material.dart';

class VisualPathwayState {
  final String lesionLocation;
  final Offset? perimetryTestPoint;
  final bool isLeftEyeTested;
  final bool showNumericDecibels;

  VisualPathwayState({
    required this.lesionLocation,
    this.perimetryTestPoint,
    this.isLeftEyeTested = true,
    this.showNumericDecibels = false,
  });
}

class VisualPathwayPainter extends CustomPainter {
  final VisualPathwayState state;

  VisualPathwayPainter({required this.state});

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    // Background
    final Paint bgPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), bgPaint);

    final double eyeRadius = 45.0;
    final Offset leftEyeCenter = Offset(width * 0.25, height * 0.18);
    final Offset rightEyeCenter = Offset(width * 0.75, height * 0.18);

    // 1. Draw Visual Fields (Humphrey 30-2 Perimetry Grayscale)
    _drawVisualField(canvas, leftEyeCenter, eyeRadius, true, state.lesionLocation);
    _drawVisualField(canvas, rightEyeCenter, eyeRadius, false, state.lesionLocation);

    // Perimetry Labels
    _drawText(canvas, 'Left Eye Field (OS)', leftEyeCenter - Offset(0, eyeRadius + 14), Colors.white);
    _drawText(canvas, 'Right Eye Field (OD)', rightEyeCenter - Offset(0, eyeRadius + 14), Colors.white);

    // Stimulus Test Point Flash if active
    if (state.perimetryTestPoint != null) {
      _drawStimulusFlash(canvas, state.perimetryTestPoint!, state.isLeftEyeTested);
    }

    // 2. Draw Anatomical Visual Pathways & Brain
    _drawPathwayAnatomy(canvas, width, height);
  }

  void _drawVisualField(Canvas canvas, Offset center, double radius, bool isLeftEye, String lesion) {
    final Paint seeingPaint = Paint()..color = const Color(0xFFF8FAFC); // 30 dB white sensitivity
    final Paint scotomaPaint = Paint()..color = const Color(0xFF020617); // 0 dB absolute defect
    final Paint gridBorder = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Base circle
    canvas.drawCircle(center, radius, seeingPaint);

    // Blind Spot (Optic Disc: ~15° Temporal, 1.5° Below Midline)
    final Offset blindSpotOffset = isLeftEye
        ? center + Offset(-radius * 0.50, radius * 0.08)
        : center + Offset(radius * 0.50, radius * 0.08);
    final Paint blindSpotPaint = Paint()..color = const Color(0xFF334155);
    canvas.drawCircle(blindSpotOffset, radius * 0.14, blindSpotPaint);

    // Darken field defects based on lesion site
    switch (lesion) {
      case 'normal':
        break;
      case 'left_optic_nerve':
        if (isLeftEye) canvas.drawCircle(center, radius, scotomaPaint);
        break;
      case 'right_optic_nerve':
        if (!isLeftEye) canvas.drawCircle(center, radius, scotomaPaint);
        break;
      case 'optic_chiasm':
        _fillHalf(canvas, center, radius, scotomaPaint, isLeft: isLeftEye);
        break;
      case 'junctional_scotoma':
        if (isLeftEye) {
          canvas.drawCircle(center, radius, scotomaPaint);
        } else {
          _fillQuadrant(canvas, center, radius, scotomaPaint, isLeft: false, isTop: true);
        }
        break;
      case 'left_optic_tract':
      case 'left_lgn':
        _fillHalf(canvas, center, radius, scotomaPaint, isLeft: false);
        break;
      case 'right_optic_tract':
      case 'right_lgn':
        _fillHalf(canvas, center, radius, scotomaPaint, isLeft: true);
        break;
      case 'left_meyers_loop':
        _fillQuadrant(canvas, center, radius, scotomaPaint, isLeft: false, isTop: true);
        break;
      case 'right_meyers_loop':
        _fillQuadrant(canvas, center, radius, scotomaPaint, isLeft: true, isTop: true);
        break;
      case 'left_baums_loop':
        _fillQuadrant(canvas, center, radius, scotomaPaint, isLeft: false, isTop: false);
        break;
      case 'right_baums_loop':
        _fillQuadrant(canvas, center, radius, scotomaPaint, isLeft: true, isTop: false);
        break;
      case 'left_occipital_sparing':
        _fillHalf(canvas, center, radius, scotomaPaint, isLeft: false);
        canvas.drawCircle(center, radius * 0.25, seeingPaint);
        break;
      case 'right_occipital_sparing':
        _fillHalf(canvas, center, radius, scotomaPaint, isLeft: true);
        canvas.drawCircle(center, radius * 0.25, seeingPaint);
        break;
      case 'occipital_pole':
        canvas.drawCircle(center, radius * 0.28, scotomaPaint);
        break;
    }

    // Humphrey 30-2 Grid Rings (10°, 20°, 30° Isopters)
    canvas.drawCircle(center, radius * 0.33, gridBorder);
    canvas.drawCircle(center, radius * 0.66, gridBorder);
    canvas.drawCircle(center, radius, gridBorder);

    // Crosshairs
    canvas.drawLine(center - Offset(radius, 0), center + Offset(radius, 0), gridBorder);
    canvas.drawLine(center - Offset(0, radius), center + Offset(0, radius), gridBorder);

    if (state.showNumericDecibels) {
      _drawNumericDecibelsGrid(canvas, center, radius, isLeftEye, lesion);
    }
  }

  void _drawNumericDecibelsGrid(Canvas canvas, Offset center, double radius, bool isLeftEye, String lesion) {
    const int gridCount = 5;
    final double step = (radius * 1.6) / gridCount;

    for (int i = 0; i < gridCount; i++) {
      for (int j = 0; j < gridCount; j++) {
        final double dx = (i - 2) * step;
        final double dy = (j - 2) * step;
        final Offset pt = center + Offset(dx, dy);

        if ((pt - center).distance < radius - 4) {
          bool isDefect = false;
          if (lesion == 'left_optic_nerve' && isLeftEye) isDefect = true;
          if (lesion == 'right_optic_nerve' && !isLeftEye) isDefect = true;
          if (lesion == 'optic_chiasm') {
            if (isLeftEye && dx < 0) isDefect = true;
            if (!isLeftEye && dx > 0) isDefect = true;
          }
          if (lesion.contains('optic_tract') || lesion.contains('meyers') || lesion.contains('baums') || lesion.contains('occipital')) {
            if (lesion.startsWith('left_') && dx > 0) isDefect = true;
            if (lesion.startsWith('right_') && dx < 0) isDefect = true;
          }

          final String val = isDefect ? '00' : '${28 + ((i + j) % 3)}';
          final Color col = isDefect ? Colors.redAccent : Colors.black87;

          final textPainter = TextPainter(
            text: TextSpan(text: val, style: TextStyle(color: col, fontSize: 9, fontWeight: FontWeight.bold)),
            textDirection: TextDirection.ltr,
          )..layout();
          textPainter.paint(canvas, pt - Offset(textPainter.width / 2, textPainter.height / 2));
        }
      }
    }
  }

  void _fillHalf(Canvas canvas, Offset center, double radius, Paint paint, {required bool isLeft}) {
    final Rect rect = Rect.fromCircle(center: center, radius: radius);
    final double startAngle = isLeft ? pi / 2 : -pi / 2;
    canvas.drawArc(rect, startAngle, pi, true, paint);
  }

  void _fillQuadrant(Canvas canvas, Offset center, double radius, Paint paint, {required bool isLeft, required bool isTop}) {
    final Rect rect = Rect.fromCircle(center: center, radius: radius);
    double startAngle = 0;
    if (isLeft && isTop) {
      startAngle = pi;
    } else if (isLeft && !isTop) {
      startAngle = pi / 2;
    } else if (!isLeft && isTop) {
      startAngle = -pi / 2;
    } else if (!isLeft && !isTop) {
      startAngle = 0;
    }
    canvas.drawArc(rect, startAngle, pi / 2, true, paint);
  }

  void _drawStimulusFlash(Canvas canvas, Offset testPt, bool isLeftEye) {
    final Paint flashPaint = Paint()
      ..color = Colors.amberAccent
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(testPt, 8, flashPaint);

    final Paint corePaint = Paint()..color = Colors.white;
    canvas.drawCircle(testPt, 4, corePaint);
  }

  void _drawPathwayAnatomy(Canvas canvas, double width, double height) {
    final Offset chiasm = Offset(width * 0.5, height * 0.52);
    final Offset leftLgn = Offset(width * 0.32, height * 0.68);
    final Offset rightLgn = Offset(width * 0.68, height * 0.68);
    final Offset leftV1 = Offset(width * 0.32, height * 0.88);
    final Offset rightV1 = Offset(width * 0.68, height * 0.88);

    final Offset leftGlobe = Offset(width * 0.30, height * 0.35);
    final Offset rightGlobe = Offset(width * 0.70, height * 0.35);

    // Anatomical Globes
    final Paint globePaint = Paint()..color = const Color(0xFF1E293B);
    final Paint globeRim = Paint()
      ..color = const Color(0xFF38BDF8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(leftGlobe, 18, globePaint);
    canvas.drawCircle(leftGlobe, 18, globeRim);
    canvas.drawCircle(rightGlobe, 18, globePaint);
    canvas.drawCircle(rightGlobe, 18, globeRim);

    _drawText(canvas, 'OS Retina', leftGlobe, Colors.cyanAccent);
    _drawText(canvas, 'OD Retina', rightGlobe, Colors.cyanAccent);

    // Fiber Pathways
    final Paint temporalFiberPaint = Paint()
      ..color = const Color(0xFF0284C7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    final Paint nasalFiberPaint = Paint()
      ..color = const Color(0xFFE11D48)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    // Optic Nerves
    canvas.drawLine(leftGlobe, chiasm - const Offset(10, 0), temporalFiberPaint);
    canvas.drawLine(rightGlobe, chiasm + const Offset(10, 0), nasalFiberPaint);

    // Chiasm Decussation
    canvas.drawLine(chiasm - const Offset(10, 0), chiasm + const Offset(10, 0), nasalFiberPaint);

    // Optic Tracts
    canvas.drawLine(chiasm - const Offset(10, 0), leftLgn, temporalFiberPaint);
    canvas.drawLine(chiasm + const Offset(10, 0), rightLgn, nasalFiberPaint);

    // LGN Nodes
    final Paint lgnPaint = Paint()..color = const Color(0xFFF59E0B);
    canvas.drawCircle(leftLgn, 8, lgnPaint);
    canvas.drawCircle(rightLgn, 8, lgnPaint);

    // Optic Radiations
    final Path meyerLeft = Path()
      ..moveTo(leftLgn.dx, leftLgn.dy)
      ..cubicTo(leftLgn.dx - 30, leftLgn.dy + 30, leftV1.dx - 30, leftV1.dy - 30, leftV1.dx, leftV1.dy);
    final Path meyerRight = Path()
      ..moveTo(rightLgn.dx, rightLgn.dy)
      ..cubicTo(rightLgn.dx + 30, rightLgn.dy + 30, rightV1.dx + 30, rightV1.dy - 30, rightV1.dx, rightV1.dy);

    canvas.drawPath(meyerLeft, temporalFiberPaint);
    canvas.drawPath(meyerRight, nasalFiberPaint);

    // Occipital Cortex V1 Polarity
    final Paint v1Paint = Paint()..color = const Color(0xFF10B981);
    canvas.drawRect(Rect.fromCenter(center: leftV1, width: 34, height: 12), v1Paint);
    canvas.drawRect(Rect.fromCenter(center: rightV1, width: 34, height: 12), v1Paint);

    _drawText(canvas, 'LGN', leftLgn - const Offset(24, 0), const Color(0xFFF59E0B));
    _drawText(canvas, 'LGN', rightLgn + const Offset(24, 0), const Color(0xFFF59E0B));
    _drawText(canvas, 'Left V1 (PCA+MCA)', leftV1 + const Offset(0, 16), const Color(0xFF10B981));
    _drawText(canvas, 'Right V1 (PCA+MCA)', rightV1 + const Offset(0, 16), const Color(0xFF10B981));

    // Active Lesion Indicator Marker
    Offset? lesionPos;
    switch (state.lesionLocation) {
      case 'left_optic_nerve':
        lesionPos = (leftGlobe + chiasm) * 0.5;
        break;
      case 'right_optic_nerve':
        lesionPos = (rightGlobe + chiasm) * 0.5;
        break;
      case 'optic_chiasm':
      case 'junctional_scotoma':
        lesionPos = chiasm;
        break;
      case 'left_optic_tract':
        lesionPos = (chiasm + leftLgn) * 0.5;
        break;
      case 'right_optic_tract':
        lesionPos = (chiasm + rightLgn) * 0.5;
        break;
      case 'left_meyers_loop':
      case 'left_baums_loop':
        lesionPos = (leftLgn + leftV1) * 0.5;
        break;
      case 'right_meyers_loop':
      case 'right_baums_loop':
        lesionPos = (rightLgn + rightV1) * 0.5;
        break;
      case 'left_occipital_sparing':
        lesionPos = leftV1;
        break;
      case 'right_occipital_sparing':
        lesionPos = rightV1;
        break;
      case 'occipital_pole':
        lesionPos = (leftV1 + rightV1) * 0.5;
        break;
    }

    if (lesionPos != null) {
      final Paint markerGlow = Paint()
        ..color = Colors.redAccent.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      final Paint markerBg = Paint()..color = Colors.redAccent;
      final Paint markerX = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      canvas.drawCircle(lesionPos, 16, markerGlow);
      canvas.drawCircle(lesionPos, 13, markerBg);
      canvas.drawLine(lesionPos - const Offset(6, 6), lesionPos + const Offset(6, 6), markerX);
      canvas.drawLine(lesionPos - const Offset(6, -6), lesionPos + const Offset(6, -6), markerX);
    }
  }

  void _drawText(Canvas canvas, String text, Offset position, Color color) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, position - Offset(textPainter.width / 2, textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant VisualPathwayPainter oldDelegate) => true;
}

