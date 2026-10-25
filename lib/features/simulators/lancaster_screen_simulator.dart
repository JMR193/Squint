import 'dart:math';
import 'package:flutter/material.dart';

class LancasterScreenSimulator extends StatefulWidget {
  const LancasterScreenSimulator({super.key});

  @override
  State<LancasterScreenSimulator> createState() => _LancasterScreenSimulatorState();
}

class _LancasterScreenSimulatorState extends State<LancasterScreenSimulator> {
  // Examiner Target Coordinate (Red streak)
  Offset _redStreakPos = Offset.zero;

  // Patient Adjustable Coordinate & Tilt (Green streak)
  Offset _greenStreakPos = const Offset(15, -10);
  double _greenStreakRotation = 8.0; // degrees of cyclodeviation

  // Preset Incomitant Clinical Cases
  String _selectedCase = 'Right 4th Nerve Palsy (Exclyclotorsion + RHT)';

  final Map<String, ({Offset redOffset, Offset greenOffset, double rot, String note})> _cases = {
    'Right 4th Nerve Palsy (Exclyclotorsion + RHT)': (
      redOffset: const Offset(0, 0),
      greenOffset: const Offset(5, -18), // RHT: green displaced down/in
      rot: 9.0, // Excyclotorsion on right gaze
      note: 'Right 4th Palsy: Excyclotorsion and right hyperdeviation greatest in levo-depression (down and left).',
    ),
    'Right 6th Nerve Palsy (LR Underaction)': (
      redOffset: const Offset(60, 0), // Dextroversion
      greenOffset: const Offset(20, 0), // Underaction of Right LR
      rot: 0.0,
      note: 'Right 6th Palsy: Large uncrossed horizontal separation in dextroversion.',
    ),
    'Orbital Floor Blowout (Inferior Rectus Entrapment)': (
      redOffset: const Offset(0, 60), // Upgaze
      greenOffset: const Offset(0, 10), // Severe mechanical elevation restriction
      rot: -4.0,
      note: 'Blowout Fracture: Marked limitation of elevation in the affected eye due to trapped inferior rectus in maxillary sinus.',
    ),
  };

  void _applyCase(String caseName) {
    final c = _cases[caseName]!;
    setState(() {
      _selectedCase = caseName;
      _redStreakPos = c.redOffset;
      _greenStreakPos = c.greenOffset;
      _greenStreakRotation = c.rot;
    });
  }

  @override
  Widget build(BuildContext context) {
    final horizDev = (_greenStreakPos.dx - _redStreakPos.dx).toInt();
    final vertDev = (_greenStreakPos.dy - _redStreakPos.dy).toInt();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lancaster Red-Green Screen'),
      ),
      body: Column(
        children: [
          // Case selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: DropdownButtonFormField<String>(
              initialValue: _selectedCase,
              decoration: const InputDecoration(
                labelText: 'Clinical Case Preset',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              items: _cases.keys.map((k) => DropdownMenuItem(value: k, child: Text(k, style: const TextStyle(fontSize: 13)))).toList(),
              onChanged: (v) {
                if (v != null) _applyCase(v);
              },
            ),
          ),
          // Tangent Grid Canvas
          Expanded(
            child: Container(
              color: const Color(0xFF030712), // Dark tangent examination room
              child: CustomPaint(
                size: Size.infinite,
                painter: LancasterGridPainter(
                  redStreakPos: _redStreakPos,
                  greenStreakPos: _greenStreakPos,
                  greenRotation: _greenStreakRotation,
                ),
              ),
            ),
          ),
          // Patient Torch Controls
          Container(
            padding: const EdgeInsets.all(14),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Patient Green Flashlight Controls:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Horizontal: $horizDevΔ (${horizDev >= 0 ? "Uncrossed/Eso" : "Crossed/Exo"})', style: const TextStyle(fontSize: 11)),
                          Slider(
                            value: _greenStreakPos.dx,
                            min: -80,
                            max: 80,
                            divisions: 160,
                            label: '$horizDevΔ',
                            onChanged: (v) => setState(() => _greenStreakPos = Offset(v, _greenStreakPos.dy)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Vertical: $vertDevΔ (${vertDev >= 0 ? "Hypo" : "Hyper"})', style: const TextStyle(fontSize: 11)),
                          Slider(
                            value: _greenStreakPos.dy,
                            min: -50,
                            max: 50,
                            divisions: 100,
                            label: '$vertDevΔ',
                            onChanged: (v) => setState(() => _greenStreakPos = Offset(_greenStreakPos.dx, v)),
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
                          Text('Cyclotorsion: ${_greenStreakRotation.toInt()}° (${_greenStreakRotation >= 0 ? "Excyclotorsion" : "Incyclotorsion"})', style: const TextStyle(fontSize: 11)),
                          Slider(
                            value: _greenStreakRotation,
                            min: -20,
                            max: 20,
                            divisions: 40,
                            label: '${_greenStreakRotation.toInt()}°',
                            onChanged: (v) => setState(() => _greenStreakRotation = v),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => setState(() {
                        _greenStreakPos = _redStreakPos;
                        _greenStreakRotation = 0;
                      }),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Superimpose'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _cases[_selectedCase]?.note ?? '',
                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onPrimaryContainer),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LancasterGridPainter extends CustomPainter {
  final Offset redStreakPos;
  final Offset greenStreakPos;
  final double greenRotation;

  LancasterGridPainter({
    required this.redStreakPos,
    required this.greenStreakPos,
    required this.greenRotation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // 1. Tangent Screen Grid (2cm squares representing 1Δ or 1° at 1 meter or 2 meters)
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 1.0;

    final step = 22.0;
    for (double x = center.dx % step; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = center.dy % step; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Major Axes
    final axisPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), axisPaint);
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), axisPaint);

    // 2. Examiner Red Streak (Fixed coordinate target)
    final redTarget = center + redStreakPos;
    final redStreakPaint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2);

    canvas.drawLine(redTarget - const Offset(24, 0), redTarget + const Offset(24, 0), redStreakPaint);

    // 3. Patient Green Streak (Adjustable coordinate & tilt)
    final greenTarget = center + greenStreakPos;
    final greenStreakPaint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2);

    canvas.save();
    canvas.translate(greenTarget.dx, greenTarget.dy);
    canvas.rotate((greenRotation * pi) / 180.0);
    canvas.drawLine(const Offset(-24, 0), const Offset(24, 0), greenStreakPaint);
    canvas.restore();

    // 4. Labels
    _drawText(canvas, 'Examiner: Red (OD)', const Offset(12, 12), const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold));
    _drawText(canvas, 'Patient: Green (OS)', const Offset(12, 28), const TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold));
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final tp = TextPainter(text: TextSpan(text: text, style: style), textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant LancasterGridPainter oldDelegate) => true;
}
