import 'dart:math';
import 'package:flutter/material.dart';

class UnitySimulatorScreen extends StatefulWidget {
  const UnitySimulatorScreen({super.key});

  @override
  State<UnitySimulatorScreen> createState() => _UnitySimulatorScreenState();
}

class _UnitySimulatorScreenState extends State<UnitySimulatorScreen> with SingleTickerProviderStateMixin {
  String _currentPathology = 'Normal';
  double _gazeX = 0.0; // -1.0 (Left) to +1.0 (Right)
  double _gazeY = 0.0; // -1.0 (Down) to +1.0 (Up)
  bool _showMuscles = true;
  bool _showAxes = true;
  bool _isRightEye = true;

  final List<String> _pathologies = [
    'Normal',
    'Right 6th Nerve Palsy (Abducens)',
    'Left 6th Nerve Palsy (Abducens)',
    'Right 4th Nerve Palsy (Trochlear)',
    'Left 4th Nerve Palsy (Trochlear)',
    'Right 3rd Nerve Palsy (Oculomotor)',
    'Left 3rd Nerve Palsy (Oculomotor)',
    'Duane Syndrome Type 1 (Limited Abduction)',
    'Brown Syndrome (Limited Elevation in Adduction)',
  ];

  void _setPresetGaze(double x, double y) {
    setState(() {
      _gazeX = x;
      _gazeY = y;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3D Ocular Motility Simulator'),
        actions: [
          IconButton(
            tooltip: _isRightEye ? 'Switch to Left Eye' : 'Switch to Right Eye',
            icon: Icon(_isRightEye ? Icons.visibility : Icons.visibility_outlined),
            onPressed: () {
              setState(() {
                _isRightEye = !_isRightEye;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _currentPathology,
                    decoration: const InputDecoration(
                      labelText: 'Pathology / Cranial Nerve Palsy',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    items: _pathologies.map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 13)))).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _currentPathology = val);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(_isRightEye ? 'OD (Right)' : 'OS (Left)'),
                  selected: true,
                  onSelected: (_) {
                    setState(() => _isRightEye = !_isRightEye);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onPanUpdate: (details) {
                final size = MediaQuery.of(context).size;
                setState(() {
                  _gazeX = (_gazeX + (details.delta.dx / (size.width / 3))).clamp(-1.0, 1.0);
                  _gazeY = (_gazeY - (details.delta.dy / (size.height / 4))).clamp(-1.0, 1.0);
                });
              },
              child: Container(
                width: double.infinity,
                color: const Color(0xFF0F172A), // Deep surgical midnight blue
                child: CustomPaint(
                  painter: Realistic3DEyePainter(
                    gazeX: _gazeX,
                    gazeY: _gazeY,
                    pathology: _currentPathology,
                    isRightEye: _isRightEye,
                    showMuscles: _showMuscles,
                    showAxes: _showAxes,
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FilterChip(
                      label: const Text('Muscles'),
                      selected: _showMuscles,
                      onSelected: (v) => setState(() => _showMuscles = v),
                    ),
                    FilterChip(
                      label: const Text('Axes of Fick'),
                      selected: _showAxes,
                      onSelected: (v) => setState(() => _showAxes = v),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _setPresetGaze(0, 0),
                      icon: const Icon(Icons.center_focus_strong, size: 16),
                      label: const Text('Primary Gaze'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Cardinal Positions of Gaze (Tap or Drag Screen):',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildGazeBtn('Up-Left', -0.8, 0.8),
                    _buildGazeBtn('Up', 0.0, 0.9),
                    _buildGazeBtn('Up-Right', 0.8, 0.8),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildGazeBtn('Dextro (R)', 0.9, 0.0),
                    _buildGazeBtn('Center', 0.0, 0.0),
                    _buildGazeBtn('Levo (L)', -0.9, 0.0),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildGazeBtn('Down-Left', -0.8, -0.8),
                    _buildGazeBtn('Down', 0.0, -0.9),
                    _buildGazeBtn('Down-Right', 0.8, -0.8),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGazeBtn(String label, double x, double y) {
    final isSelected = (_gazeX - x).abs() < 0.2 && (_gazeY - y).abs() < 0.2;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: InkWell(
        onTap: () => _setPresetGaze(x, y),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class Realistic3DEyePainter extends CustomPainter {
  final double gazeX;
  final double gazeY;
  final String pathology;
  final bool isRightEye;
  final bool showMuscles;
  final bool showAxes;

  Realistic3DEyePainter({
    required this.gazeX,
    required this.gazeY,
    required this.pathology,
    required this.isRightEye,
    required this.showMuscles,
    required this.showAxes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final eyeRadius = min(size.width, size.height) * 0.32;

    // Calculate effective gaze with pathology limitations
    double effectiveX = gazeX;
    double effectiveY = gazeY;

    if (pathology.contains('6th Nerve Palsy')) {
      // Abduction limitation (Right eye: x > 0; Left eye: x < 0)
      if (pathology.contains('Right') && isRightEye && effectiveX > 0.1) {
        effectiveX = 0.1; // Palsy restricts abduction
      } else if (pathology.contains('Left') && !isRightEye && effectiveX < -0.1) {
        effectiveX = -0.1;
      }
    } else if (pathology.contains('3rd Nerve Palsy')) {
      // Complete 3rd nerve: Eye is 'down and out'
      final affectsThisEye = (pathology.contains('Right') && isRightEye) || (pathology.contains('Left') && !isRightEye);
      if (affectsThisEye) {
        effectiveX = isRightEye ? 0.7 : -0.7; // Exotropia
        effectiveY = -0.6; // Hypotropia
      }
    } else if (pathology.contains('4th Nerve Palsy')) {
      // Superior Oblique: limited depression in adduction, hypertropia
      final affectsThisEye = (pathology.contains('Right') && isRightEye) || (pathology.contains('Left') && !isRightEye);
      if (affectsThisEye) {
        final isAdducted = isRightEye ? effectiveX < -0.2 : effectiveX > 0.2;
        if (isAdducted && effectiveY < 0) {
          effectiveY = 0.2; // Elevation in adduction (overaction of antagonist IO)
        }
      }
    } else if (pathology.contains('Brown Syndrome')) {
      // Limited elevation in adduction (SO tendon sheath restriction)
      final isAdducted = isRightEye ? effectiveX < -0.2 : effectiveX > 0.2;
      if (isAdducted && effectiveY > 0.1) {
        effectiveY = 0.1;
      }
    } else if (pathology.contains('Duane Syndrome Type 1')) {
      // Severe abduction deficit, slight adduction retraction
      if (isRightEye && effectiveX > 0.1) {
        effectiveX = 0.1;
      } else if (!isRightEye && effectiveX < -0.1) {
        effectiveX = -0.1;
      }
    }

    // 1. Draw Orbit Rim / Sockets
    final orbitPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, eyeRadius * 1.35, orbitPaint);

    // 2. Extraocular Muscle Insertion Vectors
    if (showMuscles) {
      _drawExtraocularMuscles(canvas, center, eyeRadius, effectiveX, effectiveY);
    }

    // 3. Eyeball Sclera (3D Shaded Sphere)
    final scleraGradient = RadialGradient(
      center: Alignment(effectiveX * 0.3 - 0.2, -effectiveY * 0.3 - 0.2),
      radius: 0.9,
      colors: const [
        Color(0xFFFFFFFF),
        Color(0xFFF1F5F9),
        Color(0xFFCBD5E1),
        Color(0xFF64748B),
      ],
      stops: const [0.0, 0.4, 0.8, 1.0],
    );

    final scleraPaint = Paint()
      ..shader = scleraGradient.createShader(Rect.fromCircle(center: center, radius: eyeRadius));
    canvas.drawCircle(center, eyeRadius, scleraPaint);

    // Scleral Blood Vessels (Fine conjunctival ciliary injection)
    _drawCiliaryVessels(canvas, center, eyeRadius, effectiveX, effectiveY);

    // 4. Cornea, Iris & Pupil Displacement
    final maxCornealOffset = eyeRadius * 0.65;
    final cornealCenter = Offset(
      center.dx + (effectiveX * maxCornealOffset),
      center.dy - (effectiveY * maxCornealOffset),
    );

    final irisRadius = eyeRadius * 0.45;
    final pupilRadius = irisRadius * 0.42;

    // Cornea 3D Bulge & Depth Shadow
    final limbusPaint = Paint()
      ..color = const Color(0xFF0F172A).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(cornealCenter, irisRadius + 1.5, limbusPaint);

    // Iris Texture & Radial Fibrils
    final irisGradient = RadialGradient(
      colors: const [
        Color(0xFF1E3A8A), // Deep Blue Iris
        Color(0xFF0284C7), // Light cyan striations
        Color(0xFF0369A1),
        Color(0xFF082F49), // Dark collarette
      ],
      stops: const [0.0, 0.5, 0.85, 1.0],
    );
    final irisPaint = Paint()..shader = irisGradient.createShader(Rect.fromCircle(center: cornealCenter, radius: irisRadius));
    canvas.drawCircle(cornealCenter, irisRadius, irisPaint);

    // Pupil
    final pupilPaint = Paint()..color = const Color(0xFF020617);
    canvas.drawCircle(cornealCenter, pupilRadius, pupilPaint);

    // Corneal Specular Light Reflex (Hirschberg Light Reflex simulation!)
    final reflexOffset = cornealCenter + const Offset(-7, -9);
    final reflexPaint = Paint()..color = Colors.white.withValues(alpha: 0.95);
    canvas.drawCircle(reflexOffset, 4.5, reflexPaint);

    final secondaryReflex = cornealCenter + const Offset(9, 10);
    final secReflexPaint = Paint()..color = Colors.white.withValues(alpha: 0.4);
    canvas.drawCircle(secondaryReflex, 2.5, secReflexPaint);

    // 5. Axes of Fick (Z-axis vertical, X-axis transverse, Y-axis visual)
    if (showAxes) {
      _drawAxesOfFick(canvas, center, eyeRadius);
    }
  }

  void _drawExtraocularMuscles(Canvas canvas, Offset center, double radius, double gx, double gy) {
    final musclePaint = Paint()
      ..color = const Color(0xFFE11D48).withValues(alpha: 0.85) // Reddish tendon/muscle
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    final tendonPaint = Paint()
      ..color = const Color(0xFFFDE047).withValues(alpha: 0.75) // Yellow tendon
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    // Superior Rectus (Top)
    final srStart = Offset(center.dx, center.dy - radius * 1.35);
    final srEnd = Offset(center.dx + (gx * radius * 0.2), center.dy - radius * 0.75);
    canvas.drawLine(srStart, srEnd, musclePaint);
    canvas.drawLine(srEnd - const Offset(0, 8), srEnd, tendonPaint);

    // Inferior Rectus (Bottom)
    final irStart = Offset(center.dx, center.dy + radius * 1.35);
    final irEnd = Offset(center.dx + (gx * radius * 0.2), center.dy + radius * 0.75);
    canvas.drawLine(irStart, irEnd, musclePaint);
    canvas.drawLine(irEnd + const Offset(0, 8), irEnd, tendonPaint);

    // Medial & Lateral Recti depending on OD/OS
    final mrIsLeft = isRightEye; // OD medial is towards the nose (left side of screen)
    final mrStart = Offset(mrIsLeft ? center.dx - radius * 1.35 : center.dx + radius * 1.35, center.dy);
    final mrEnd = Offset(mrIsLeft ? center.dx - radius * 0.8 : center.dx + radius * 0.8, center.dy - (gy * radius * 0.2));
    canvas.drawLine(mrStart, mrEnd, musclePaint);

    final lrStart = Offset(mrIsLeft ? center.dx + radius * 1.35 : center.dx - radius * 1.35, center.dy);
    final lrEnd = Offset(mrIsLeft ? center.dx + radius * 0.8 : center.dx - radius * 0.8, center.dy - (gy * radius * 0.2));
    canvas.drawLine(lrStart, lrEnd, musclePaint);

    // Muscle Labels
    final textStyle = const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold);
    _drawText(canvas, 'SR', Offset(center.dx - 8, center.dy - radius * 1.25), textStyle);
    _drawText(canvas, 'IR', Offset(center.dx - 8, center.dy + radius * 1.15), textStyle);
    _drawText(canvas, mrIsLeft ? 'MR (Nasal)' : 'LR (Temporal)', Offset(center.dx - radius * 1.3, center.dy - 8), textStyle);
    _drawText(canvas, mrIsLeft ? 'LR (Temporal)' : 'MR (Nasal)', Offset(center.dx + radius * 0.9, center.dy - 8), textStyle);
  }

  void _drawCiliaryVessels(Canvas canvas, Offset center, double radius, double gx, double gy) {
    final vesselPaint = Paint()
      ..color = const Color(0xFFDC2626).withValues(alpha: 0.2)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(center.dx - radius * 0.7, center.dy - radius * 0.2);
    path.quadraticBezierTo(center.dx - radius * 0.5, center.dy - radius * 0.4, center.dx - radius * 0.2, center.dy - radius * 0.3);

    path.moveTo(center.dx + radius * 0.6, center.dy + radius * 0.3);
    path.quadraticBezierTo(center.dx + radius * 0.4, center.dy + radius * 0.5, center.dx + radius * 0.2, center.dy + radius * 0.3);

    canvas.drawPath(path, vesselPaint);
  }

  void _drawAxesOfFick(Canvas canvas, Offset center, double radius) {
    final axisPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.35)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Vertical Z-axis
    canvas.drawLine(Offset(center.dx, center.dy - radius * 1.2), Offset(center.dx, center.dy + radius * 1.2), axisPaint);
    // Transverse X-axis
    canvas.drawLine(Offset(center.dx - radius * 1.2, center.dy), Offset(center.dx + radius * 1.2, center.dy), axisPaint);
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant Realistic3DEyePainter oldDelegate) {
    return oldDelegate.gazeX != gazeX ||
        oldDelegate.gazeY != gazeY ||
        oldDelegate.pathology != pathology ||
        oldDelegate.isRightEye != isRightEye ||
        oldDelegate.showMuscles != showMuscles ||
        oldDelegate.showAxes != showAxes;
  }
}
