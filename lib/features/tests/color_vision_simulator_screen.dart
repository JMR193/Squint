import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/services/clinical_database_service.dart';
import '../../core/widgets/custom_ui_components.dart';

enum ColorDeficiency { normal, protanopia, deuteranopia, tritanopia, redDesaturation, achromatopsia }

class ColorVisionSimulatorScreen extends StatefulWidget {
  const ColorVisionSimulatorScreen({super.key});

  @override
  State<ColorVisionSimulatorScreen> createState() => _ColorVisionSimulatorScreenState();
}

class _ColorVisionSimulatorScreenState extends State<ColorVisionSimulatorScreen> {
  int _currentPlateIndex = 0;
  ColorDeficiency _selectedDeficiency = ColorDeficiency.normal;
  final TextEditingController _inputController = TextEditingController();
  int _score = 0;
  bool _hasSubmitted = false;

  final List<Map<String, dynamic>> _plates = [
    {
      'number': '12',
      'type': 'Demonstration Plate',
      'normalSee': '12',
      'deficiencySee': '12 (All perceive this plate)',
      'clinical': 'Universal calibration plate. If missed, suspect non-organic visual loss or malingering.',
    },
    {
      'number': '8',
      'type': 'Transformation Plate',
      'normalSee': '8',
      'deficiencySee': '3 (Red-Green Deficient)',
      'clinical': 'Distinguishes normal trichromats from protan/deutan congenital dyschromatopsia.',
    },
    {
      'number': '29',
      'type': 'Transformation Plate',
      'normalSee': '29',
      'deficiencySee': '70 (Red-Green Deficient)',
      'clinical': 'Evaluates mid-spectrum cone sensitivity.',
    },
    {
      'number': '5',
      'type': 'Vanishing Plate',
      'normalSee': '5',
      'deficiencySee': 'Nothing / Unclear',
      'clinical': 'Vanishing plates contain figure dots visible only to intact L/M cone photoreceptors.',
    },
    {
      'number': '74',
      'type': 'Vanishing Plate',
      'normalSee': '74',
      'deficiencySee': '21 or Unclear',
      'clinical': 'Sensitive screening plate for optic nerve conduction delay and optic neuritis.',
    },
  ];

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curPlate = _plates[_currentPlateIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Color Vision & Ishihara Lab'),
        actions: [
          PopupMenuButton<ColorDeficiency>(
            icon: const Icon(Icons.filter_vintage, color: Colors.cyanAccent),
            tooltip: 'Simulate Color Deficiency',
            onSelected: (def) => setState(() => _selectedDeficiency = def),
            itemBuilder: (context) => [
              const PopupMenuItem(value: ColorDeficiency.normal, child: Text('Normal Trichromacy')),
              const PopupMenuItem(value: ColorDeficiency.protanopia, child: Text('Protanopia (Red-Blind)')),
              const PopupMenuItem(value: ColorDeficiency.deuteranopia, child: Text('Deuteranopia (Green-Blind)')),
              const PopupMenuItem(value: ColorDeficiency.tritanopia, child: Text('Tritanopia (Blue-Blind)')),
              const PopupMenuItem(value: ColorDeficiency.redDesaturation, child: Text('Red Desaturation (Optic Neuritis)')),
              const PopupMenuItem(value: ColorDeficiency.achromatopsia, child: Text('Achromatopsia (Total Mono)')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Ishihara Pseudoisochromatic Dot Plate Canvas
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blueGrey.shade700, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: CustomPaint(
                painter: _IshiharaPlatePainter(
                  number: curPlate['number'] as String,
                  deficiency: _selectedDeficiency,
                  seed: _currentPlateIndex * 42,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Simulation active indicator
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.cyan.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.cyanAccent),
              ),
              child: Text(
                'Deficiency Mode: ${_getDeficiencyLabel(_selectedDeficiency)}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.cyanAccent),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 2. Interactive Input & Verification Card
          SamsungOneUiGroupCard(
            title: 'PLATE INTERACTION & SCORING',
            icon: Icons.pin,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Enter number seen on plate',
                          hintText: 'e.g. 12, 8, 29',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      onPressed: () {
                        setState(() {
                          _hasSubmitted = true;
                          if (_inputController.text.trim() == curPlate['normalSee']) {
                            _score++;
                          }
                        });
                      },
                      child: const Text('Verify', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                if (_hasSubmitted) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (_inputController.text.trim() == curPlate['normalSee'])
                          ? Colors.green.withValues(alpha: 0.2)
                          : Colors.red.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: (_inputController.text.trim() == curPlate['normalSee']) ? Colors.green : Colors.red,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Normal Trichromats See: ${curPlate['normalSee']}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Dyschromatopsia Perceived: ${curPlate['deficiencySee']}',
                          style: const TextStyle(fontSize: 11, color: Colors.amberAccent),
                        ),
                      ],
                    ),
                  ),
                ],
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Plate ${_currentPlateIndex + 1} of ${_plates.length}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: _currentPlateIndex > 0
                              ? () => setState(() {
                                    _currentPlateIndex--;
                                    _hasSubmitted = false;
                                    _inputController.clear();
                                  })
                              : null,
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: _currentPlateIndex < _plates.length - 1
                              ? () => setState(() {
                                    _currentPlateIndex++;
                                    _hasSubmitted = false;
                                    _inputController.clear();
                                  })
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 3. Clinical Interpretation & Optic Neuropathy Pearl
          SamsungOneUiGroupCard(
            title: 'CLINICAL SIGNIFICANCE & NEUROPATHY',
            icon: Icons.medical_services,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  curPlate['type'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.cyanAccent),
                ),
                const SizedBox(height: 4),
                Text(
                  curPlate['clinical'] as String,
                  style: const TextStyle(fontSize: 12, height: 1.4),
                ),
                const Divider(height: 16),
                const Text(
                  '💡 Red Desaturation Diagnostic Pearl:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.redAccent),
                ),
                const SizedBox(height: 4),
                const Text(
                  'A subjective loss of red saturation (a bright red object appearing washed out, pink, or brownish) is the earliest and most sensitive clinical marker of compressive or demyelinating optic neuropathy (Optic Neuritis), even with 20/20 Snellen acuity!',
                  style: TextStyle(fontSize: 11, height: 1.3),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  icon: const Icon(Icons.save_as, size: 16),
                  label: const Text('Save Color Vision Result to Patient File', style: TextStyle(fontSize: 12)),
                  onPressed: _saveColorResultToDatabase,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDeficiencyLabel(ColorDeficiency def) {
    switch (def) {
      case ColorDeficiency.normal:
        return 'Normal Trichromacy';
      case ColorDeficiency.protanopia:
        return 'Protanopia (Red Deficit)';
      case ColorDeficiency.deuteranopia:
        return 'Deuteranopia (Green Deficit)';
      case ColorDeficiency.tritanopia:
        return 'Tritanopia (Blue Deficit)';
      case ColorDeficiency.redDesaturation:
        return 'Red Desaturation (Optic Neuritis)';
      case ColorDeficiency.achromatopsia:
        return 'Achromatopsia (Monochrome)';
    }
  }

  Future<void> _saveColorResultToDatabase() async {
    final record = PatientRecord(
      id: 'CV-${DateTime.now().millisecondsSinceEpoch}',
      patientName: 'Color Vision Exam',
      age: 28,
      gender: 'Other',
      primaryDiagnosis: 'Color Vision Screening (Ishihara $_score/${_plates.length})',
      distanceDeviationPd: 0.0,
      distanceDeviationType: 'Normal Ortho',
      nearDeviationPd: 0.0,
      nearDeviationType: 'Normal Ortho',
      visionOd: '20/20',
      visionOs: '20/20',
      bsvGrade: 'Ishihara Score: $_score / ${_plates.length}',
      surgicalPlan: 'Non-surgical • Neurological workup if asymmetric desaturation.',
      patchingPrescription: 'None',
      notes: 'Ishihara pseudoisochromatic plate test performed with $_score correct plates. Tested under mode ${_getDeficiencyLabel(_selectedDeficiency)}.',
      createdAt: DateTime.now(),
    );

    await ClinicalDatabaseService.saveRecord(record);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Color Vision report saved to Patient Records!'),
          backgroundColor: Colors.teal,
        ),
      );
    }
  }
}

class _IshiharaPlatePainter extends CustomPainter {
  final String number;
  final ColorDeficiency deficiency;
  final int seed;

