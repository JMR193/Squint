import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/services/clinical_database_service.dart';
import '../../core/widgets/custom_ui_components.dart';

enum AniseikoniaOrientation { horizontal, vertical }

class AniseikoniaTestScreen extends StatefulWidget {
  const AniseikoniaTestScreen({super.key});

  @override
  State<AniseikoniaTestScreen> createState() => _AniseikoniaTestScreenState();
}

class _AniseikoniaTestScreenState extends State<AniseikoniaTestScreen> {
  final List<double> _percentageSteps = [
    0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 10.0, 12.0, 14.0, 16.0, 18.0, 20.0, 24.0
  ];
  int _currentStepIndex = 0;
  AniseikoniaOrientation _orientation = AniseikoniaOrientation.horizontal;
  bool _redTargetIsLarger = true; // Red bracket larger vs Green bracket larger

  final TextEditingController _patientIdCtrl = TextEditingController();
  final TextEditingController _odPowerCtrl = TextEditingController(text: '-2.00');
  final TextEditingController _osPowerCtrl = TextEditingController(text: '-4.50');
  final TextEditingController _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _patientIdCtrl.dispose();
    _odPowerCtrl.dispose();
    _osPowerCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  double get _currentPercentage => _percentageSteps[_currentStepIndex];

  double _calculatePredictedAniseikonia() {
    final od = double.tryParse(_odPowerCtrl.text) ?? 0.0;
    final os = double.tryParse(_osPowerCtrl.text) ?? 0.0;
    final anisometropia = (od - os).abs();
    // Rule of thumb: ~1.0% aniseikonia per 0.75 D anisometropia in spectacle wear
    return (anisometropia / 0.75) * 1.0;
  }

  void _saveToDatabase() async {
    final measuredAniseikonia = '${_currentPercentage.toStringAsFixed(1)}% ${_redTargetIsLarger ? "(OD Image Larger)" : "(OS Image Larger)"}';
    final predicted = _calculatePredictedAniseikonia().toStringAsFixed(1);

    String diagnosis = _currentPercentage <= 1.0
        ? 'Physiological Symmetry (No Significant Aniseikonia)'
        : 'Significant Aniseikonia: $_currentPercentage% ${_orientation == AniseikoniaOrientation.horizontal ? "Horizontal" : "Vertical"}';

    final record = PatientRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientName: _patientIdCtrl.text.trim().isEmpty ? 'Anonymous Patient' : _patientIdCtrl.text.trim(),
      age: 28,
      gender: 'Unspecified',
      primaryDiagnosis: diagnosis,
      notes: 'Exam: Awaya NAT (${_orientation == AniseikoniaOrientation.horizontal ? "Horizontal" : "Vertical"}). Measured: $measuredAniseikonia. Predicted from Rx: $predicted%. Notes: ${_notesCtrl.text.trim()}',
      createdAt: DateTime.now(),
    );

