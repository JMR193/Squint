import 'dart:math';
import 'package:flutter/material.dart';

enum SynoptophoreSlide {
  lionAndCage('Grade 1: SMP (Lion & Cage)'),
  rabbit('Grade 2: Fusion (Rabbits with Ear/Tail)'),
  concentricRings('Grade 3: Stereopsis (Depth Circles)'),
  haidinger('Haidinger Brushes (Macular Polarization)'),
  afterImage('After-Image Test (Retinal Correspondence)');

  final String label;
  const SynoptophoreSlide(this.label);
}

class SynoptophoreSimulatorScreen extends StatefulWidget {
  const SynoptophoreSimulatorScreen({super.key});

  @override
  State<SynoptophoreSimulatorScreen> createState() => _SynoptophoreSimulatorScreenState();
}

class _SynoptophoreSimulatorScreenState extends State<SynoptophoreSimulatorScreen> with SingleTickerProviderStateMixin {
  SynoptophoreSlide _slide = SynoptophoreSlide.lionAndCage;

  // Patient Pathology presets
  final double _trueDeviation = 15.0; // Patient has +15Δ Esotropia
  bool _hasHarc = true; // Harmonious ARC

  // Optical tube arm controls
  double _tubeAngleHorizontal = 0.0; // -40Δ to +40Δ
  double _tubeAngleVertical = 0.0; // -15Δ to +15Δ
  double _torsionAngle = 0.0; // -15° to +15°
  double _angleKappa = 0.0; // -10Δ to +10Δ

  // Flashing lights
  bool _flashRight = true;
  bool _flashLeft = true;

  late AnimationController _haidingerAnim;

  @override
  void initState() {
    super.initState();
    _haidingerAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _haidingerAnim.dispose();
    super.dispose();
  }

  // Diagnostic calculations
  double get _objectiveAngle => _trueDeviation;
  double get _subjectiveAngle => _hasHarc ? 0.0 : _trueDeviation;
  double get _angleOfAnomaly => _objectiveAngle - _subjectiveAngle;

