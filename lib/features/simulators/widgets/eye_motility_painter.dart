import 'dart:math';
import 'package:flutter/material.dart';

class EyeMotilityState {
  final double gazeX;
  final double gazeY;
  final String pathologyKey;
  final double lightIntensityRight;
  final double lightIntensityLeft;
  final Offset? torchPosition;
  final bool isTorchActive;
  final String coverState;
  final String strabismusType;
  final double nystagmusPhase;
  final int prismPower;
  final String prismBase;
  final String prismEye;
  final bool isNearTargetActive;
  final double headTiltAngle; // -15.0 (left tilt), 0.0 (upright), +15.0 (right tilt)
  final double fatigueLevel; // 0.0 (fresh) to 1.0 (exhausted for MG ptosis)
  final double blinkPhase; // 0.0 (open) to 1.0 (closed)

  EyeMotilityState({
    required this.gazeX,
    required this.gazeY,
    required this.pathologyKey,
    required this.lightIntensityRight,
    required this.lightIntensityLeft,
    this.torchPosition,
    this.isTorchActive = true,
    required this.coverState,
    required this.strabismusType,
    this.nystagmusPhase = 0.0,
    this.prismPower = 0,
    this.prismBase = 'none',
    this.prismEye = 'none',
    this.isNearTargetActive = false,
    this.headTiltAngle = 0.0,
    this.fatigueLevel = 0.0,
    this.blinkPhase = 0.0,
  });
}

class EyeMotilityPainter extends CustomPainter {
  final EyeMotilityState state;

  EyeMotilityPainter({required this.state});

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    final double halfWidth = width / 2;

