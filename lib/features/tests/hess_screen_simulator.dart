import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/widgets/custom_ui_components.dart';

class HessScreenSimulator extends StatefulWidget {
  const HessScreenSimulator({super.key});

  @override
  State<HessScreenSimulator> createState() => _HessScreenSimulatorState();
}

class _HessScreenSimulatorState extends State<HessScreenSimulator> {
  String _selectedCondition = 'r_vi_palsy'; // normal, r_vi_palsy, r_iv_palsy, l_iii_palsy, blowout_ir, duane_type1
  bool _showRightEye = true;
  bool _showLeftEye = true;
  bool _showOuterGrid = true;

  final Map<String, Map<String, dynamic>> _conditionData = {
    'normal': {
      'name': 'Normal Symmetrical Motility (Orthophoria)',
      'description': 'Both right and left eye fields are equal in area and symmetrically centered within the 15° and 30° tangent screen borders.',
      'underaction': 'None',
      'overaction': 'None',
      'clinical': 'Full range of extraocular movement with equal innervation.',
    },
    'r_vi_palsy': {
      'name': 'Right Lateral Rectus Palsy (CN VI)',
      'description': 'Right eye field is compressed horizontally on right lateral gaze (Right LR underaction). Left eye field demonstrates secondary overaction of the yoke Left Medial Rectus.',
      'underaction': 'Right Lateral Rectus (LR)',
      'overaction': 'Left Medial Rectus (MR) - Hering\'s Law',
      'clinical': 'Esotropia greatest on dextroversion; horizontal uncrossed diplopia at distance.',
    },
    'r_iv_palsy': {
      'name': 'Right Superior Oblique Palsy (CN IV)',
      'description': 'Right eye field shows marked underaction in depression and adduction (Right SO). Left eye shows yoke overaction of the Left Inferior Rectus.',
      'underaction': 'Right Superior Oblique (SO)',
      'overaction': 'Left Inferior Rectus (IR) & Right IO (Antagonist)',
      'clinical': 'Positive Parks-Bielschowsky 3-step test: Right hypertropia worse on left gaze and right head tilt. Patient adopts left compensatory head tilt.',
    },
    'l_iii_palsy': {
      'name': 'Left Oculomotor Nerve Palsy (CN III)',
      'description': 'Left eye field is severely constricted across superior, medial, and inferior gazes (SR, MR, IR, IO paretic). Only abduction (LR) and intorsion (SO) remain.',
      'underaction': 'Left SR, MR, IR, and IO',
      'overaction': 'Right LR and contralateral synergists',
      'clinical': 'Down-and-out resting position with ptosis and mydriasis (if pupil-involved). High emergency rule-out for PCoA aneurysm.',
    },
    'blowout_ir': {
      'name': 'Right Orbital Floor Blowout Fracture (IR Entrapment)',
      'description': 'Mechanical restriction of elevation in the right eye due to entrapment of inferior rectus and orbital fat in the maxillary roof fracture.',
      'underaction': 'Right Elevation (Mechanical tethering)',
      'overaction': 'Minimal yoke overaction (Mechanical vs Neurogenic sign)',
      'clinical': 'Positive forced duction test; enophthalmos, infraorbital nerve hypoesthesia.',
    },
    'duane_type1': {
      'name': 'Duane Retraction Syndrome Type 1',
      'description': 'Congenital absence of sixth nerve nucleus with anomalous innervation of LR by third nerve branches.',
      'underaction': 'Abduction deficit with globe retraction in adduction',
      'overaction': 'Mild upshoot/downshoot in adduction',
      'clinical': 'Palpebral fissure narrowing on adduction with widening on abduction.',
    },
  };

