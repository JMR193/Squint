import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

enum FixationTarget { near, middle, far }
enum SuppressionState { none, rightEye, leftEye }

class BrockStringSimulatorScreen extends StatefulWidget {
  const BrockStringSimulatorScreen({super.key});

  @override
  State<BrockStringSimulatorScreen> createState() => _BrockStringSimulatorScreenState();
}

class _BrockStringSimulatorScreenState extends State<BrockStringSimulatorScreen> {
  FixationTarget _fixation = FixationTarget.middle;
  SuppressionState _suppression = SuppressionState.none;
  final double _nearBeadDist = 0.25; // 0.1 to 0.4
  final double _middleBeadDist = 0.55; // 0.4 to 0.7
  final double _farBeadDist = 0.85; // 0.7 to 0.95

  // Exercise Mode
  bool _isExerciseMode = false;
  FixationTarget _promptedTarget = FixationTarget.near;
  int _score = 0;
  int _jumpsRemaining = 10;
  Timer? _exerciseTimer;

  void _startExercise() {
    setState(() {
      _isExerciseMode = true;
      _score = 0;
      _jumpsRemaining = 10;
      _nextJumpPrompt();
    });
  }

  void _nextJumpPrompt() {
    final targets = FixationTarget.values.where((t) => t != _promptedTarget).toList();
    setState(() {
      _promptedTarget = targets[Random().nextInt(targets.length)];
    });
  }