    // 1. Draw Background
    final Paint bgPaint = Paint()..color = const Color(0xFF0F172A); // Deep slate background
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), bgPaint);

    // Eye centers: Patient Right Eye (OD) is on viewer left; Patient Left Eye (OS) is on viewer right
    final double rightEyeCenterX = halfWidth - 85;
    final double leftEyeCenterX = halfWidth + 85;
    final double eyeCenterY = height / 2 - 10;
    final double eyeRadius = 46.0;

    final Offset rightEyePos = Offset(rightEyeCenterX, eyeCenterY);
    final Offset leftEyePos = Offset(leftEyeCenterX, eyeCenterY);

    // Calculate effective direct/consensual light intensities
    double effectiveLightRight = state.lightIntensityRight;
    double effectiveLightLeft = state.lightIntensityLeft;

    if (state.torchPosition != null && state.isTorchActive) {
      final double distRight = (state.torchPosition! - rightEyePos).distance;
      final double distLeft = (state.torchPosition! - leftEyePos).distance;

      if (distRight < 90) {
        effectiveLightRight = max(effectiveLightRight, (1.0 - (distRight / 90)).clamp(0.0, 1.0));
      }
      if (distLeft < 90) {
        effectiveLightLeft = max(effectiveLightLeft, (1.0 - (distLeft / 90)).clamp(0.0, 1.0));
      }
    }

    // Draw Globes
    _drawEye(canvas, rightEyePos, eyeRadius, isRightEye: true, lightIntensity: effectiveLightRight, fellowLight: effectiveLightLeft);
    _drawEye(canvas, leftEyePos, eyeRadius, isRightEye: false, lightIntensity: effectiveLightLeft, fellowLight: effectiveLightRight);

    // Draw Labels
    _drawLabel(canvas, Offset(rightEyeCenterX, eyeCenterY + eyeRadius + 14), 'OD (Right Eye)');
    _drawLabel(canvas, Offset(leftEyeCenterX, eyeCenterY + eyeRadius + 14), 'OS (Left Eye)');

    // Draw Cover paddle
    if (state.coverState == 'cover_right') {
      _drawCoverPaddle(canvas, rightEyePos, eyeRadius);
    } else if (state.coverState == 'cover_left') {
      _drawCoverPaddle(canvas, leftEyePos, eyeRadius);
    }

    // Draw Penlight / Torchlight
    if (state.torchPosition != null && state.isTorchActive && state.prismPower == 0) {
      _drawPenlight(canvas, state.torchPosition!);
    }

    // Draw Prism Bar if active
    if (state.prismPower > 0 && state.prismEye != 'none') {
      _drawPrismBar(canvas, state.prismEye == 'right' ? rightEyePos : leftEyePos, eyeRadius);
    }
  }

  void _drawLabel(Canvas canvas, Offset position, String text) {
    final textSpan = TextSpan(
      text: text,
      style: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
    textPainter.paint(canvas, position - Offset(textPainter.width / 2, 0));
  }

  void _drawEye(Canvas canvas, Offset center, double radius, {
    required bool isRightEye,
    required double lightIntensity,
    required double fellowLight,
  }) {
    // 1. Sclera with subtle episcleral vascularity
    final Paint scleraPaint = Paint()..color = const Color(0xFFF8FAFC);
    final Paint borderPaint = Paint()
      ..color = const Color(0xFF475569)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, radius, scleraPaint);

    // Fine episcleral blood vessels
    final Paint vesselPaint = Paint()
      ..color = const Color(0xFFEF4444).withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    for (int i = 0; i < 6; i++) {
      final double angle = (i * pi / 3) + (isRightEye ? 0.2 : 0.5);
      final Offset start = center + Offset(cos(angle) * (radius * 0.55), sin(angle) * (radius * 0.55));
      final Offset end = center + Offset(cos(angle) * (radius * 0.95), sin(angle) * (radius * 0.95));
      canvas.drawLine(start, end, vesselPaint);
    }

    canvas.drawCircle(center, radius, borderPaint);

    // 2. Dynamic Gaze & Iris Calculation
    final Offset gazeOffset = _calculateGazeOffset(isRightEye);
    final double maxMovement = radius - 19.0;
    final Offset irisCenter = center + Offset(gazeOffset.dx * maxMovement, -gazeOffset.dy * maxMovement);

    // Iris Base Shading
    final Paint irisPaint = Paint()
      ..color = isRightEye ? const Color(0xFF0284C7) : const Color(0xFF0D9488);
    canvas.drawCircle(irisCenter, 19.0, irisPaint);

    // Iris Radial Fibril Lines (Realistic Texture)
    final Paint fibrilPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 1.0;
    for (int i = 0; i < 16; i++) {
      final double angle = i * pi / 8;
      final Offset fStart = irisCenter + Offset(cos(angle) * 7.0, sin(angle) * 7.0);
      final Offset fEnd = irisCenter + Offset(cos(angle) * 18.5, sin(angle) * 18.5);
      canvas.drawLine(fStart, fEnd, fibrilPaint);
    }

    // Iris Limbal Ring
    final Paint limbusPaint = Paint()
      ..color = const Color(0xFF0F172A).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawCircle(irisCenter, 19.0, limbusPaint);

    // Iris Collarette Ring
    final Paint collarettePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(irisCenter, 13.0, collarettePaint);

    // 3. Pupil Sphincter & Miosis
    double pupilRadius = _calculatePupilRadius(isRightEye, lightIntensity, fellowLight);
    final Paint pupilPaint = Paint()..color = const Color(0xFF020617);
    canvas.drawCircle(irisCenter, pupilRadius, pupilPaint);

    // 4. Corneal Specular Highlight (Hirschberg Reflex)
    Offset reflectionOffset = const Offset(-4.0, -4.0);
    if (state.torchPosition != null && state.isTorchActive && state.prismPower == 0) {
      final Offset diff = (state.torchPosition! - center);
      reflectionOffset = Offset(
        (diff.dx * 0.075).clamp(-11.0, 11.0),
        (diff.dy * 0.075).clamp(-11.0, 11.0),
      );
    }
    final Paint reflectionPaint = Paint()..color = Colors.white.withValues(alpha: 0.95);
    canvas.drawCircle(irisCenter + reflectionOffset, 3.0, reflectionPaint);

    // Light Beam Glow
    if (lightIntensity > 0 && state.prismPower == 0) {
      final Paint lightBeamPaint = Paint()
        ..color = const Color(0xFFFBBF24).withValues(alpha: (lightIntensity * 0.40).clamp(0.0, 0.55))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
      canvas.drawCircle(center, radius + 10, lightBeamPaint);
    }

    // Ptosis or Eyelid Retraction
    _drawEyelids(canvas, center, radius, isRightEye);
  }

  void _drawEyelids(Canvas canvas, Offset center, double radius, bool isRightEye) {
    double ptosisDrop = 0.0;
    bool hasCollierRetraction = false;

    if (state.pathologyKey == 'parinaud') {
      hasCollierRetraction = true;
    }

    if (isRightEye) {
      if (state.pathologyKey == 'horner_right') {
        ptosisDrop = radius * 0.38; // Mild Müller ptosis
      } else if (state.pathologyKey == 'cn3_right' || state.pathologyKey == 'cn3_pupil_sparing' || state.pathologyKey == 'cn3_superior_division_right') {
        ptosisDrop = radius * 0.76; // Severe complete levator ptosis
      } else if (state.pathologyKey == 'myasthenia_gravis') {
        ptosisDrop = radius * (0.30 + state.fatigueLevel * 0.50);
      }
    } else {
      if (state.pathologyKey == 'horner_left') {
        ptosisDrop = radius * 0.38;
      } else if (state.pathologyKey == 'cn3_left' || state.pathologyKey == 'cn3_pupil_sparing_left') {
        ptosisDrop = radius * 0.76;
      } else if (state.pathologyKey == 'myasthenia_gravis') {
        ptosisDrop = radius * (0.25 + state.fatigueLevel * 0.55);
      }
    }

    double activeTopDrop = ptosisDrop;
    if (state.blinkPhase > 0) {
      activeTopDrop = max(ptosisDrop, (radius * 1.8) * state.blinkPhase);
    }

    if (activeTopDrop > 0) {
      final Path eyelidPath = Path()
        ..moveTo(center.dx - radius - 2, center.dy - radius)
        ..lineTo(center.dx + radius + 2, center.dy - radius)
        ..lineTo(center.dx + radius + 2, center.dy - radius + activeTopDrop)
        ..quadraticBezierTo(
          center.dx,
          center.dy - radius + activeTopDrop + 8,
          center.dx - radius - 2,
          center.dy - radius + activeTopDrop,
        )
        ..close();

      final Paint lidPaint = Paint()..color = const Color(0xFFD97706).withValues(alpha: 0.90);
      canvas.drawPath(eyelidPath, lidPaint);
    }

    if (state.blinkPhase > 0) {
      final double bottomRise = (radius * 1.2) * state.blinkPhase;
      final Path bottomLidPath = Path()
        ..moveTo(center.dx - radius - 2, center.dy + radius)
        ..lineTo(center.dx + radius + 2, center.dy + radius)
        ..lineTo(center.dx + radius + 2, center.dy + radius - bottomRise)
        ..quadraticBezierTo(
          center.dx,
          center.dy + radius - bottomRise - 6,
          center.dx - radius - 2,
          center.dy + radius - bottomRise,
        )
        ..close();
      final Paint lidPaint = Paint()..color = const Color(0xFFD97706).withValues(alpha: 0.90);
      canvas.drawPath(bottomLidPath, lidPaint);
    }

    if (hasCollierRetraction) {
      // Collier's sign: path showing sclera above limbus
      final Paint retractionRing = Paint()
        ..color = Colors.amberAccent.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(center, radius + 4, retractionRing);
    }
  }

  Offset _calculateGazeOffset(bool isRightEye) {
    double rightGx = state.gazeX;
    double rightGy = state.gazeY;
    double leftGx = state.gazeX;
    double leftGy = state.gazeY;

    // Accommodative convergence near target
    if (state.isNearTargetActive) {
      rightGx = -0.40; // converge inward
      leftGx = 0.40;
      rightGy = 0.15;
      leftGy = 0.15;
    }

    // Prism shift
    if (state.prismEye == 'right') {
      if (state.prismBase == 'BO') rightGx += state.prismPower / 80.0;
      if (state.prismBase == 'BI') rightGx -= state.prismPower / 80.0;
      if (state.prismBase == 'BU') rightGy -= state.prismPower / 80.0;
      if (state.prismBase == 'BD') rightGy += state.prismPower / 80.0;
    } else if (state.prismEye == 'left') {
      if (state.prismBase == 'BO') leftGx -= state.prismPower / 80.0;
      if (state.prismBase == 'BI') leftGx += state.prismPower / 80.0;
      if (state.prismBase == 'BU') leftGy -= state.prismPower / 80.0;
      if (state.prismBase == 'BD') leftGy += state.prismPower / 80.0;
    }

    // Strabismus deviations under cover
    double devRightX = 0.0;
    double devRightY = 0.0;
    double devLeftX = 0.0;
    double devLeftY = 0.0;

    switch (state.strabismusType) {
      case 'exophoria':
      case 'exotropia':
        devRightX = -0.45;
        devLeftX = 0.45;
        break;
      case 'esophoria':
      case 'esotropia':
        devRightX = 0.45;
        devLeftX = -0.45;
        break;
      case 'hypertropia_right':
        devRightY = 0.45;
        devLeftY = -0.45;
        break;
      case 'hypertropia_left':
        devRightY = -0.45;
        devLeftY = 0.45;
        break;
    }

    // Apply Cover-Uncover Hering mechanics
    double gx = isRightEye ? rightGx : leftGx;
    double gy = isRightEye ? rightGy : leftGy;

    if (state.coverState == 'cover_right') {
      if (isRightEye) {
        gx = leftGx + devRightX;
        gy = leftGy + devRightY;
      } else {
        gx = leftGx;
        gy = leftGy;
      }
    } else if (state.coverState == 'cover_left') {
      if (!isRightEye) {
        gx = rightGx + devLeftX;
        gy = rightGy + devLeftY;
      } else {
        gx = rightGx;
        gy = rightGy;
      }
    } else if (state.strabismusType.contains('tropia')) {
      // Manifest tropia even without cover
      if (isRightEye) {
        gx += devRightX * 0.7;
        gy += devRightY * 0.7;
      }
    }

    // Nystagmus waves
    final double jerkWave = (sin(state.nystagmusPhase * 8 * pi) > 0.0 ? 0.08 : -0.04);
    final double verticalJerk = (sin(state.nystagmusPhase * 6 * pi) > 0.0 ? -0.10 : 0.03);

    // Pathology movement limits & palsies
    switch (state.pathologyKey) {
      // Cranial Nerve Palsies
      case 'cn6_right':
        if (isRightEye && gx < 0) gx = 0.0; // Cannot abduct right eye
        break;
      case 'cn6_left':
        if (!isRightEye && gx > 0) gx = 0.0; // Cannot abduct left eye
        break;
      case 'cn6_bilateral':
        if (isRightEye && gx < 0) gx = 0.0;
        if (!isRightEye && gx > 0) gx = 0.0;
        break;
      case 'cn3_right':
      case 'cn3_pupil_sparing':
        if (isRightEye) { gx = -0.65; gy = -0.45; } // Down-and-out
        break;
      case 'cn3_left':
      case 'cn3_pupil_sparing_left':
        if (!isRightEye) { gx = 0.65; gy = -0.45; }
        break;
      case 'cn3_superior_division_right':
        if (isRightEye && gy > 0) gy = 0.0; // Limited elevation
        break;
      case 'cn4_right':
        if (isRightEye) {
          // Bielschowsky 3-step: Right HT worsens on left gaze (adduction) & right head tilt (+15 deg)
          final double tiltBonus = state.headTiltAngle > 0 ? (state.headTiltAngle / 15.0) * 0.30 : (state.headTiltAngle < 0 ? -0.15 : 0.0);
          if (gx > 0 && gy < 0) gy = 0.0; // Limited depression in adduction
          gy += 0.25 + tiltBonus; // Hypertropia
        }
        break;
      case 'cn4_left':
        if (!isRightEye) {
          // Bielschowsky 3-step: Left HT worsens on right gaze & left head tilt (-15 deg)
          final double tiltBonus = state.headTiltAngle < 0 ? (-state.headTiltAngle / 15.0) * 0.30 : (state.headTiltAngle > 0 ? -0.15 : 0.0);
          if (gx < 0 && gy < 0) gy = 0.0;
          gy += 0.25 + tiltBonus;
        }
        break;
      case 'cn4_bilateral':
        if (isRightEye) gy += 0.20;
        if (!isRightEye) gy += 0.20;
        break;
      // Internuclear & Gaze Disorders
      case 'ino_right':
        if (isRightEye && gx > 0) gx = 0.0; // Right eye adduction failure
        if (!isRightEye && gx > 0.3) gx += jerkWave; // Left eye abducting nystagmus
        break;
      case 'ino_left':
        if (!isRightEye && gx < 0) gx = 0.0; // Left eye adduction failure
        if (isRightEye && gx < -0.3) gx -= jerkWave;
        break;
      case 'ino_bilateral':
        if (isRightEye && gx > 0) gx = 0.0;
        if (!isRightEye && gx < 0) gx = 0.0;
        if (gx.abs() > 0.3) gx += (gx > 0 ? jerkWave : -jerkWave);
        break;
      case 'webino':
        if (isRightEye) {
          if (gx > 0) gx = 0.0;
          gx -= 0.35; // Exotropia
        } else {
          if (gx < 0) gx = 0.0;
          gx += 0.35;
        }
        break;
      case 'one_and_a_half':
        if (gx < 0) {
          gx = 0.0; // Gaze palsy to right
        } else if (gx > 0 && isRightEye) {
          gx = 0.0; // Right eye adduction failure
        } else if (gx > 0 && !isRightEye) {
          gx += jerkWave; // Left eye abducting nystagmus
        }
        break;
      case 'one_and_a_half_left':
        if (gx > 0) {
          gx = 0.0; // Gaze palsy to left
        } else if (gx < 0 && !isRightEye) {
          gx = 0.0;
        } else if (gx < 0 && isRightEye) {
          gx -= jerkWave;
        }
        break;
      case 'parinaud':
        if (gy > 0) gy = 0.0; // Paralysis of upgaze
        if (state.isNearTargetActive) gx += (isRightEye ? -jerkWave : jerkWave);
        break;
      case 'skew_deviation':
        if (isRightEye) gy += 0.35;
        if (!isRightEye) gy -= 0.35;
        break;
      case 'psp':
        if (gy < 0) gy = 0.0; // Supranuclear downgaze palsy
        break;
      // Nystagmus
      case 'gaze_nystagmus':
        if (gx.abs() > 0.4) gx += (gx > 0 ? jerkWave : -jerkWave);
        break;
      case 'downbeat_nystagmus':
        gy += verticalJerk;
        break;
      case 'upbeat_nystagmus':
        gy -= verticalJerk;
        break;
      case 'infantile_nystagmus':
        gx += jerkWave * 1.5;
        break;
      case 'convergence_retraction':
        if (gy > 0) {
          gy = 0.0;
          gx += (isRightEye ? -jerkWave : jerkWave);
        }
        break;
      // Strabismus
      case 'duane_type1':
        if (isRightEye && gx < 0) gx = 0.0; // Abduction limitation
        break;
    }

    return Offset(gx.clamp(-1.0, 1.0), gy.clamp(-1.0, 1.0));
  }

  double _calculatePupilRadius(bool isRightEye, double intensityDirect, double intensityConsensual) {
    // 1. Complete CN III Palsy: 8mm blown fixed pupil
    if (isRightEye && state.pathologyKey == 'cn3_right') return 14.5;
    if (!isRightEye && state.pathologyKey == 'cn3_left') return 14.5;

    // 2. Pupil-Sparing CN III: Normal light reflex intact
    if (isRightEye && state.pathologyKey == 'cn3_pupil_sparing') {
      double constr = max(intensityDirect * 5.0, intensityConsensual * 4.2);
      if (state.isNearTargetActive) constr = max(constr, 4.0);
      return (9.0 - constr).clamp(3.5, 9.5);
    }
    if (!isRightEye && state.pathologyKey == 'cn3_pupil_sparing_left') {
      double constr = max(intensityDirect * 5.0, intensityConsensual * 4.2);
      if (state.isNearTargetActive) constr = max(constr, 4.0);
      return (9.0 - constr).clamp(3.5, 9.5);
    }

    // 3. Argyll Robertson: 2mm small, light-near dissociation
    if (state.pathologyKey == 'argyll_robertson') {
      return state.isNearTargetActive ? 3.0 : 4.0;
    }

    // 4. Parinaud: Mid-dilated with light-near dissociation
    if (state.pathologyKey == 'parinaud') {
      return state.isNearTargetActive ? 4.5 : 8.5;
    }

    // 5. Adie Tonic Pupil: Unilateral dilated pupil with sluggish response
    if (isRightEye && state.pathologyKey == 'adie_right') {
      double constr = max(intensityDirect * 1.5, intensityConsensual * 1.0);
      if (state.isNearTargetActive) constr = 3.5;
      return (13.0 - constr).clamp(9.5, 13.5);
    }
    if (!isRightEye && state.pathologyKey == 'adie_left') {
      double constr = max(intensityDirect * 1.5, intensityConsensual * 1.0);
      if (state.isNearTargetActive) constr = 3.5;
      return (13.0 - constr).clamp(9.5, 13.5);
    }

    // 6. Horner Syndrome: Unilateral mild miosis
    double hornerMiosis = 0.0;
    if (isRightEye && state.pathologyKey == 'horner_right') hornerMiosis = -2.2;
    if (!isRightEye && state.pathologyKey == 'horner_left') hornerMiosis = -2.2;

    // 7. Pharmacologic Mydriasis (Atropine)
    if (isRightEye && state.pathologyKey == 'pharmacologic_right') return 16.0;
    if (!isRightEye && state.pathologyKey == 'pharmacologic_left') return 16.0;

    // 8. RAPD (Relative Afferent Pupillary Defect)
    if (isRightEye && state.pathologyKey == 'rapd_right') {
      if (intensityDirect > 0.4 && intensityConsensual < 0.2) {
        return 12.0; // Dilates when light swings onto affected right eye
      } else if (intensityConsensual > 0.4) {
        return 5.5; // Constricts when light is on normal left eye
      }
    }
    if (!isRightEye && state.pathologyKey == 'rapd_left') {
      if (intensityDirect > 0.4 && intensityConsensual < 0.2) {
        return 12.0;
      } else if (intensityConsensual > 0.4) {
        return 5.5;
      }
    }

    // Normal direct/consensual reaction
    double constriction = max(intensityDirect * 5.0, intensityConsensual * 4.2);
    if (state.isNearTargetActive) constriction = max(constriction, 3.8);

    double baseRadius = 8.5 + hornerMiosis;
    return (baseRadius - constriction).clamp(3.0, 11.0);
  }

  void _drawCoverPaddle(Canvas canvas, Offset center, double radius) {
    final Paint paddlePaint = Paint()..color = Colors.black.withValues(alpha: 0.90);
    final Paint rimPaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Occluder disk
    canvas.drawCircle(center, radius + 8, paddlePaint);
    canvas.drawCircle(center, radius + 8, rimPaint);

    // Paddle handle
    final Paint handlePaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center + Offset(0, radius + 8), center + Offset(0, radius + 60), handlePaint);
  }

  void _drawPenlight(Canvas canvas, Offset pos) {
    // Torch beam glow
    final Paint beamPaint = Paint()
      ..color = const Color(0xFFFDE047).withValues(alpha: 0.40)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);
    canvas.drawCircle(pos, 35, beamPaint);

    // Torch head
    final Paint torchPaint = Paint()..color = const Color(0xFFFACC15);
    canvas.drawCircle(pos, 8, torchPaint);
    final Paint bulbPaint = Paint()..color = Colors.white;
    canvas.drawCircle(pos, 4, bulbPaint);
  }

  void _drawPrismBar(Canvas canvas, Offset eyeCenter, double eyeRadius) {
    final Rect prismRect = Rect.fromCenter(
      center: eyeCenter + const Offset(0, -5),
      width: eyeRadius * 1.8,
      height: eyeRadius * 2.2,
    );

    final Paint prismGlass = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    final Paint prismEdge = Paint()
      ..color = const Color(0xFF0284C7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRect(prismRect, prismGlass);
    canvas.drawRect(prismRect, prismEdge);

    // Prism base label
    final textSpan = TextSpan(
      text: '${state.prismPower}Δ ${state.prismBase}',
      style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 11, fontWeight: FontWeight.bold),
    );
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
    textPainter.paint(canvas, eyeCenter - Offset(textPainter.width / 2, eyeRadius + 18));
  }

  @override
  bool shouldRepaint(covariant EyeMotilityPainter oldDelegate) => true;
}