  @override
  Widget build(BuildContext context) {
    final curData = _conditionData[_selectedCondition] ?? _conditionData['normal']!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hess / Lees Screen Motility Chart'),
        actions: [
          IconButton(
            icon: Icon(_showOuterGrid ? Icons.grid_on : Icons.grid_off, color: Colors.cyanAccent),
            tooltip: 'Toggle 30° Outer Tangent Grid',
            onPressed: () => setState(() => _showOuterGrid = !_showOuterGrid),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Interactive Tangent Hess Screen Canvas (Distortion-Free 1:1 Aspect Ratio)
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360, maxHeight: 360),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF090D16),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF334155), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: CustomPaint(
                    painter: _HessScreenPainter(
                      condition: _selectedCondition,
                      showRightEye: _showRightEye,
                      showLeftEye: _showLeftEye,
                      showOuterGrid: _showOuterGrid,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Eye visibility toggles
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilterChip(
                label: const Text('Right Eye (Green Plot)', style: TextStyle(fontSize: 11)),
                selected: _showRightEye,
                selectedColor: Colors.green.withValues(alpha: 0.25),
                checkmarkColor: Colors.greenAccent,
                onSelected: (val) => setState(() => _showRightEye = val),
              ),
              const SizedBox(width: 10),
              FilterChip(
                label: const Text('Left Eye (Red Plot)', style: TextStyle(fontSize: 11)),
                selected: _showLeftEye,
                selectedColor: Colors.red.withValues(alpha: 0.25),
                checkmarkColor: Colors.redAccent,
                onSelected: (val) => setState(() => _showLeftEye = val),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 2. Condition Findings Card
          SamsungOneUiGroupCard(
            title: 'HESS TANGENT FIELD INTERPRETATION',
            icon: Icons.analytics,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  curData['name'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.cyanAccent),
                ),
                const SizedBox(height: 6),
                Text(
                  curData['description'] as String,
                  style: const TextStyle(fontSize: 12, height: 1.4),
                ),
                const Divider(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _buildFindingBadge('Underaction (Smaller Field)', curData['underaction'] as String, Colors.redAccent),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildFindingBadge('Overaction (Yoke Muscle)', curData['overaction'] as String, Colors.greenAccent),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Diagnostic Pearl: ${curData['clinical']}',
                  style: const TextStyle(fontSize: 11, color: Colors.amberAccent, height: 1.3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 3. Clinical Pathology Presets
          SamsungOneUiGroupCard(
            title: 'CLINICAL MOTILITY PRESETS',
            icon: Icons.list_alt,
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: _selectedCondition,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: _conditionData.entries.map((e) {
                return DropdownMenuItem(
                  value: e.key,
                  child: Text(e.value['name'] as String, style: const TextStyle(fontSize: 12)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedCondition = val);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFindingBadge(String title, String muscle, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(muscle, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
        ],
      ),
    );
  }
}

class _HessScreenPainter extends CustomPainter {
  final String condition;
  final bool showRightEye;
  final bool showLeftEye;
  final bool showOuterGrid;

  _HessScreenPainter({
    required this.condition,
    required this.showRightEye,
    required this.showLeftEye,
    required this.showOuterGrid,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    // 1. Draw Red-Green Tangent Screen Grid (Inner 15°, Outer 30°)
    final Paint gridPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 1.0;

    final Paint axisPaint = Paint()
      ..color = const Color(0xFF475569)
      ..strokeWidth = 1.5;

    final double step = min(w, h) / 10;

    // Grid lines
    for (int i = -4; i <= 4; i++) {
      canvas.drawLine(Offset(center.dx + i * step, 10), Offset(center.dx + i * step, h - 10), gridPaint);
      canvas.drawLine(Offset(10, center.dy + i * step), Offset(w - 10, center.dy + i * step), gridPaint);
    }

    // Axes
    canvas.drawLine(Offset(center.dx, 10), Offset(center.dx, h - 10), axisPaint);
    canvas.drawLine(Offset(10, center.dy), Offset(w - 10, center.dy), axisPaint);

    // Inner 15° square & Outer 30° square
    final Paint box15Paint = Paint()
      ..color = const Color(0xFF64748B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(Rect.fromCenter(center: center, width: step * 4, height: step * 4), box15Paint);

    if (showOuterGrid) {
      final Paint box30Paint = Paint()
        ..color = const Color(0xFF334155)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawRect(Rect.fromCenter(center: center, width: step * 8, height: step * 8), box30Paint);
    }

    // Grid Labels (Temp / Nasal)
    _drawLabel(canvas, Offset(25, center.dy - 12), 'Temp', Colors.grey);
    _drawLabel(canvas, Offset(w - 25, center.dy - 12), 'Nasal', Colors.grey);
    _drawLabel(canvas, Offset(center.dx, 20), 'Up (30°)', Colors.grey);
    _drawLabel(canvas, Offset(center.dx, h - 20), 'Down (30°)', Colors.grey);

    // 2. Compute 8 Diagnostic Vector Coordinates for Right and Left Eye
    final double baseR = step * 2; // 15° base radius

    // Right Eye points (Green)
    List<Offset> rePoints = [
      Offset(center.dx, center.dy - baseR), // Up (SR/IO)
      Offset(center.dx + baseR, center.dy - baseR), // Up-Right (IO/SR)
      Offset(center.dx + baseR, center.dy), // Right (LR)
      Offset(center.dx + baseR, center.dy + baseR), // Down-Right (SO/IR)
      Offset(center.dx, center.dy + baseR), // Down (IR/SO)
      Offset(center.dx - baseR, center.dy + baseR), // Down-Left (IR)
      Offset(center.dx - baseR, center.dy), // Left (MR)
      Offset(center.dx - baseR, center.dy - baseR), // Up-Left (SR)
    ];

    // Left Eye points (Red)
    List<Offset> lePoints = [
      Offset(center.dx, center.dy - baseR),
      Offset(center.dx + baseR, center.dy - baseR),
      Offset(center.dx + baseR, center.dy),
      Offset(center.dx + baseR, center.dy + baseR),
      Offset(center.dx, center.dy + baseR),
      Offset(center.dx - baseR, center.dy + baseR),
      Offset(center.dx - baseR, center.dy),
      Offset(center.dx - baseR, center.dy - baseR),
    ];

    // Apply Pathology Modifications
    if (condition == 'r_vi_palsy') {
      // Right LR underaction (Right horizontal shift inward)
      rePoints[1] = Offset(center.dx + baseR * 0.4, center.dy - baseR);
      rePoints[2] = Offset(center.dx + baseR * 0.3, center.dy);
      rePoints[3] = Offset(center.dx + baseR * 0.4, center.dy + baseR);

      // Left MR yoke overaction (Left eye overaction on dextroversion)
      lePoints[1] = Offset(center.dx + baseR * 1.4, center.dy - baseR * 1.1);
      lePoints[2] = Offset(center.dx + baseR * 1.5, center.dy);
      lePoints[3] = Offset(center.dx + baseR * 1.4, center.dy + baseR * 1.1);
    } else if (condition == 'r_iv_palsy') {
      // Right SO underaction in down-and-in (Down-Left)
      rePoints[5] = Offset(center.dx - baseR * 0.4, center.dy + baseR * 0.3);
      // Right IO antagonist overaction (Up-Left)
      rePoints[7] = Offset(center.dx - baseR * 1.4, center.dy - baseR * 1.4);

      // Left IR yoke overaction
      lePoints[5] = Offset(center.dx - baseR * 1.4, center.dy + baseR * 1.5);
    } else if (condition == 'l_iii_palsy') {
      // Left eye severe constriction in all fields except abduction
      for (int i = 0; i < lePoints.length; i++) {
        if (i != 6) { // Except Left (LR)
          lePoints[i] = Offset(
            center.dx + (lePoints[i].dx - center.dx) * 0.35,
            center.dy + (lePoints[i].dy - center.dy) * 0.35,
          );
        }
      }
    } else if (condition == 'blowout_ir') {
      // Mechanical upgaze restriction in Right Eye
      rePoints[0] = Offset(center.dx, center.dy - baseR * 0.2);
      rePoints[1] = Offset(center.dx + baseR, center.dy - baseR * 0.2);
      rePoints[7] = Offset(center.dx - baseR, center.dy - baseR * 0.2);
    } else if (condition == 'duane_type1') {
      // Severe abduction deficit in Right Eye
      rePoints[2] = Offset(center.dx + baseR * 0.2, center.dy);
    }

    // 3. Draw Polygons & Points
    if (showRightEye) {
      _drawHessField(canvas, rePoints, Colors.greenAccent, 'OD (Green)');
    }
    if (showLeftEye) {
      _drawHessField(canvas, lePoints, Colors.redAccent, 'OS (Red)');
    }
  }

  void _drawHessField(Canvas canvas, List<Offset> points, Color color, String eyeLabel) {
    final Paint linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final Paint fillPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final Paint dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Path path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, linePaint);

    for (final pt in points) {
      canvas.drawCircle(pt, 4.0, dotPaint);
    }
  }

  void _drawLabel(Canvas canvas, Offset pos, String text, Color color) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, pos - Offset(textPainter.width / 2, textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant _HessScreenPainter oldDelegate) => true;
}