    await ClinicalDatabaseService.saveRecord(record);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.greenAccent),
              const SizedBox(width: 8),
              Expanded(child: Text('Aniseikonia Exam saved: $measuredAniseikonia')),
            ],
          ),
          backgroundColor: const Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final predictedAniseikonia = _calculatePredictedAniseikonia();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Awaya Aniseikonia Test (NAT)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Aniseikonia Principles',
            onPressed: _showInfoDialog,
          ),
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Save Record',
            onPressed: _saveToDatabase,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instructions Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.purpleAccent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.4)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.visibility, color: Colors.purpleAccent, size: 22),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Wear Red-Green Glasses (Red OD, Green OS) at 40 cm. Cycle brackets until the patient reports the Red and Green semicircles appear equal in size.',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 1. Awaya Semicircular Target Stage
            Container(
              height: 280,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.blueGrey.shade800, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.8),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: CustomPaint(
                  size: const Size(260, 240),
                  painter: _AwayaBracketsPainter(
                    percentageDiff: _currentPercentage,
                    orientation: _orientation,
                    redIsLarger: _redTargetIsLarger,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // 2. Size Comparison Stepper Controls
            SamsungOneUiGroupCard(
              title: 'SIZE DISPARITY STEPS & ORIENTATION',
              icon: Icons.tune,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Target Disparity Size:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          Text(
                            '$_currentPercentage% Disparity',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.cyanAccent),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton.filled(
                            icon: const Icon(Icons.remove),
                            style: IconButton.styleFrom(backgroundColor: Colors.blueGrey.shade800),
                            onPressed: _currentStepIndex > 0 ? () => setState(() => _currentStepIndex--) : null,
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            icon: const Icon(Icons.add),
                            style: IconButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black),
                            onPressed: _currentStepIndex < _percentageSteps.length - 1 ? () => setState(() => _currentStepIndex++) : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Slider(
                    value: _currentStepIndex.toDouble(),
                    min: 0,
                    max: (_percentageSteps.length - 1).toDouble(),
                    divisions: _percentageSteps.length - 1,
                    activeColor: Colors.cyanAccent,
                    onChanged: (v) => setState(() => _currentStepIndex = v.toInt()),
                  ),
                  const Divider(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          avatar: const Icon(Icons.swap_horiz, size: 14),
                          label: const Text('Horizontal Disparity', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          selected: _orientation == AniseikoniaOrientation.horizontal,
                          selectedColor: Colors.cyanAccent,
                          onSelected: (_) => setState(() => _orientation = AniseikoniaOrientation.horizontal),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          avatar: const Icon(Icons.swap_vert, size: 14),
                          label: const Text('Vertical Disparity', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          selected: _orientation == AniseikoniaOrientation.vertical,
                          selectedColor: Colors.cyanAccent,
                          onSelected: (_) => setState(() => _orientation = AniseikoniaOrientation.vertical),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Red Target is Larger (OD > OS)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Toggle to make Green Target larger (OS > OD)', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    value: _redTargetIsLarger,
                    activeThumbColor: Colors.redAccent,
                    onChanged: (val) => setState(() => _redTargetIsLarger = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 3. Anisometropia Optical Correlation Calculator
            SamsungOneUiGroupCard(
              title: 'ANISOMETROPIA PREDICTION CALCULATOR',
              icon: Icons.calculate,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _odPowerCtrl,
                          keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                          decoration: InputDecoration(
                            labelText: 'OD Sph (D)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _osPowerCtrl,
                          keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                          decoration: InputDecoration(
                            labelText: 'OS Sph (D)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade900.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Predicted Spectacle Aniseikonia:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text(
                          '~${predictedAniseikonia.toStringAsFixed(1)}%',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.amberAccent),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 4. Patient Database Export
            SamsungOneUiGroupCard(
              title: 'PATIENT RECORD ENTRY',
              icon: Icons.assignment_ind,
              child: Column(
                children: [
                  TextField(
                    controller: _patientIdCtrl,
                    decoration: InputDecoration(
                      labelText: 'Patient Identifier / MRN',
                      prefixIcon: const Icon(Icons.badge, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _notesCtrl,
                    decoration: InputDecoration(
                      labelText: 'Clinical Notes / Contact Lens Recommendation',
                      prefixIcon: const Icon(Icons.note, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Save Aniseikonia Exam to Database', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _saveToDatabase,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info, color: Colors.cyanAccent),
            SizedBox(width: 8),
            Text('Awaya Aniseikonia Optics'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Clinical Aniseikonia Principles:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.cyanAccent),
              ),
              SizedBox(height: 4),
              Text(
                '• Aniseikonia is a relative difference in the perceived size or shape of the ocular images between the two eyes.\n'
                '• Awaya NAT Test: Red-Green glasses dissociate two complementary half-moon brackets.\n'
                '• Physiological tolerance threshold: Up to 0.75% – 1.5%.\n'
                '• Clinical symptoms (headache, asthenopia, spatial distortion): Typically occur at > 2.0% – 3.0% aniseikonia.\n'
                '• Knapp\'s Law: Axial anisometropia is theoretically corrected with spectacle lenses at the anterior focal point (15 mm); Refractive anisometropia is best corrected with contact lenses to minimize image size disparity.',
                style: TextStyle(fontSize: 11, height: 1.4),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _AwayaBracketsPainter extends CustomPainter {
  final double percentageDiff;
  final AniseikoniaOrientation orientation;
  final bool redIsLarger;

  _AwayaBracketsPainter({
    required this.percentageDiff,
    required this.orientation,
    required this.redIsLarger,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = 60.0;
    final scaleFactor = 1.0 + (percentageDiff / 100.0);

    final double redRadius = redIsLarger ? baseRadius * scaleFactor : baseRadius;
    final double greenRadius = redIsLarger ? baseRadius : baseRadius * scaleFactor;

    final redPaint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.butt;

    final greenPaint = Paint()
      ..color = const Color(0xFF00E676)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.butt;

    if (orientation == AniseikoniaOrientation.horizontal) {
      // Left bracket (Red - OD) vs Right bracket (Green - OS)
      final gap = 12.0;

      // Red Semicircle (Facing right)
      canvas.drawArc(
        Rect.fromCircle(center: Offset(center.dx - gap, center.dy), radius: redRadius),
        pi / 2,
        pi,
        false,
        redPaint,
      );

      // Green Semicircle (Facing left)
      canvas.drawArc(
        Rect.fromCircle(center: Offset(center.dx + gap, center.dy), radius: greenRadius),
        -pi / 2,
        pi,
        false,
        greenPaint,
      );
    } else {
      // Top bracket (Red - OD) vs Bottom bracket (Green - OS)
      final gap = 12.0;

      // Red Semicircle (Facing down)
      canvas.drawArc(
        Rect.fromCircle(center: Offset(center.dx, center.dy - gap), radius: redRadius),
        pi,
        pi,
        false,
        redPaint,
      );

      // Green Semicircle (Facing up)
      canvas.drawArc(
        Rect.fromCircle(center: Offset(center.dx, center.dy + gap), radius: greenRadius),
        0,
        pi,
        false,
        greenPaint,
      );
    }

    // Central white fixation cross
    final whitePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(center.dx - 6, center.dy), Offset(center.dx + 6, center.dy), whitePaint);
    canvas.drawLine(Offset(center.dx, center.dy - 6), Offset(center.dx, center.dy + 6), whitePaint);
  }

  @override
  bool shouldRepaint(covariant _AwayaBracketsPainter oldDelegate) {
    return oldDelegate.percentageDiff != percentageDiff ||
        oldDelegate.orientation != orientation ||
        oldDelegate.redIsLarger != redIsLarger;
  }
}
