import 'dart:math';
import 'package:flutter/material.dart';

enum ProcedureType {
  recessionResection('Recession-Resection (R&R)'),
  bilateralRecession('Bilateral Medial Rectus Recession (BMR)'),
  bilateralResection('Bilateral Lateral Rectus Resection (BLR)');

  final String title;
  const ProcedureType(this.title);
}

class SurgicalBiomechanicsScreen extends StatefulWidget {
  const SurgicalBiomechanicsScreen({super.key});

  @override
  State<SurgicalBiomechanicsScreen> createState() => _SurgicalBiomechanicsScreenState();
}

class _SurgicalBiomechanicsScreenState extends State<SurgicalBiomechanicsScreen> {
  ProcedureType _procedure = ProcedureType.recessionResection;
  double _preOpDeviation = 35.0; // Prism Diopters (Esotropia = +; Exotropia = -)
  bool _isEsotropia = true;

  // Surgical Dosing in Millimeters (mm)
  double _mrRecession = 5.0; // mm
  double _lrResection = 6.0; // mm
  bool _useAdjustableSuture = false;

  // Biomechanical Calculations (based on Orbit™ and SEE++ models)
  // 1mm MR recession corrects ~3.2Δ
  // 1mm LR resection corrects ~2.2Δ
  double get _mrCorrection => _mrRecession * 3.2;
  double get _lrCorrection => _lrResection * 2.2;
  double get _totalCorrection => _mrCorrection + _lrCorrection;
  double get _postOpDeviation => _preOpDeviation - _totalCorrection;

  // Arc of Contact changes (Normal MR arc of contact ~6.3mm)
  double get _postOpArcOfContact => max(0.0, 6.3 - _mrRecession);