  void _userSelectedTarget(FixationTarget target) {
    if (_isExerciseMode) {
      if (target == _promptedTarget) {
        _score += 10;
      }
      _jumpsRemaining--;
      if (_jumpsRemaining <= 0) {
        setState(() {
          _isExerciseMode = false;
        });
        _showCompletionDialog();
      } else {
        _nextJumpPrompt();
      }
    }
    setState(() {
      _fixation = target;
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Jump Vergence Complete!'),
        content: Text('Your Vergence Score: $_score / 100\nGreat job training conscious physiological diplopia and vergence flexibility!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _exerciseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Virtual Brock String Simulator'),
        actions: [
          IconButton(
            icon: Icon(_isExerciseMode ? Icons.stop : Icons.play_arrow),
            tooltip: _isExerciseMode ? 'Stop Jump Vergence' : 'Start Jump Vergence Training',
            onPressed: () {
              if (_isExerciseMode) {
                setState(() => _isExerciseMode = false);
              } else {
                _startExercise();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isExerciseMode)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Prompt: Fixate on ${_promptedTarget.name.toUpperCase()} Bead!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    'Score: $_score | Jumps: $_jumpsRemaining',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          // Interactive 3D Perspective Canvas
          Expanded(
            child: Container(
              color: const Color(0xFF0B132B), // Deep visual optical space
              child: CustomPaint(
                size: Size.infinite,
                painter: BrockStringPainter(
                  fixation: _fixation,
                  suppression: _suppression,
                  nearDist: _nearBeadDist,
                  middleDist: _middleBeadDist,
                  farDist: _farBeadDist,
                ),
              ),
            ),
          ),
          // Diagnostic Explanation & Controls
          Container(
            padding: const EdgeInsets.all(14),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text('Fixate Bead: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SegmentedButton<FixationTarget>(
                        segments: const [
                          ButtonSegment(value: FixationTarget.near, label: Text('Near (Green)')),
                          ButtonSegment(value: FixationTarget.middle, label: Text('Mid (Yellow)')),
                          ButtonSegment(value: FixationTarget.far, label: Text('Far (Red)')),
                        ],
                        selected: {_fixation},
                        onSelectionChanged: (set) => _userSelectedTarget(set.first),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('Cortical State: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SegmentedButton<SuppressionState>(
                        segments: const [
                          ButtonSegment(value: SuppressionState.none, label: Text('Normal (X-Pattern)')),
                          ButtonSegment(value: SuppressionState.rightEye, label: Text('Suppress OD')),
                          ButtonSegment(value: SuppressionState.leftEye, label: Text('Suppress OS')),
                        ],
                        selected: {_suppression},
                        onSelectionChanged: (set) => setState(() => _suppression = set.first),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 18, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getPhysiologicalDiplopiaExplanation(),
                          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ),
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

  String _getPhysiologicalDiplopiaExplanation() {
    if (_suppression != SuppressionState.none) {
      return 'Suppression Detected: Patient only sees ONE string entering their bridge of nose. One cortical visual pathway is inhibited to avoid confusion.';
    }
    switch (_fixation) {
      case FixationTarget.middle:
        return 'Normal "X" Pattern: Strings cross perfectly through the Yellow Bead. The Near (Green) bead appears doubled (crossed diplopia), and the Far (Red) bead appears doubled (uncrossed diplopia).';
      case FixationTarget.near:
        return 'Normal "V" Pattern: Strings converge on the Near Green Bead and open outward towards infinity. Both Middle and Far beads appear doubled.';
      case FixationTarget.far:
        return 'Normal "A" / Inverted "V" Pattern: Strings diverge until reaching the Far Red Bead at the fixation plane.';
    }
  }
}

class BrockStringPainter extends CustomPainter {
  final FixationTarget fixation;
  final SuppressionState suppression;
  final double nearDist;
  final double middleDist;
  final double farDist;

  BrockStringPainter({
    required this.fixation,
    required this.suppression,
    required this.nearDist,
    required this.middleDist,
    required this.farDist,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bottomY = size.height * 0.92;
    final topY = size.height * 0.12;

    // Patient's Left Eye and Right Eye anchor points at bridge of nose (bottom of screen)
    final leftEye = Offset(size.width * 0.28, bottomY);
    final rightEye = Offset(size.width * 0.72, bottomY);

    // Far anchor point on wall (top center of visual corridor)
    final vanishingPoint = Offset(size.width * 0.5, topY);

    // Determine the 2D intersection point based on active fixation
    final fixateFraction = fixation == FixationTarget.near
        ? nearDist
        : fixation == FixationTarget.middle
            ? middleDist
            : farDist;

    final fixatePoint = Offset(
      size.width * 0.5,
      bottomY - ((bottomY - topY) * fixateFraction),
    );

    // 1. Draw Simulated Perspective Background Grid Lines
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1.0;
    for (int i = 0; i < 6; i++) {
      final frac = i / 5.0;
      final y = bottomY - ((bottomY - topY) * frac);
      canvas.drawLine(Offset(size.width * 0.1, y), Offset(size.width * 0.9, y), gridPaint);
    }

    // 2. Draw Strings based on Physiological Diplopia & Suppression
    final stringPaintLeft = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.85) // Blue string from left eye
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final stringPaintRight = Paint()
      ..color = const Color(0xFFF43F5E).withValues(alpha: 0.85) // Reddish-pink string from right eye
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    // Line from Left Eye: crosses to right visual space beyond the fixation point (forming the X)
    if (suppression != SuppressionState.leftEye) {
      // Left eye sees a straight line extending from left eye through the fixatePoint toward the opposite side
      final slopeX = (fixatePoint.dx - leftEye.dx) / (leftEye.dy - fixatePoint.dy);
      final destX = fixatePoint.dx + (slopeX * (fixatePoint.dy - topY));
      canvas.drawLine(leftEye, Offset(destX, topY), stringPaintLeft);
    }

    // Line from Right Eye: crosses to left visual space beyond the fixation point
    if (suppression != SuppressionState.rightEye) {
      final slopeX = (fixatePoint.dx - rightEye.dx) / (rightEye.dy - fixatePoint.dy);
      final destX = fixatePoint.dx + (slopeX * (fixatePoint.dy - topY));
      canvas.drawLine(rightEye, Offset(destX, topY), stringPaintRight);
    }

    // 3. Draw Eye Indicator Labels at Bottom
    final textStyle = const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold);
    _drawText(canvas, 'OS (Left Eye)', leftEye + const Offset(-35, 10), textStyle);
    _drawText(canvas, 'OD (Right Eye)', rightEye + const Offset(-35, 10), textStyle);
    _drawText(canvas, 'Fixation Anchor (Wall)', vanishingPoint + const Offset(-60, -20), textStyle);

    // 4. Render Beads (Near, Middle, Far) with Physiological Diplopia (Doubling)
    _renderBeadGroup(canvas, size, bottomY, topY, nearDist, const Color(0xFF22C55E), 'Near (Green)', fixation == FixationTarget.near, fixatePoint, leftEye, rightEye);
    _renderBeadGroup(canvas, size, bottomY, topY, middleDist, const Color(0xFFEAB308), 'Mid (Yellow)', fixation == FixationTarget.middle, fixatePoint, leftEye, rightEye);
    _renderBeadGroup(canvas, size, bottomY, topY, farDist, const Color(0xFFEF4444), 'Far (Red)', fixation == FixationTarget.far, fixatePoint, leftEye, rightEye);
  }

  void _renderBeadGroup(
    Canvas canvas,
    Size size,
    double bottomY,
    double topY,
    double fraction,
    Color color,
    String label,
    bool isFixated,
    Offset fixPoint,
    Offset leftEye,
    Offset rightEye,
  ) {
    final y = bottomY - ((bottomY - topY) * fraction);
    final beadRadius = 14.0 * (0.6 + (1.0 - fraction) * 0.7);

    if (isFixated) {
      // Single fused bead where strings intersect
      final center = Offset(size.width * 0.5, y);
      _drawSphericalBead(canvas, center, beadRadius, color, true);
      _drawText(canvas, '$label [FUSED]', center + Offset(beadRadius + 8, -6), const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold));
    } else {
      // Non-fixated bead: splits into two beads due to physiological diplopia!
      // Compute horizontal coordinate along the left-eye line and right-eye line at this y
      final slopeLeft = (fixPoint.dx - leftEye.dx) / (leftEye.dy - fixPoint.dy);
      final slopeRight = (fixPoint.dx - rightEye.dx) / (rightEye.dy - fixPoint.dy);

      final leftPos = Offset(leftEye.dx + (slopeLeft * (leftEye.dy - y)), y);
      final rightPos = Offset(rightEye.dx + (slopeRight * (rightEye.dy - y)), y);

      if (suppression != SuppressionState.leftEye) {
        _drawSphericalBead(canvas, leftPos, beadRadius * 0.9, color.withValues(alpha: 0.65), false);
      }
      if (suppression != SuppressionState.rightEye) {
        _drawSphericalBead(canvas, rightPos, beadRadius * 0.9, color.withValues(alpha: 0.65), false);
      }

      // Draw diplopic label
      final diplopiaType = fraction < (fixPoint.dy / bottomY) ? 'Crossed' : 'Uncrossed';
      _drawText(canvas, '$label (2x $diplopiaType)', Offset(size.width * 0.5 - 45, y - beadRadius - 12), TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10));
    }
  }

  void _drawSphericalBead(Canvas canvas, Offset center, double radius, Color color, bool isGlowing) {
    if (isGlowing) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(center, radius + 6, glowPaint);
    }

    final gradient = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      radius: 0.85,
      colors: [
        Colors.white,
        color,
        color.withValues(alpha: 0.8),
        Colors.black87,
      ],
      stops: const [0.0, 0.4, 0.7, 1.0],
    );

    final paint = Paint()..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final tp = TextPainter(text: TextSpan(text: text, style: style), textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant BrockStringPainter oldDelegate) => true;
}
