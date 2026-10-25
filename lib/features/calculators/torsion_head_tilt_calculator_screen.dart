import 'dart:math';
import 'package:flutter/material.dart';

class TorsionHeadTiltCalculatorScreen extends StatefulWidget {
  const TorsionHeadTiltCalculatorScreen({super.key});

  @override
  State<TorsionHeadTiltCalculatorScreen> createState() => _TorsionHeadTiltCalculatorScreenState();
}

class _TorsionHeadTiltCalculatorScreenState extends State<TorsionHeadTiltCalculatorScreen> {
  // Double Maddox Rod (DMR) subjective torsion values in trial frame
  // Standard: Red Maddox Rod over Right Eye (OD), White over Left Eye (OS)
  // Positive = Excyclotorsion (rotated outward, patient rotates knob inward)
  // Negative = Incyclotorsion
  double _odTorsionDegrees = 0.0;
  double _osTorsionDegrees = 0.0;

  // Bielschowsky Head Tilt Test (BHTT) hypertropia measurements (Δ)
  // Evaluated in: Primary, Tilt Right, Tilt Left
  double _primaryVerticalDelta = 0.0; // Positive = RHT, Negative = LHT
  double _tiltRightVerticalDelta = 0.0;
  double _tiltLeftVerticalDelta = 0.0;

  // Muscle paresis prediction
  String _diagnosis = 'No significant cyclovertical paresis detected';
  String _surgicalGuidance = 'Maintain observational follow-up';

  @override
  void initState() {
    super.initState();
    _analyzeData();
  }

  void _analyzeData() {
    final double totalTorsion = _odTorsionDegrees + _osTorsionDegrees;

    // Check for Bielschowsky head tilt pattern
    // Right Superior Oblique (RSO) palsy classic sign:
    // Right Hypertropia (RHT) increases on RIGHT tilt, decreases on LEFT tilt.
    // Also excyclotorsion OD. If bilateral: V-pattern, total excyclo > 10°-15°, alternating hypertropia.
    bool rsoPattern = (_tiltRightVerticalDelta - _tiltLeftVerticalDelta) >= 6.0 && _tiltRightVerticalDelta > 0;
    bool lsoPattern = (_tiltLeftVerticalDelta - _tiltRightVerticalDelta) >= 6.0 && _tiltLeftVerticalDelta < 0;

    if (totalTorsion >= 10.0) {
      if ((_odTorsionDegrees >= 4.0 && _osTorsionDegrees >= 4.0) ||
          (_tiltRightVerticalDelta > 0 && _tiltLeftVerticalDelta < 0)) {
        _diagnosis = 'Bilateral Superior Oblique (CN IV) Palsy (Symmetric or Asymmetric)';
        _surgicalGuidance =
            'Harada-Ito procedure (advancement & anterior transposition of SO anterior fibers) is the gold standard for subjective excyclotorsion > 10° without large vertical deviation.';
        return;
      }
    }

    if (rsoPattern || (_odTorsionDegrees > 5.0 && _tiltRightVerticalDelta > _tiltLeftVerticalDelta)) {
      _diagnosis = 'Right Superior Oblique (RSO / Right CN IV) Palsy';
      _surgicalGuidance = _odTorsionDegrees > 8.0
          ? 'Consider Harada-Ito procedure or RIO (Inferior Oblique) weakening (myectomy/recession) if IO overaction present.'
          : 'Right IO recession / myectomy if IO overaction, or RSO tuck if tendon laxity is confirmed with forced duction test.';
      return;
    }

    if (lsoPattern || (_osTorsionDegrees > 5.0 && _tiltLeftVerticalDelta < _tiltRightVerticalDelta)) {
      _diagnosis = 'Left Superior Oblique (LSO / Left CN IV) Palsy';
      _surgicalGuidance = _osTorsionDegrees > 8.0
          ? 'Consider Harada-Ito procedure or LIO weakening if IO overaction present.'
          : 'Left IO recession / myectomy if IO overaction, or LSO tuck if tendon laxity is confirmed.';
      return;
    }

    if (totalTorsion.abs() > 4.0) {
      _diagnosis = 'Isolated Cyclotorsion (${totalTorsion > 0 ? "Excyclotorsion" : "Incyclotorsion"}: ${totalTorsion.abs().toStringAsFixed(1)}°)';
      _surgicalGuidance = 'Investigate vestibular ocular skew deviation or subtle oblique muscle dysfunction.';
      return;
    }

    _diagnosis = 'Normal cyclovertical alignment or compensated phoria';
    _surgicalGuidance = 'No surgical intervention indicated.';
  }