  String get _arcDiagnosis {
    if (_angleOfAnomaly.abs() < 1.0) {
      return 'Normal Retinal Correspondence (NRC): Fovea of one eye shares common visual direction with fovea of fellow eye.';
    } else if ((_angleOfAnomaly - _objectiveAngle).abs() < 2.0) {
      return 'Harmonious ARC (HARC): Angle of Anomaly equals Objective Angle (${_objectiveAngle.toInt()}Δ). Subjective angle is 0Δ (no diplopia, adaptation complete).';
    } else {
      return 'Unharmonious ARC (UARC): Angle of Anomaly (${_angleOfAnomaly.toInt()}Δ) is less than Objective Angle (${_objectiveAngle.toInt()}Δ). Incomplete cortical re-adaptation.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Virtual Synoptophore (Amblyoscope)'),
      ),
      body: Column(
        children: [
          // Clinical Scenario Settings Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<SynoptophoreSlide>(
                    initialValue: _slide,
                    decoration: const InputDecoration(
                      labelText: 'Synoptophore Test Slide',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    items: SynoptophoreSlide.values
                        .map((s) => DropdownMenuItem(value: s, child: Text(s.label, style: const TextStyle(fontSize: 13))))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _slide = v);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(_hasHarc ? 'HARC Active' : 'NRC Active'),
                  selected: true,
                  onSelected: (_) => setState(() => _hasHarc = !_hasHarc),
                ),
              ],
            ),
          ),
          // Eyepiece Optical Tubes (Left & Right Eyes)
          Expanded(
            child: Container(
              color: const Color(0xFF020617), // Dark tube barrels
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: _buildEyepieceBarrel(
                      label: 'LEFT EYE TUBE (OS)',
                      isIlluminated: _flashLeft,
                      isRight: false,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildEyepieceBarrel(
                      label: 'RIGHT EYE TUBE (OD)',
                      isIlluminated: _flashRight,
                      isRight: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Synoptophore Mechanical Control Panel
          Container(
            padding: const EdgeInsets.all(14),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Horizontal Arm: ${_tubeAngleHorizontal.toInt()}Δ (${_tubeAngleHorizontal >= 0 ? "Eso/Conv" : "Exo/Div"})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Slider(
                            value: _tubeAngleHorizontal,
                            min: -30,
                            max: 35,
                            divisions: 65,
                            label: '${_tubeAngleHorizontal.toInt()}Δ',
                            onChanged: (v) => setState(() => _tubeAngleHorizontal = v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Vertical Arm: ${_tubeAngleVertical.toInt()}Δ (${_tubeAngleVertical >= 0 ? "Hyper" : "Hypo"})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Slider(
                            value: _tubeAngleVertical,
                            min: -15,
                            max: 15,
                            divisions: 30,
                            label: '${_tubeAngleVertical.toInt()}Δ',
                            onChanged: (v) => setState(() => _tubeAngleVertical = v),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Torsion: ${_torsionAngle.toInt()}° (${_torsionAngle >= 0 ? "Excyclo" : "Incyclo"})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Slider(
                            value: _torsionAngle,
                            min: -15,
                            max: 15,
                            divisions: 30,
                            label: '${_torsionAngle.toInt()}°',
                            onChanged: (v) => setState(() => _torsionAngle = v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Angle Kappa (κ): ${_angleKappa.toInt()}Δ (${_angleKappa >= 0 ? "+ Nasal" : "- Temp"})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Slider(
                            value: _angleKappa,
                            min: -10,
                            max: 10,
                            divisions: 20,
                            label: '${_angleKappa.toInt()}Δ',
                            onChanged: (v) => setState(() => _angleKappa = v),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Flashing / Diagnostic Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => setState(() {
                        _flashLeft = true;
                        _flashRight = false;
                      }),
                      icon: const Icon(Icons.flash_on, size: 16),
                      label: const Text('Flash OS'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => setState(() {
                        _flashLeft = true;
                        _flashRight = true;
                      }),
                      icon: const Icon(Icons.lightbulb, size: 16),
                      label: const Text('Both Tubes On'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => setState(() {
                        _flashLeft = false;
                        _flashRight = true;
                      }),
                      icon: const Icon(Icons.flash_on, size: 16),
                      label: const Text('Flash OD'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Clinical ARC readout
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Objective Angle (O): ${_objectiveAngle.toInt()}Δ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Text('Subjective Angle (S): ${_subjectiveAngle.toInt()}Δ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Text('Angle of Anomaly (A): ${_angleOfAnomaly.toInt()}Δ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.indigo)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(_arcDiagnosis, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onPrimaryContainer)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEyepieceBarrel({required String label, required bool isIlluminated, required bool isRight}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isIlluminated ? Colors.white : Colors.black,
              border: Border.all(color: Colors.blueGrey, width: 3),
              boxShadow: isIlluminated
                  ? [BoxShadow(color: Colors.blue.withValues(alpha: 0.4), blurRadius: 16, spreadRadius: 4)]
                  : null,
            ),
            child: ClipOval(
              child: isIlluminated
                  ? AnimatedBuilder(
                      animation: _haidingerAnim,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: SynoptophoreEyepiecePainter(
                            slide: _slide,
                            isRight: isRight,
                            tubeAngleX: _tubeAngleHorizontal,
                            tubeAngleY: _tubeAngleVertical,
                            torsion: _torsionAngle,
                            angleKappa: _angleKappa,
                            animVal: _haidingerAnim.value,
                          ),
                        );
                      },
                    )
                  : const Center(child: Text('OFF', style: TextStyle(color: Colors.white38, fontSize: 12))),
            ),
          ),
        ),
      ],
    );
  }
}

class SynoptophoreEyepiecePainter extends CustomPainter {
  final SynoptophoreSlide slide;
  final bool isRight;
  final double tubeAngleX;
  final double tubeAngleY;
  final double torsion;
  final double angleKappa;
  final double animVal;

  SynoptophoreEyepiecePainter({
    required this.slide,
    required this.isRight,
    required this.tubeAngleX,
    required this.tubeAngleY,
    required this.torsion,
    required this.angleKappa,
    required this.animVal,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.45;

    // Apply tube angle displacement (simulating the optical tube shifting the image across the retina)
    final shiftX = isRight ? (tubeAngleX * 1.5) : (-tubeAngleX * 1.5);
    final shiftY = isRight ? (-tubeAngleY * 1.5) : (tubeAngleY * 1.5);
    final targetCenter = center + Offset(shiftX, shiftY);

    canvas.save();
    // Apply torsion rotation
    canvas.translate(targetCenter.dx, targetCenter.dy);
    canvas.rotate((torsion * pi) / 180.0);
    canvas.translate(-targetCenter.dx, -targetCenter.dy);

    switch (slide) {
      case SynoptophoreSlide.lionAndCage:
        if (isRight) {
          // Right Eye sees the Lion
          _drawLion(canvas, targetCenter, radius * 0.5);
        } else {
          // Left Eye sees the Cage
          _drawCage(canvas, center, radius * 0.75);
        }
        break;

      case SynoptophoreSlide.rabbit:
        // Fusion slides: Left rabbit has tail, right rabbit has ears
        _drawRabbit(canvas, targetCenter, radius * 0.6, hasEars: isRight, hasTail: !isRight);
        break;

      case SynoptophoreSlide.concentricRings:
        // Stereopsis depth circles
        _drawDepthRings(canvas, targetCenter, radius * 0.7, isRight);
        break;

      case SynoptophoreSlide.haidinger:
        // Haidinger Brushes (rotating polarization bowtie)
        _drawHaidingerBrushes(canvas, targetCenter, radius * 0.8, animVal);
        break;

      case SynoptophoreSlide.afterImage:
        // After-image test lines: Right eye horizontal line, Left eye vertical line
        _drawAfterImage(canvas, targetCenter, radius * 0.7, isRight);
        break;
    }

    canvas.restore();

    // Corneal Light Reflex (Hirschberg on Synoptophore) with Angle Kappa
    final reflexOffset = center + Offset(angleKappa * 2.0, 0);
    final reflexPaint = Paint()..color = Colors.amber.withValues(alpha: 0.9);
    canvas.drawCircle(reflexOffset, 3.5, reflexPaint);
  }

  void _drawLion(Canvas canvas, Offset c, double r) {
    final paint = Paint()..color = const Color(0xFFD97706)..style = PaintingStyle.fill;
    // Lion head
    canvas.drawCircle(c, r * 0.6, paint);
    // Mane
    final manePaint = Paint()..color = const Color(0xFF92400E)..style = PaintingStyle.stroke..strokeWidth = 6;
    canvas.drawCircle(c, r * 0.75, manePaint);
    // Eyes & Nose
    final featurePaint = Paint()..color = Colors.black;
    canvas.drawCircle(c + Offset(-r * 0.2, -r * 0.1), 3, featurePaint);
    canvas.drawCircle(c + Offset(r * 0.2, -r * 0.1), 3, featurePaint);
    canvas.drawCircle(c + Offset(0, r * 0.15), 4, featurePaint);
  }

  void _drawCage(Canvas canvas, Offset c, double r) {
    final cagePaint = Paint()..color = Colors.black87..style = PaintingStyle.stroke..strokeWidth = 3;
    final rect = Rect.fromCenter(center: c, width: r * 1.5, height: r * 1.5);
    canvas.drawRect(rect, cagePaint);
    // Vertical cage bars
    for (double x = -r * 0.6; x <= r * 0.6; x += r * 0.3) {
      canvas.drawLine(c + Offset(x, -r * 0.75), c + Offset(x, r * 0.75), cagePaint);
    }
  }

  void _drawRabbit(Canvas canvas, Offset c, double r, {required bool hasEars, required bool hasTail}) {
    final bodyPaint = Paint()..color = const Color(0xFF64748B);
    // Body
    canvas.drawCircle(c, r * 0.5, bodyPaint);
    // Head
    canvas.drawCircle(c + Offset(r * 0.4, -r * 0.3), r * 0.3, bodyPaint);
    // Eye
    canvas.drawCircle(c + Offset(r * 0.45, -r * 0.35), 2.5, Paint()..color = Colors.red);
    // Ears (only in Right eye slide)
    if (hasEars) {
      final earPaint = Paint()..color = const Color(0xFF475569)..strokeWidth = 4..strokeCap = StrokeCap.round;
      canvas.drawLine(c + Offset(r * 0.4, -r * 0.5), c + Offset(r * 0.4, -r * 0.9), earPaint);
      canvas.drawLine(c + Offset(r * 0.5, -r * 0.5), c + Offset(r * 0.55, -r * 0.85), earPaint);
    }
    // Tail (only in Left eye slide)
    if (hasTail) {
      canvas.drawCircle(c + Offset(-r * 0.55, 0), r * 0.15, Paint()..color = Colors.white);
    }
  }

  void _drawDepthRings(Canvas canvas, Offset c, double r, bool isRight) {
    final p = Paint()..style = PaintingStyle.stroke..strokeWidth = 3;
    // Outer circle
    canvas.drawCircle(c, r, p..color = Colors.blue.shade800);
    // Inner circle with slight disparity for 3D depth perception
    final disparity = isRight ? 4.0 : -4.0;
    canvas.drawCircle(c + Offset(disparity, 0), r * 0.5, p..color = Colors.purple.shade700);
  }

  void _drawHaidingerBrushes(Canvas canvas, Offset c, double r, double anim) {
    final angle = anim * 2 * pi;
    final brushPaint = Paint()..color = const Color(0xFFFBBF24).withValues(alpha: 0.65);

    final path = Path();
    // Bowtie geometry
    final p1 = c + Offset(cos(angle) * r * 0.6, sin(angle) * r * 0.6);
    final p2 = c + Offset(cos(angle + 0.5) * r * 0.2, sin(angle + 0.5) * r * 0.2);
    final p3 = c + Offset(cos(angle + pi) * r * 0.6, sin(angle + pi) * r * 0.6);
    final p4 = c + Offset(cos(angle + pi + 0.5) * r * 0.2, sin(angle + pi + 0.5) * r * 0.2);

    path.moveTo(p1.dx, p1.dy);
    path.lineTo(p2.dx, p2.dy);
    path.lineTo(p3.dx, p3.dy);
    path.lineTo(p4.dx, p4.dy);
    path.close();

    canvas.drawPath(path, brushPaint);
    // Macular fixation center
    canvas.drawCircle(c, 4, Paint()..color = Colors.blue.shade900);
  }

  void _drawAfterImage(Canvas canvas, Offset c, double r, bool isRight) {
    final p = Paint()..strokeWidth = 5..strokeCap = StrokeCap.round..color = Colors.amber;
    if (isRight) {
      // Right Eye: Horizontal after-image streak with central gap for fovea
      canvas.drawLine(c - Offset(r, 0), c - const Offset(8, 0), p);
      canvas.drawLine(c + const Offset(8, 0), c + Offset(r, 0), p);
    } else {
      // Left Eye: Vertical after-image streak with central gap
      canvas.drawLine(c - Offset(0, r), c - const Offset(0, 8), p);
      canvas.drawLine(c + const Offset(0, 8), c + Offset(0, r), p);
    }
  }

  @override
  bool shouldRepaint(covariant SynoptophoreEyepiecePainter oldDelegate) => true;
}