  String get _surgicalOutcomeAlert {
    if (_postOpDeviation.abs() <= 5.0) {
      return 'Target Alignment Achieved: Post-op residual ${_postOpDeviation.abs().toStringAsFixed(1)}Δ (Orthotropic range within ±5Δ).';
    } else if (_postOpDeviation > 5.0) {
      return 'Undercorrection Risk: Residual esotropia of ${_postOpDeviation.toStringAsFixed(1)}Δ. Consider increasing LR resection or adding bilateral MR recession.';
    } else {
      return 'Overcorrection Warning: Consecutive exotropia of ${_postOpDeviation.abs().toStringAsFixed(1)}Δ. High risk of diplopia!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biomechanical Surgical Simulator'),
      ),
      body: Column(
        children: [
          // Pre-Op Target Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pre-Op Deviation: ${_preOpDeviation.toInt()}Δ ${_isEsotropia ? "Esotropia" : "Exotropia"}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Slider(
                        value: _preOpDeviation,
                        min: 10,
                        max: 70,
                        divisions: 60,
                        label: '${_preOpDeviation.toInt()}Δ',
                        onChanged: (v) => setState(() => _preOpDeviation = v),
                      ),
                      DropdownButton<ProcedureType>(
                        isDense: true,
                        value: _procedure,
                        items: ProcedureType.values.map((p) {
                          return DropdownMenuItem(value: p, child: Text(p.title, style: const TextStyle(fontSize: 12)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _procedure = val);
                        },
                      ),
                    ],
                  ),
                ),
                ChoiceChip(
                  label: Text(_isEsotropia ? 'ET (Eso)' : 'XT (Exo)'),
                  selected: true,
                  onSelected: (_) => setState(() => _isEsotropia = !_isEsotropia),
                ),
              ],
            ),
          ),
          // Biomechanical 3D Eyeball & Caliper Canvas
          Expanded(
            child: Container(
              color: const Color(0xFF0F172A), // Surgical midnight blue
              child: CustomPaint(
                size: Size.infinite,
                painter: BiomechanicalSurgicalPainter(
                  mrRecession: _mrRecession,
                  lrResection: _lrResection,
                  arcOfContact: _postOpArcOfContact,
                  postOpDev: _postOpDeviation,
                ),
              ),
            ),
          ),
          // Surgical Calipers & Dosages Panel
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
                          Text('Medial Rectus Recession: ${_mrRecession.toStringAsFixed(1)} mm', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Slider(
                            value: _mrRecession,
                            min: 0.0,
                            max: 8.0,
                            divisions: 16,
                            label: '${_mrRecession.toStringAsFixed(1)} mm',
                            onChanged: (v) => setState(() => _mrRecession = v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Lateral Rectus Resection: ${_lrResection.toStringAsFixed(1)} mm', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Slider(
                            value: _lrResection,
                            min: 0.0,
                            max: 9.0,
                            divisions: 18,
                            label: '${_lrResection.toStringAsFixed(1)} mm',
                            onChanged: (v) => setState(() => _lrResection = v),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Arc of Contact: ${_postOpArcOfContact.toStringAsFixed(1)} mm (Norm: 6.3mm)', style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
                    FilterChip(
                      label: const Text('Adjustable Suture'),
                      selected: _useAdjustableSuture,
                      onSelected: (v) => setState(() => _useAdjustableSuture = v),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Outcome Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _postOpDeviation.abs() <= 5.0 ? Colors.green.shade50 : Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _postOpDeviation.abs() <= 5.0 ? Colors.green : Colors.amber),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Correction: ${_totalCorrection.toStringAsFixed(1)}Δ',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            'Post-Op Residual: ${_postOpDeviation.abs().toStringAsFixed(1)}Δ ${_postOpDeviation >= 0 ? "Eso" : "Exo"}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: _postOpDeviation.abs() <= 5.0 ? Colors.green.shade800 : Colors.deepOrange.shade900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _surgicalOutcomeAlert,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade900),
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
}

class BiomechanicalSurgicalPainter extends CustomPainter {
  final double mrRecession;
  final double lrResection;
  final double arcOfContact;
  final double postOpDev;

  BiomechanicalSurgicalPainter({
    required this.mrRecession,
    required this.lrResection,
    required this.arcOfContact,
    required this.postOpDev,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final globeRadius = min(size.width, size.height) * 0.32;

    // 1. Draw Scleral Eyeball Globe (Axial View from Above)
    final scleraPaint = Paint()..color = const Color(0xFFF8FAFC);
    canvas.drawCircle(center, globeRadius, scleraPaint);

    // Limbus & Cornea at top
    final corneaCenter = center - Offset(0, globeRadius * 0.95);
    final corneaPaint = Paint()
      ..color = const Color(0xFF0284C7).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(corneaCenter, globeRadius * 0.4, corneaPaint);

    final pupilPaint = Paint()..color = Colors.black;
    canvas.drawCircle(corneaCenter, globeRadius * 0.15, pupilPaint);

    // 2. Draw Original Insertions (Spiral of Tillaux)
    // MR: Left side (5.5 mm from limbus), LR: Right side (6.9 mm from limbus)
    final originalMrInsertion = center + Offset(-globeRadius * 0.9, -globeRadius * 0.2);
    final originalLrInsertion = center + Offset(globeRadius * 0.9, -globeRadius * 0.1);

    final originalPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Dotted original insertion lines
    canvas.drawLine(originalMrInsertion - const Offset(0, 10), originalMrInsertion + const Offset(0, 10), originalPaint);
    canvas.drawLine(originalLrInsertion - const Offset(0, 10), originalLrInsertion + const Offset(0, 10), originalPaint);

    // 3. Draw Recessed Medial Rectus
    // Recessed posterior by mrRecession * scale
    final mrShift = mrRecession * 4.5;
    final newMrInsertion = originalMrInsertion + Offset(0, mrShift);

    final musclePaint = Paint()
      ..color = const Color(0xFFE11D48)
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    final tendonPaint = Paint()
      ..color = const Color(0xFFFDE047)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    // MR Muscle Belly coming from Annulus of Zinn (apex posterior)
    final apex = center + Offset(0, globeRadius * 1.5);
    canvas.drawLine(apex - const Offset(20, 0), newMrInsertion, musclePaint);
    canvas.drawLine(newMrInsertion - const Offset(0, 6), newMrInsertion, tendonPaint);

    // Caliper measurement indicator for Recession
    final caliperPaint = Paint()
      ..color = Colors.cyanAccent
      ..strokeWidth = 1.5;
    canvas.drawLine(originalMrInsertion, newMrInsertion, caliperPaint);

    // 4. Draw Resected Lateral Rectus
    final lrShift = lrResection * 4.5;
    final newLrInsertion = originalLrInsertion - Offset(0, lrShift * 0.2); // Advanced/tightened anteriorly
    canvas.drawLine(apex + const Offset(20, 0), newLrInsertion, musclePaint);
    canvas.drawLine(newLrInsertion - const Offset(0, 6), newLrInsertion, tendonPaint);

    // 5. Labels & Anatomical Annotations
    const textStyle = TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold);
    _drawText(canvas, 'Anterior (Cornea)', corneaCenter - const Offset(45, 30), textStyle);
    _drawText(canvas, 'MR Recessed: ${mrRecession.toStringAsFixed(1)}mm', newMrInsertion + const Offset(-120, -6), const TextStyle(color: Colors.cyanAccent, fontSize: 11, fontWeight: FontWeight.bold));
    _drawText(canvas, 'LR Resected: ${lrResection.toStringAsFixed(1)}mm', newLrInsertion + const Offset(15, -6), const TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.bold));
    _drawText(canvas, 'Apex (Annulus of Zinn)', apex + const Offset(-60, 10), textStyle);

    // Vector Force Arc of Contact Curve
    final arcPaint = Paint()
      ..color = Colors.purpleAccent.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final arcRect = Rect.fromCircle(center: center, radius: globeRadius + 2);
    canvas.drawArc(arcRect, pi * 0.8, (arcOfContact / 6.3) * 0.6, false, arcPaint);
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final tp = TextPainter(text: TextSpan(text: text, style: style), textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant BiomechanicalSurgicalPainter oldDelegate) => true;
}