  _IshiharaPlatePainter({
    required this.number,
    required this.deficiency,
    required this.seed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final rand = Random(seed);

    // Background matrix dots (Greens, Oranges, Browns)
    for (int i = 0; i < 450; i++) {
      final r = sqrt(rand.nextDouble()) * (radius - 12);
      final theta = rand.nextDouble() * 2 * pi;
      final dotPos = Offset(center.dx + r * cos(theta), center.dy + r * sin(theta));
      final dotRadius = rand.nextDouble() * 4.5 + 2.5;

      Color dotColor = _getBackgroundDotColor(rand, deficiency);
      canvas.drawCircle(dotPos, dotRadius, Paint()..color = dotColor);
    }

    // Number dots (Orange / Red / Pink)
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: number,
        style: const TextStyle(fontSize: 110, fontWeight: FontWeight.w900, fontFamily: 'monospace'),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final textOffset = center - Offset(tp.width / 2, tp.height / 2);

    for (int i = 0; i < 280; i++) {
      final nx = rand.nextDouble() * tp.width;
      final ny = rand.nextDouble() * tp.height;
      final dotPos = textOffset + Offset(nx, ny);

      // Check if inside text bounds
      if ((dotPos - center).distance < radius - 16) {
        final dotRadius = rand.nextDouble() * 4.0 + 3.0;
        Color numColor = _getNumberDotColor(rand, deficiency);
        canvas.drawCircle(dotPos, dotRadius, Paint()..color = numColor);
      }
    }
  }

  Color _getBackgroundDotColor(Random rand, ColorDeficiency def) {
    if (def == ColorDeficiency.achromatopsia) {
      final shade = rand.nextInt(120) + 60;
      return Color.fromARGB(255, shade, shade, shade);
    }
    if (def == ColorDeficiency.protanopia || def == ColorDeficiency.deuteranopia) {
      // Confused yellowish brownish colors
      return Color.fromARGB(255, 160 + rand.nextInt(40), 150 + rand.nextInt(40), 90);
    }
    // Normal Trichromacy background (Greens & Olives)
    final greens = [
      const Color(0xFF4ADE80),
      const Color(0xFF22C55E),
      const Color(0xFF16A34A),
      const Color(0xFF84CC16),
      const Color(0xFF65A30D),
      const Color(0xFFA3E635),
    ];
    return greens[rand.nextInt(greens.length)];
  }

  Color _getNumberDotColor(Random rand, ColorDeficiency def) {
    if (def == ColorDeficiency.achromatopsia) {
      final shade = rand.nextInt(100) + 80;
      return Color.fromARGB(255, shade, shade, shade);
    }
    if (def == ColorDeficiency.protanopia || def == ColorDeficiency.deuteranopia) {
      // Red vanishes or matches background yellowish brown
      return Color.fromARGB(255, 165 + rand.nextInt(35), 145 + rand.nextInt(35), 95);
    }
    if (def == ColorDeficiency.redDesaturation) {
      // Washed out pale pinkish grey
      return Color.fromARGB(255, 210, 180 + rand.nextInt(20), 180 + rand.nextInt(20));
    }
    // Normal Trichromacy number dots (Vibrant Oranges, Corals, and Reds)
    final reds = [
      const Color(0xFFEF4444),
      const Color(0xFFDC2626),
      const Color(0xFFF97316),
      const Color(0xFFEA580C),
      const Color(0xFFFB923C),
      const Color(0xFFF87171),
    ];
    return reds[rand.nextInt(reds.length)];
  }

  @override
  bool shouldRepaint(covariant _IshiharaPlatePainter oldDelegate) => true;
}
