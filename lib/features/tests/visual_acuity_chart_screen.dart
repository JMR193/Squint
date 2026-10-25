import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/services/clinical_database_service.dart';
import '../../core/widgets/custom_ui_components.dart';

enum OptotypeType { snellen, tumblingE, leaSymbols, numbers }
enum ChartLayoutMode { single, line, fullChart }

class VisualAcuityChartScreen extends StatefulWidget {
  const VisualAcuityChartScreen({super.key});

  @override
  State<VisualAcuityChartScreen> createState() => _VisualAcuityChartScreenState();
}

class _VisualAcuityChartScreenState extends State<VisualAcuityChartScreen> {
  OptotypeType _optotype = OptotypeType.snellen;
  ChartLayoutMode _layoutMode = ChartLayoutMode.line;
  int _currentLineIndex = 4; // 20/40 (Line 4)
  bool _isDuochromeActive = false;
  bool _isCrowdingBarsActive = false;
  String _distance = '6m'; // 3m, 4m, 6m, 20ft
  int _tumblingEDirection = 0; // 0: Right, 1: Down, 2: Left, 3: Up

  final List<Map<String, dynamic>> _acuityLines = [
    {'snellen': '20/200', 'metric': '6/60', 'logmar': '1.0', 'decimal': '0.10', 'letters': ['E']},
    {'snellen': '20/100', 'metric': '6/30', 'logmar': '0.7', 'decimal': '0.20', 'letters': ['F', 'P']},
    {'snellen': '20/70', 'metric': '6/20', 'logmar': '0.54', 'decimal': '0.28', 'letters': ['T', 'O', 'Z']},
    {'snellen': '20/50', 'metric': '6/15', 'logmar': '0.4', 'decimal': '0.40', 'letters': ['L', 'P', 'E', 'D']},
    {'snellen': '20/40', 'metric': '6/12', 'logmar': '0.3', 'decimal': '0.50', 'letters': ['P', 'E', 'C', 'F', 'D']},
    {'snellen': '20/30', 'metric': '6/9', 'logmar': '0.18', 'decimal': '0.67', 'letters': ['E', 'D', 'F', 'C', 'Z', 'P']},
    {'snellen': '20/25', 'metric': '6/7.5', 'logmar': '0.1', 'decimal': '0.80', 'letters': ['F', 'E', 'L', 'O', 'P', 'Z', 'D']},
    {'snellen': '20/20', 'metric': '6/6', 'logmar': '0.0', 'decimal': '1.00', 'letters': ['D', 'E', 'F', 'P', 'O', 'T', 'E', 'C']},
    {'snellen': '20/15', 'metric': '6/4.5', 'logmar': '-0.12', 'decimal': '1.33', 'letters': ['L', 'E', 'F', 'O', 'D', 'P', 'C', 'T']},
  ];

