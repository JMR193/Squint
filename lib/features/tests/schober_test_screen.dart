import 'package:flutter/material.dart';
import '../../core/services/clinical_database_service.dart';
import '../../core/widgets/custom_ui_components.dart';

class SchoberTestScreen extends StatefulWidget {
  const SchoberTestScreen({super.key});

  @override
  State<SchoberTestScreen> createState() => _SchoberTestScreenState();
}

class _SchoberTestScreenState extends State<SchoberTestScreen> {
  double _horizontalShiftDelta = 0.0; // Prism diopters: -25Δ (Exo) to +25Δ (Eso)
  double _verticalShiftDelta = 0.0;   // Prism diopters: -15Δ (Hypo) to +15Δ (Hyper)
  bool _isFreeDragMode = true;
  final double _testDistanceMeters = 1.0;   // 1.0m standard (or 0.33m / 6.0m)

  final TextEditingController _patientIdCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _patientIdCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _resetAlignment() {
    setState(() {
      _horizontalShiftDelta = 0.0;
      _verticalShiftDelta = 0.0;
    });
  }

  String _getDeviationSummary() {
    String hText = 'Orthophoria';
    if (_horizontalShiftDelta > 0.5) {
      hText = '${_horizontalShiftDelta.toStringAsFixed(1)}Δ Esophoria (Uncrossed)';
    } else if (_horizontalShiftDelta < -0.5) {
      hText = '${(-_horizontalShiftDelta).toStringAsFixed(1)}Δ Exophoria (Crossed)';
    }

    String vText = 'No Vertical Phoria';
    if (_verticalShiftDelta > 0.5) {
      vText = '${_verticalShiftDelta.toStringAsFixed(1)}Δ R. Hyperphoria';
    } else if (_verticalShiftDelta < -0.5) {
      vText = '${(-_verticalShiftDelta).toStringAsFixed(1)}Δ R. Hypophoria';
    }

    return '$hText | $vText';
  }