  @override
  Widget build(BuildContext context) {
    final double totalTorsion = _odTorsionDegrees + _osTorsionDegrees;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Torsion & Bielschowsky Tilt'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Diagnostic Result Banner
            Card(
              elevation: 2,
              color: Colors.blueGrey.shade900,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.psychology, color: Colors.cyanAccent),
                        SizedBox(width: 8),
                        Text('Diagnostic Assessment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _diagnosis,
                      style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Surgical & Management Strategy:\n$_surgicalGuidance',
                      style: TextStyle(color: Colors.grey.shade300, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Double Maddox Rod Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Double Maddox Rod (DMR) Torsion',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Chip(
                          label: Text(
                            'Total: ${totalTorsion.abs().toStringAsFixed(1)}° ${totalTorsion >= 0 ? "Excyclo" : "Incyclo"}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: totalTorsion > 10 ? Colors.red : Colors.teal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Interactive Double Maddox Rod Visualizer
                    SizedBox(
                      height: 120,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildMaddoxRodDial(eyeName: 'Right Eye (OD - Red)', degrees: _odTorsionDegrees, color: Colors.redAccent),
                          _buildMaddoxRodDial(eyeName: 'Left Eye (OS - White)', degrees: _osTorsionDegrees, color: Colors.blueAccent),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    Text('OD Torsion: ${_odTorsionDegrees.toStringAsFixed(1)}° (${_odTorsionDegrees >= 0 ? "Excyclo" : "Incyclo"})',
                        style: const TextStyle(fontSize: 12)),
                    Slider(
                      value: _odTorsionDegrees,
                      min: -15.0,
                      max: 20.0,
                      divisions: 35,
                      label: '${_odTorsionDegrees.toStringAsFixed(1)}°',
                      onChanged: (val) {
                        setState(() {
                          _odTorsionDegrees = val;
                          _analyzeData();
                        });
                      },
                    ),

                    Text('OS Torsion: ${_osTorsionDegrees.toStringAsFixed(1)}° (${_osTorsionDegrees >= 0 ? "Excyclo" : "Incyclo"})',
                        style: const TextStyle(fontSize: 12)),
                    Slider(
                      value: _osTorsionDegrees,
                      min: -15.0,
                      max: 20.0,
                      divisions: 35,
                      label: '${_osTorsionDegrees.toStringAsFixed(1)}°',
                      onChanged: (val) {
                        setState(() {
                          _osTorsionDegrees = val;
                          _analyzeData();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Bielschowsky Head Tilt Test (BHTT) Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Bielschowsky Head Tilt Test (BHTT)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 6),
                    const Text('Measure vertical deviation in 3 head positions (Positive = RHT, Negative = LHT):',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 14),

                    _buildTiltInputRow(
                      label: 'Head Tilt RIGHT:',
                      value: _tiltRightVerticalDelta,
                      onChanged: (val) {
                        setState(() {
                          _tiltRightVerticalDelta = val;
                          _analyzeData();
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildTiltInputRow(
                      label: 'Primary Gaze (Upright):',
                      value: _primaryVerticalDelta,
                      onChanged: (val) {
                        setState(() {
                          _primaryVerticalDelta = val;
                          _analyzeData();
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildTiltInputRow(
                      label: 'Head Tilt LEFT:',
                      value: _tiltLeftVerticalDelta,
                      onChanged: (val) {
                        setState(() {
                          _tiltLeftVerticalDelta = val;
                          _analyzeData();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTiltInputRow({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    String formattedValue = value == 0
        ? 'Ortho (0Δ)'
        : (value > 0 ? '${value.toInt()}Δ RHT' : '${value.abs().toInt()}Δ LHT');

    return Row(
      children: [
        Expanded(flex: 3, child: Text(label, style: const TextStyle(fontSize: 13))),
        Expanded(
          flex: 4,
          child: Slider(
            value: value,
            min: -25.0,
            max: 25.0,
            divisions: 50,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 70,
          child: Text(
            formattedValue,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildMaddoxRodDial({
    required String eyeName,
    required double degrees,
    required Color color,
  }) {
    return Column(
      children: [
        Text(eyeName, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 8),
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade600, width: 2),
            color: Colors.black,
          ),
          child: CustomPaint(
            painter: _MaddoxStreakPainter(degrees: degrees, color: color),
          ),
        ),
      ],
    );
  }
}

class _MaddoxStreakPainter extends CustomPainter {
  final double degrees;
  final Color color;

  _MaddoxStreakPainter({required this.degrees, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Horizontal reference line
    final refPaint = Paint()
      ..color = Colors.grey.shade800
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(4, center.dy), Offset(size.width - 4, center.dy), refPaint);

    // Tilted Maddox streak
    final rad = degrees * (pi / 180.0);
    final streakPaint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final dx = radius * cos(rad);
    final dy = radius * sin(rad);

    canvas.drawLine(Offset(center.dx - dx, center.dy - dy), Offset(center.dx + dx, center.dy + dy), streakPaint);
  }

  @override
  bool shouldRepaint(covariant _MaddoxStreakPainter oldDelegate) =>
      oldDelegate.degrees != degrees || oldDelegate.color != color;
}
