import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/widgets/custom_ui_components.dart';

enum CoverState { none, rightCovered, leftCovered }
enum DeviationPreset { esotropia, exotropia, hypertropia, orthophoria, intermittentExo }

class CoverTest3dStudioScreen extends StatefulWidget {
  const CoverTest3dStudioScreen({super.key});

  @override
  State<CoverTest3dStudioScreen> createState() => _CoverTest3dStudioScreenState();
}

class _CoverTest3dStudioScreenState extends State<CoverTest3dStudioScreen> with SingleTickerProviderStateMixin {
  CoverState _coverState = CoverState.none;
  DeviationPreset _preset = DeviationPreset.esotropia;
  double _appliedPrismDiopters = 0.0;
  String _prismBase = 'BO'; // BO, BI, BD, BU
  bool _isAlternateTest = false;

  late AnimationController _paddleAnimCtrl;

  @override
  void initState() {
    super.initState();
    _paddleAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void dispose() {
    _paddleAnimCtrl.dispose();
    super.dispose();
  }

  void _toggleCover(CoverState state) {
    setState(() {
      _coverState = state;
    });
    _paddleAnimCtrl.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    // Determine manifest deviation angle
    double manifestAnglePd = 0.0;
    switch (_preset) {
      case DeviationPreset.esotropia:
        manifestAnglePd = 20.0;
        break;
      case DeviationPreset.exotropia:
        manifestAnglePd = 25.0;
        break;
      case DeviationPreset.hypertropia:
        manifestAnglePd = 14.0;
        break;
      case DeviationPreset.orthophoria:
        manifestAnglePd = 0.0;
        break;
      case DeviationPreset.intermittentExo:
        manifestAnglePd = 18.0;
        break;
    }

    // Residual movement after applying prism
    final residualMovement = (manifestAnglePd - _appliedPrismDiopters).clamp(-30.0, 30.0);
    final isNeutralized = residualMovement.abs() <= 1.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('3D Cover Test & Prism Studio'),
        actions: [
          IconButton(
            icon: Icon(_isAlternateTest ? Icons.sync : Icons.sync_disabled, color: Colors.cyanAccent),
            tooltip: 'Toggle Cross-Cover / Alternate Cover Test',
            onPressed: () {
              setState(() {
                _isAlternateTest = !_isAlternateTest;
                if (_isAlternateTest) {
                  _coverState = CoverState.rightCovered;
                }
              });
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Interactive 3D Binocular Eye Stage with Paddle Occluder (Distortion-Free Binocular Ratio)
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420, maxHeight: 280),
              child: AspectRatio(
                aspectRatio: 1.5,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF090D16),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF1E293B), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: AnimatedBuilder(
                    animation: _paddleAnimCtrl,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _CoverTestStagePainter(
                          coverState: _coverState,
                          preset: _preset,
                          residualMovement: residualMovement,
                          appliedPrism: _appliedPrismDiopters,
                          prismBase: _prismBase,
                          animProgress: _paddleAnimCtrl.value,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Neutralization Status Banner
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isNeutralized ? Colors.green.withValues(alpha: 0.2) : Colors.amber.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isNeutralized ? Colors.greenAccent : Colors.amberAccent),
              ),
              child: Text(
                isNeutralized
                    ? '🎯 NEUTRALIZED! True Angle = ${_appliedPrismDiopters.toStringAsFixed(0)}Δ $_prismBase'
                    : 'Refixation Saccade: ${residualMovement.abs().toStringAsFixed(1)}Δ Residual Shift',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isNeutralized ? Colors.greenAccent : Colors.amberAccent,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 2. Interactive Occluder Controls
          SamsungOneUiGroupCard(
            title: 'OCCLUDER PADDLE CONTROLS',
            icon: Icons.shield,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.visibility_off, size: 16),
                    label: const Text('Cover OD (Right)', style: TextStyle(fontSize: 11)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _coverState == CoverState.rightCovered ? Colors.cyanAccent : Colors.blueGrey.shade900,
                      foregroundColor: _coverState == CoverState.rightCovered ? Colors.black : Colors.white,
                    ),
                    onPressed: () => _toggleCover(CoverState.rightCovered),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _coverState == CoverState.none ? Colors.cyanAccent : Colors.blueGrey.shade900,
                      foregroundColor: _coverState == CoverState.none ? Colors.black : Colors.white,
                    ),
                    onPressed: () => _toggleCover(CoverState.none),
                    child: const Text('Uncover (Both)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.visibility_off, size: 16),
                    label: const Text('Cover OS (Left)', style: TextStyle(fontSize: 11)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _coverState == CoverState.leftCovered ? Colors.cyanAccent : Colors.blueGrey.shade900,
                      foregroundColor: _coverState == CoverState.leftCovered ? Colors.black : Colors.white,
                    ),
                    onPressed: () => _toggleCover(CoverState.leftCovered),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 3. Virtual Prism Neutralization Bar
          SamsungOneUiGroupCard(
            title: 'PRISM BAR NEUTRALIZATION',
            icon: Icons.change_history,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Prism Power: ${_appliedPrismDiopters.toStringAsFixed(0)} Δ $_prismBase', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.cyanAccent)),
                    Wrap(
                      spacing: 4,
                      children: ['BO', 'BI', 'BU', 'BD'].map((base) {
                        final isSel = _prismBase == base;
                        return ChoiceChip(
                          label: Text(base, style: TextStyle(fontSize: 10, color: isSel ? Colors.black : Colors.white)),
                          selected: isSel,
                          selectedColor: Colors.cyanAccent,
                          onSelected: (_) => setState(() => _prismBase = base),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                Slider(
                  value: _appliedPrismDiopters,
                  min: 0,
                  max: 45,
                  divisions: 45,
                  label: '${_appliedPrismDiopters.toInt()} Δ',
                  onChanged: (val) => setState(() => _appliedPrismDiopters = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 4. Clinical Deviation Preset Selector
          SamsungOneUiGroupCard(
            title: 'STRABISMUS PHENOTYPE PRESET',
            icon: Icons.category,
            child: DropdownButtonFormField<DeviationPreset>(
              isExpanded: true,
              initialValue: _preset,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: DeviationPreset.esotropia, child: Text('Right Esotropia 20Δ (Inward Turn)')),
                DropdownMenuItem(value: DeviationPreset.exotropia, child: Text('Right Exotropia 25Δ (Outward Turn)')),
                DropdownMenuItem(value: DeviationPreset.hypertropia, child: Text('Right Hypertropia 14Δ (Upward Turn)')),
                DropdownMenuItem(value: DeviationPreset.intermittentExo, child: Text('Intermittent Exotropia 18Δ (Phoria to Tropia)')),
                DropdownMenuItem(value: DeviationPreset.orthophoria, child: Text('Orthophoria 0Δ (Perfect Alignment)')),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _preset = val;
                    _appliedPrismDiopters = 0.0;
                    _prismBase = (val == DeviationPreset.esotropia) ? 'BO' : ((val == DeviationPreset.exotropia) ? 'BI' : 'BD');
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverTestStagePainter extends CustomPainter {
  final CoverState coverState;
  final DeviationPreset preset;
  final double residualMovement;
  final double appliedPrism;
  final String prismBase;
  final double animProgress;

  _CoverTestStagePainter({
    required this.coverState,
    required this.preset,
    required this.residualMovement,
    required this.appliedPrism,
    required this.prismBase,
    required this.animProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    final eyeRadius = min(w, h) * 0.22;
    final leftEyeCenter = Offset(center.dx - eyeRadius * 1.5, center.dy);
    final rightEyeCenter = Offset(center.dx + eyeRadius * 1.5, center.dy);

    // Compute deviation shift for Right Eye
    double reShiftX = 0;
    double reShiftY = 0;

    if (coverState == CoverState.none) {
      // Manifest deviation in Right Eye if left eye is fixating
      if (preset == DeviationPreset.esotropia) reShiftX = -(residualMovement * 0.8);
      if (preset == DeviationPreset.exotropia) reShiftX = (residualMovement * 0.8);
      if (preset == DeviationPreset.hypertropia) reShiftY = -(residualMovement * 0.8);
    } else if (coverState == CoverState.leftCovered) {
      // When Left eye covered, Right eye takes up central fixation with saccade!
      reShiftX = 0;
      reShiftY = 0;
    }

    // 1. Draw Left Eye (OS) & Right Eye (OD)
    _drawEye(canvas, leftEyeCenter, eyeRadius, Offset.zero, 'Left Eye (OS - Fixating)');
    _drawEye(canvas, rightEyeCenter, eyeRadius, Offset(reShiftX, reShiftY), 'Right Eye (OD - Test)');

    // 2. Draw Virtual Prism Bar over Right Eye if prism applied
    if (appliedPrism > 0) {
      final Paint prismPaint = Paint()
        ..color = Colors.cyanAccent.withValues(alpha: 0.35)
        ..style = PaintingStyle.fill;
      final Paint prismBorder = Paint()
        ..color = Colors.cyanAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      final Rect prismRect = Rect.fromCenter(center: rightEyeCenter, width: eyeRadius * 2.2, height: eyeRadius * 2.4);
      canvas.drawRect(prismRect, prismPaint);
      canvas.drawRect(prismRect, prismBorder);

      // Draw Base orientation triangle
      final Path baseTriangle = Path();
      if (prismBase == 'BO') {
        baseTriangle.moveTo(prismRect.right, prismRect.top);
        baseTriangle.lineTo(prismRect.right, prismRect.bottom);
        baseTriangle.lineTo(prismRect.right - 10, prismRect.center.dy);
        baseTriangle.close();
      } else if (prismBase == 'BI') {
        baseTriangle.moveTo(prismRect.left, prismRect.top);
        baseTriangle.lineTo(prismRect.left, prismRect.bottom);
        baseTriangle.lineTo(prismRect.left + 10, prismRect.center.dy);
        baseTriangle.close();
      }
      canvas.drawPath(baseTriangle, Paint()..color = Colors.cyanAccent);
    }

    // 3. Draw Occluder Paddle Animation
    if (coverState != CoverState.none) {
      final targetEye = (coverState == CoverState.rightCovered) ? rightEyeCenter : leftEyeCenter;
      final paddleCenter = Offset(targetEye.dx, targetEye.dy * (0.8 + animProgress * 0.2));

      final Paint paddlePaint = Paint()..color = const Color(0xFF1E293B);
      final Paint paddleRim = Paint()
        ..color = Colors.cyanAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      // Round Paddle Disc
      canvas.drawCircle(paddleCenter, eyeRadius * 1.15, paddlePaint);
      canvas.drawCircle(paddleCenter, eyeRadius * 1.15, paddleRim);

      // Paddle Handle
      final Paint handlePaint = Paint()
        ..color = const Color(0xFF334155)
        ..strokeWidth = 10.0
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(paddleCenter + Offset(0, eyeRadius * 1.15), paddleCenter + Offset(0, eyeRadius * 2.6), handlePaint);
    }
  }

  void _drawEye(Canvas canvas, Offset center, double radius, Offset pupilShift, String label) {
    // Sclera
    final Paint sclera = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius, sclera);

    // Sclera boundary
    final Paint rim = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, radius, rim);

    // Cornea & Iris with Shift
    final Offset pupilCenter = center + pupilShift;
    final Paint iris = Paint()..color = const Color(0xFF0284C7);
    canvas.drawCircle(pupilCenter, radius * 0.52, iris);

    // Pupil
    final Paint pupil = Paint()..color = Colors.black;
    canvas.drawCircle(pupilCenter, radius * 0.22, pupil);

    // Specular Reflection
    final Paint glint = Paint()..color = Colors.white;
    canvas.drawCircle(pupilCenter - const Offset(4, 4), 3, glint);

    // Label
    final TextPainter tp = TextPainter(
      text: TextSpan(text: label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy + radius + 8));
  }

  @override
  bool shouldRepaint(covariant _CoverTestStagePainter oldDelegate) => true;
}