  @override
  Widget build(BuildContext context) {
    final curLine = _acuityLines[_currentLineIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Visual Acuity & Optotype Chart'),
        actions: [
          IconButton(
            icon: Icon(
              _isDuochromeActive ? Icons.contrast : Icons.circle_outlined,
              color: _isDuochromeActive ? Colors.redAccent : Colors.cyanAccent,
            ),
            tooltip: 'Toggle Red-Green Duochrome Test',
            onPressed: () => setState(() => _isDuochromeActive = !_isDuochromeActive),
          ),
          IconButton(
            icon: Icon(
              _isCrowdingBarsActive ? Icons.crop_square : Icons.crop_free,
              color: _isCrowdingBarsActive ? Colors.amberAccent : Colors.white70,
            ),
            tooltip: 'Toggle Amblyopia Crowding Bars',
            onPressed: () => setState(() => _isCrowdingBarsActive = !_isCrowdingBarsActive),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Digital Acuity Chart Display Viewport
          Container(
            width: double.infinity,
            height: 260,
            decoration: BoxDecoration(
              color: _isDuochromeActive ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blueGrey.shade700, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // Duochrome split background if active
                if (_isDuochromeActive)
                  Row(
                    children: [
                      Expanded(
                        child: Container(color: const Color(0xFFDC2626)), // Red filter
                      ),
                      Expanded(
                        child: Container(color: const Color(0xFF16A34A)), // Green filter
                      ),
                    ],
                  ),

                // Optotypes Canvas
                Center(
                  child: CustomPaint(
                    size: const Size(double.infinity, 240),
                    painter: _OptotypeChartPainter(
                      optotype: _optotype,
                      layoutMode: _layoutMode,
                      letters: (curLine['letters'] as List<String>),
                      lineIndex: _currentLineIndex,
                      isDuochrome: _isDuochromeActive,
                      hasCrowdingBars: _isCrowdingBarsActive,
                      tumblingEDirection: _tumblingEDirection,
                    ),
                  ),
                ),

                // Acuity Info Badge
                Positioned(
                  top: 10,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Snellen: ${curLine['snellen']} • LogMAR: ${curLine['logmar']}',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Chart Controls row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_circle_left, size: 32, color: Colors.cyanAccent),
                onPressed: _currentLineIndex > 0
                    ? () => setState(() => _currentLineIndex--)
                    : null,
                tooltip: 'Larger Optotypes (Lower Acuity)',
              ),
              const SizedBox(width: 16),
              Text(
                'Line ${_currentLineIndex + 1} of ${_acuityLines.length} (${curLine['snellen']})',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.arrow_circle_right, size: 32, color: Colors.cyanAccent),
                onPressed: _currentLineIndex < _acuityLines.length - 1
                    ? () => setState(() => _currentLineIndex++)
                    : null,
                tooltip: 'Smaller Optotypes (Higher Acuity)',
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 2. Optotype Selection & Modes
          SamsungOneUiGroupCard(
            title: 'OPTOTYPE & PEDIA SELECTION',
            icon: Icons.font_download,
            child: Column(
              children: [
                Row(
                  children: [
                    _buildOptotypeSelector(OptotypeType.snellen, 'Snellen / Sloan', Icons.abc),
                    const SizedBox(width: 8),
                    _buildOptotypeSelector(OptotypeType.tumblingE, 'Tumbling E (Illiterate)', Icons.grid_view),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildOptotypeSelector(OptotypeType.leaSymbols, 'Lea Pediatric Symbols', Icons.toys),
                    const SizedBox(width: 8),
                    _buildOptotypeSelector(OptotypeType.numbers, 'Numeric Optotypes', Icons.numbers),
                  ],
                ),
                if (_optotype == OptotypeType.tumblingE) ...[
                  const Divider(height: 16),
                  const Text('Rotate Tumbling E Direction:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton.filledTonal(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () => setState(() => _tumblingEDirection = 0),
                      ),
                      IconButton.filledTonal(
                        icon: const Icon(Icons.arrow_downward),
                        onPressed: () => setState(() => _tumblingEDirection = 1),
                      ),
                      IconButton.filledTonal(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => setState(() => _tumblingEDirection = 2),
                      ),
                      IconButton.filledTonal(
                        icon: const Icon(Icons.arrow_upward),
                        onPressed: () => setState(() => _tumblingEDirection = 3),
                      ),
                    ],
                  ),
                ],
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Test Distance:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    Wrap(
                      spacing: 6,
                      children: ['3m', '4m', '6m', '20ft'].map((d) {
                        final isSel = _distance == d;
                        return ChoiceChip(
                          label: Text(d, style: TextStyle(fontSize: 10, color: isSel ? Colors.black : Colors.white)),
                          selected: isSel,
                          selectedColor: Colors.cyanAccent,
                          onSelected: (_) => setState(() => _distance = d),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Display Mode:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    SegmentedButton<ChartLayoutMode>(
                      segments: const [
                        ButtonSegment(value: ChartLayoutMode.line, label: Text('Full Line', style: TextStyle(fontSize: 10))),
                        ButtonSegment(value: ChartLayoutMode.single, label: Text('Single Letter', style: TextStyle(fontSize: 10))),
                      ],
                      selected: {_layoutMode},
                      onSelectionChanged: (val) => setState(() => _layoutMode = val.first),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 3. Multi-Metric Conversion Table
          SamsungOneUiGroupCard(
            title: 'VISUAL ACUITY METRIC CONVERSIONS',
            icon: Icons.calculate,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetricChip('Snellen 20ft', curLine['snellen'] as String, Colors.cyanAccent),
                    _buildMetricChip('Metric 6m', curLine['metric'] as String, Colors.blueAccent),
                    _buildMetricChip('LogMAR', curLine['logmar'] as String, Colors.amberAccent),
                    _buildMetricChip('Decimal', curLine['decimal'] as String, Colors.tealAccent),
                  ],
                ),
                const Divider(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.save_as, size: 16),
                        label: const Text('Record to Patient File', style: TextStyle(fontSize: 12)),
                        onPressed: _saveAcuityToDatabase,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 4. Clinical Pearls (Duochrome & Amblyopia Crowding)
          SamsungOneUiGroupCard(
            title: 'CLINICAL TESTING PROTOCOLS',
            icon: Icons.school,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '1. Duochrome (Bichrome) Spherical Refraction Refinement:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.orangeAccent),
                ),
                const SizedBox(height: 4),
                const Text(
                  '• Red clearer: Letters on red background sharper -> Patient is under-minused or over-plussed (needs more - sphere).\n'
                  '• Green clearer: Letters on green background sharper -> Patient is over-minused or under-plussed (needs more + sphere).\n'
                  '• Equal clarity: Spherical endpoint achieved.',
                  style: TextStyle(fontSize: 11, height: 1.4),
                ),
                const SizedBox(height: 8),
                const Text(
                  '2. Amblyopia Crowding Phenomenon:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.lightGreenAccent),
                ),
                const SizedBox(height: 4),
                const Text(
                  '• Amblyopic eyes often read isolated single letters 2-3 lines better than crowded lines due to contour interaction.\n'
                  '• Always test with crowding bars to accurately detect amblyopic visual deficits.',
                  style: TextStyle(fontSize: 11, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptotypeSelector(OptotypeType type, String label, IconData icon) {
    final isSelected = _optotype == type;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _optotype = type),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.cyan.withValues(alpha: 0.2) : Colors.black12,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? Colors.cyanAccent : Colors.blueGrey.shade700,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: isSelected ? Colors.cyanAccent : Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.cyanAccent : Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricChip(String title, String value, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Text(
            value,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
          ),
        ),
      ],
    );
  }

  Future<void> _saveAcuityToDatabase() async {
    final curLine = _acuityLines[_currentLineIndex];
    final record = PatientRecord(
      id: 'VA-${DateTime.now().millisecondsSinceEpoch}',
      patientName: 'Visual Acuity Exam',
      age: 25,
      gender: 'Other',
      primaryDiagnosis: 'Visual Acuity Screening (${curLine['snellen']})',
      distanceDeviationPd: 0.0,
      distanceDeviationType: 'Distance Acuity',
      nearDeviationPd: 0.0,
      nearDeviationType: 'Line ${_currentLineIndex + 1}',
      visionOd: curLine['snellen'] as String,
      visionOs: curLine['snellen'] as String,
      bsvGrade: 'Metric: ${curLine['metric']} • LogMAR: ${curLine['logmar']}',
      surgicalPlan: 'Standard refractive workup & amblyopia monitoring.',
      patchingPrescription: 'None',
      notes: 'Visual Acuity line ${curLine['snellen']} tested at $_distance with ${_optotype.name} optotypes.',
      createdAt: DateTime.now(),
    );

    await ClinicalDatabaseService.saveRecord(record);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Visual Acuity (${curLine['snellen']}) saved to Patient Records!'),
          backgroundColor: Colors.teal,
        ),
      );
    }
  }
}

class _OptotypeChartPainter extends CustomPainter {
  final OptotypeType optotype;
  final ChartLayoutMode layoutMode;
  final List<String> letters;
  final int lineIndex;
  final bool isDuochrome;
  final bool hasCrowdingBars;
  final int tumblingEDirection;

  _OptotypeChartPainter({
    required this.optotype,
    required this.layoutMode,
    required this.letters,
    required this.lineIndex,
    required this.isDuochrome,
    required this.hasCrowdingBars,
    required this.tumblingEDirection,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Scale font size based on line index (Line 0 is huge 20/200, Line 8 is small 20/15)
    final double optotypeHeight = (90.0 - lineIndex * 8.0).clamp(20.0, 95.0);

    if (isDuochrome) {
      // Draw letters on both Red and Green sides
      final leftCenterX = size.width * 0.25;
      final rightCenterX = size.width * 0.75;
      final letter = letters.first;

      _drawSingleOptotype(canvas, Offset(leftCenterX, center.dy), letter, optotypeHeight, Colors.black);
      _drawSingleOptotype(canvas, Offset(rightCenterX, center.dy), letter, optotypeHeight, Colors.black);
      return;
    }

    if (layoutMode == ChartLayoutMode.line) {
      final int count = letters.length;
      final double totalWidth = count * (optotypeHeight * 1.1);
      final double startX = (size.width - totalWidth) / 2 + (optotypeHeight * 0.55);

      for (int i = 0; i < count; i++) {
        final x = startX + i * (optotypeHeight * 1.1);
        _drawSingleOptotype(canvas, Offset(x, center.dy), letters[i], optotypeHeight, Colors.black);
      }

      // Draw Amblyopia Crowding Bars surrounding the line if enabled
      if (hasCrowdingBars) {
        final Paint barPaint = Paint()
          ..color = Colors.black
          ..strokeWidth = 3.5;
        final double barMargin = optotypeHeight * 0.4;
        final double leftX = startX - optotypeHeight * 0.6;
        final double rightX = startX + (count - 1) * (optotypeHeight * 1.1) + optotypeHeight * 0.6;
        final double topY = center.dy - optotypeHeight * 0.6 - barMargin;
        final double bottomY = center.dy + optotypeHeight * 0.6 + barMargin;

        // Top bar
        canvas.drawLine(Offset(leftX, topY), Offset(rightX, topY), barPaint);
        // Bottom bar
        canvas.drawLine(Offset(leftX, bottomY), Offset(rightX, bottomY), barPaint);
        // Left bar
        canvas.drawLine(Offset(leftX, topY), Offset(leftX, bottomY), barPaint);
        // Right bar
        canvas.drawLine(Offset(rightX, topY), Offset(rightX, bottomY), barPaint);
      }
    }
  }

  void _drawSingleOptotype(Canvas canvas, Offset pos, String letter, double size, Color color) {
    if (optotype == OptotypeType.tumblingE) {
      _drawTumblingE(canvas, pos, size, tumblingEDirection, color);
      return;
    }

    if (optotype == OptotypeType.leaSymbols) {
      _drawLeaSymbol(canvas, pos, size, letter, color);
      return;
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text: letter,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.w900,
          fontFamily: 'monospace',
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(canvas, pos - Offset(textPainter.width / 2, textPainter.height / 2));
  }

  void _drawTumblingE(Canvas canvas, Offset pos, double size, int direction, Color color) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(direction * (pi / 2));

    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = size * 0.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final double half = size * 0.4;
    // Backbone
    canvas.drawLine(Offset(-half, -half), Offset(-half, half), paint);
    // Top arm
    canvas.drawLine(Offset(-half, -half), Offset(half, -half), paint);
    // Middle arm
    canvas.drawLine(Offset(-half, 0), Offset(half * 0.7, 0), paint);
    // Bottom arm
    canvas.drawLine(Offset(-half, half), Offset(half, half), paint);

    canvas.restore();
  }

  void _drawLeaSymbol(Canvas canvas, Offset pos, double size, String letter, Color color) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double radius = size * 0.35;

    // Cycle through Lea Symbols: Circle, House, Apple/Heart, Square
    final int index = letter.codeUnitAt(0) % 4;
    switch (index) {
      case 0: // Circle
        canvas.drawCircle(pos, radius, paint);
        break;
      case 1: // Square
        canvas.drawRect(Rect.fromCenter(center: pos, width: radius * 1.8, height: radius * 1.8), paint);
        break;
      case 2: // House
        final Path house = Path()
          ..moveTo(pos.dx, pos.dy - radius * 1.2)
          ..lineTo(pos.dx + radius * 0.9, pos.dy - radius * 0.2)
          ..lineTo(pos.dx + radius * 0.9, pos.dy + radius)
          ..lineTo(pos.dx - radius * 0.9, pos.dy + radius)
          ..lineTo(pos.dx - radius * 0.9, pos.dy - radius * 0.2)
          ..close();
        canvas.drawPath(house, paint);
        break;
      case 3: // Apple / Heart
        final Path apple = Path()
          ..addOval(Rect.fromCenter(center: Offset(pos.dx - radius * 0.4, pos.dy), width: radius * 1.1, height: radius * 1.3))
          ..addOval(Rect.fromCenter(center: Offset(pos.dx + radius * 0.4, pos.dy), width: radius * 1.1, height: radius * 1.3));
        canvas.drawPath(apple, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _OptotypeChartPainter oldDelegate) => true;
}