  void _saveToDatabase() async {
    final devSummary = _getDeviationSummary();
    final record = PatientRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientName: _patientIdCtrl.text.trim().isEmpty ? 'Anonymous Patient' : _patientIdCtrl.text.trim(),
      age: 25,
      gender: 'Unspecified',
      primaryDiagnosis: (_horizontalShiftDelta.abs() > 0.5 || _verticalShiftDelta.abs() > 0.5)
          ? 'Heterophoria / Strabismus Deviation'
          : 'Orthophoria (Harmonious Binocular Alignment)',
      distanceDeviationPd: _horizontalShiftDelta.abs(),
      distanceDeviationType: _horizontalShiftDelta > 0.5 ? 'ET' : (_horizontalShiftDelta < -0.5 ? 'XT' : 'Ortho'),
      notes: 'Schober Test (${_testDistanceMeters}m). Alignment: $devSummary. Notes: ${_notesCtrl.text.trim()}',
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
              Expanded(child: Text('Schober Test saved: $devSummary')),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schober Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.replay),
            tooltip: 'Reset Center',
            onPressed: _resetAlignment,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Principles',
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
                color: Colors.greenAccent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.4)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.visibility, color: Colors.greenAccent, size: 22),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Wear Red-Green Glasses (Red OD, Green OS). Drag or use sliders until the patient perceives the Red Cross centered inside the Green Rings.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 1. Interactive Schober Optical Canvas (Distortion-Free 1:1 Aspect Ratio)
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340, maxHeight: 340),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: GestureDetector(
                        onPanUpdate: _isFreeDragMode
                            ? (details) {
                                setState(() {
                                  // Convert touch delta to prism diopters
                                  _horizontalShiftDelta += details.delta.dx * 0.15;
                                  _verticalShiftDelta -= details.delta.dy * 0.15; // Invert for cartesian up
                                  _horizontalShiftDelta = _horizontalShiftDelta.clamp(-30.0, 30.0);
                                  _verticalShiftDelta = _verticalShiftDelta.clamp(-20.0, 20.0);
                                });
                              }
                            : null,
                        child: CustomPaint(
                          painter: _SchoberCanvasPainter(
                            horizontalDelta: _horizontalShiftDelta,
                            verticalDelta: _verticalShiftDelta,
                            distanceMeters: _testDistanceMeters,
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                bottom: 12,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.75),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.4)),
                                  ),
                                  child: Text(
                                    _getDeviationSummary(),
                                    style: const TextStyle(color: Colors.cyanAccent, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // 2. Prism Sliders & Fine Controls
            SamsungOneUiGroupCard(
              title: 'PRISM SHIFT & NEUTRALIZATION SLIDERS',
              icon: Icons.tune,
              child: Column(
                children: [
                  // Horizontal Slider
                  Row(
                    children: [
                      const Icon(Icons.swap_horiz, size: 16, color: Colors.cyanAccent),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 90,
                        child: Text(
                          _horizontalShiftDelta >= 0 ? '+${_horizontalShiftDelta.toStringAsFixed(1)}Δ Eso' : '${_horizontalShiftDelta.toStringAsFixed(1)}Δ Exo',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          value: _horizontalShiftDelta,
                          min: -30.0,
                          max: 30.0,
                          divisions: 120,
                          activeColor: Colors.cyanAccent,
                          onChanged: (v) => setState(() => _horizontalShiftDelta = v),
                        ),
                      ),
                    ],
                  ),
                  // Vertical Slider
                  Row(
                    children: [
                      const Icon(Icons.swap_vert, size: 16, color: Colors.amberAccent),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 90,
                        child: Text(
                          _verticalShiftDelta >= 0 ? '+${_verticalShiftDelta.toStringAsFixed(1)}Δ R.Hyp' : '${_verticalShiftDelta.toStringAsFixed(1)}Δ R.Hypo',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          value: _verticalShiftDelta,
                          min: -20.0,
                          max: 20.0,
                          divisions: 80,
                          activeColor: Colors.amberAccent,
                          onChanged: (v) => setState(() => _verticalShiftDelta = v),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('Drag Canvas Mode', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          Switch(
                            value: _isFreeDragMode,
                            activeThumbColor: Colors.cyanAccent,
                            onChanged: (v) => setState(() => _isFreeDragMode = v),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.center_focus_strong, size: 14),
                        label: const Text('0Δ Ortho', style: TextStyle(fontSize: 11)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey.shade800,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _resetAlignment,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 3. Clinical Patient Record Entry
            SamsungOneUiGroupCard(
              title: 'PATIENT DATA & CLINICAL EXAM',
              icon: Icons.assignment,
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
                      labelText: 'Clinical Notes / Associated Phoria',
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
                      label: const Text('Save Schober Result to Database', style: TextStyle(fontWeight: FontWeight.bold)),
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
            Icon(Icons.info, color: Colors.greenAccent),
            SizedBox(width: 8),
            Text('Schober Test Optics'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Clinical Setup & Diagnostics:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.greenAccent),
              ),
              SizedBox(height: 4),
              Text(
                '• Target: Two concentric green rings (1° and 2° visual angle) with a central red cross.\n'
                '• Red filter (OD): Sees only the Red Cross.\n'
                '• Green filter (OS): Sees only the Green Rings.\n'
                '• Orthophoria: Cross rests perfectly concentric in center.\n'
                '• Uncrossed displacement (Cross on Right): Esophoria / Esotropia.\n'
                '• Crossed displacement (Cross on Left): Exophoria / Exotropia.\n'
                '• Vertical shift: Measures hyperphoria / hypophoria in prism diopters (Δ).',
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

class _SchoberCanvasPainter extends CustomPainter {
  final double horizontalDelta;
  final double verticalDelta;
  final double distanceMeters;

  _SchoberCanvasPainter({
    required this.horizontalDelta,
    required this.verticalDelta,
    required this.distanceMeters,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = size.width / 320.0;

    // 1. Draw Background Grid (Subtle)
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 1.0;
    for (double x = 0; x < size.width; x += 20 * scale) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 20 * scale) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 2. Draw Concentric Green Rings (OS Target)
    final ringPaint = Paint()
      ..color = const Color(0xFF00E676)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5 * scale;

    final outerRingRadius = 75.0 * scale;
    final innerRingRadius = 40.0 * scale;

    // Outer Ring
    canvas.drawCircle(center, outerRingRadius, ringPaint);
    // Inner Ring
    canvas.drawCircle(center, innerRingRadius, ringPaint);

    // Subtle Green Glow
    final glowPaint = Paint()
      ..color = const Color(0xFF00E676).withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0 * scale
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(center, outerRingRadius, glowPaint);
    canvas.drawCircle(center, innerRingRadius, glowPaint);

    // 3. Draw Red Cross (OD Target with displacement)
    // 1Δ = ~3.5 pixels on canvas
    final pixelsPerDelta = 3.8 * scale;
    final crossCenter = Offset(
      center.dx + (horizontalDelta * pixelsPerDelta),
      center.dy - (verticalDelta * pixelsPerDelta), // Invert for cartesian up
    );

    final crossPaint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0 * scale
      ..strokeCap = StrokeCap.round;

    final crossArm = 24.0 * scale;
    // Horizontal crossbar
    canvas.drawLine(
      Offset(crossCenter.dx - crossArm, crossCenter.dy),
      Offset(crossCenter.dx + crossArm, crossCenter.dy),
      crossPaint,
    );
    // Vertical crossbar
    canvas.drawLine(
      Offset(crossCenter.dx, crossCenter.dy - crossArm),
      Offset(crossCenter.dx, crossCenter.dy + crossArm),
      crossPaint,
    );

    // Red Cross Glow
    final redGlow = Paint()
      ..color = Colors.redAccent.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0 * scale
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawLine(
      Offset(crossCenter.dx - crossArm, crossCenter.dy),
      Offset(crossCenter.dx + crossArm, crossCenter.dy),
      redGlow,
    );
    canvas.drawLine(
      Offset(crossCenter.dx, crossCenter.dy - crossArm),
      Offset(crossCenter.dx, crossCenter.dy + crossArm),
      redGlow,
    );
  }

  @override
  bool shouldRepaint(covariant _SchoberCanvasPainter oldDelegate) {
    return oldDelegate.horizontalDelta != horizontalDelta ||
        oldDelegate.verticalDelta != verticalDelta ||
        oldDelegate.distanceMeters != distanceMeters;
  }
}
