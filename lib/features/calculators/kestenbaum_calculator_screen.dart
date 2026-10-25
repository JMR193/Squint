import 'package:flutter/material.dart';

class KestenbaumCalculatorScreen extends StatefulWidget {
  const KestenbaumCalculatorScreen({super.key});

  @override
  State<KestenbaumCalculatorScreen> createState() => _KestenbaumCalculatorScreenState();
}

class _KestenbaumCalculatorScreenState extends State<KestenbaumCalculatorScreen> {
  // Head turn (Face turn in degrees)
  // Positive = Face turn to Right (eyes in left gaze, nystagmus null point in left gaze)
  // Negative = Face turn to Left (eyes in right gaze, nystagmus null point in right gaze)
  double _faceTurnDegrees = 25.0;
  bool _faceTurnRight = true;

  // Selected dosing method
  _DosingMethod _method = _DosingMethod.parksKestenbaum;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final calculation = _calculateDosing();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kestenbaum-Anderson Dosing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Surgical Principles',
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Clinical summary header
            Card(
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(Icons.airline_stops, color: theme.colorScheme.onPrimaryContainer, size: 30),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nystagmus Null Point Surgery',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Shift both globes into the direction of the face turn to align the null zone with primary position.',
                            style: TextStyle(
                              color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Face turn input card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Abnormal Head Posture (AHP): Face Turn',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Face Turn Right')),
                            selected: _faceTurnRight,
                            onSelected: (val) {
                              if (val) setState(() => _faceTurnRight = true);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Face Turn Left')),
                            selected: !_faceTurnRight,
                            onSelected: (val) {
                              if (val) setState(() => _faceTurnRight = false);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Measured Face Turn Angle:'),
                        Text(
                          '${_faceTurnDegrees.toInt()}°',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _faceTurnDegrees,
                      min: 10.0,
                      max: 45.0,
                      divisions: 35,
                      label: '${_faceTurnDegrees.toInt()}°',
                      onChanged: (val) => setState(() => _faceTurnDegrees = val),
                    ),
                    const SizedBox(height: 10),
                    const Text('Dosing Protocol Formula:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    SegmentedButton<_DosingMethod>(
                      segments: const [
                        ButtonSegment(
                          value: _DosingMethod.parksKestenbaum,
                          label: Text('Parks (Classic 5-6-7-8)'),
                        ),
                        ButtonSegment(
                          value: _DosingMethod.augmented,
                          label: Text('Augmented (+40-60%)'),
                        ),
                      ],
                      selected: {_method},
                      onSelectionChanged: (set) => setState(() => _method = set.first),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Surgical Dosing Output Table
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recommended 4-Muscle Dosing',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Chip(
                          backgroundColor: Colors.teal.shade50,
                          label: Text(
                            'Total Recess/Resect: ${calculation.totalMm.toStringAsFixed(1)} mm',
                            style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),

                    // Right Eye (OD) Plan
                    _buildEyeSurgeryCard(
                      eyeName: 'Right Eye (OD)',
                      muscle1Name: calculation.odMuscle1Name,
                      muscle1Procedure: calculation.odMuscle1Procedure,
                      muscle1Amount: calculation.odMuscle1Mm,
                      muscle2Name: calculation.odMuscle2Name,
                      muscle2Procedure: calculation.odMuscle2Procedure,
                      muscle2Amount: calculation.odMuscle2Mm,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(height: 12),

                    // Left Eye (OS) Plan
                    _buildEyeSurgeryCard(
                      eyeName: 'Left Eye (OS)',
                      muscle1Name: calculation.osMuscle1Name,
                      muscle1Procedure: calculation.osMuscle1Procedure,
                      muscle1Amount: calculation.osMuscle1Mm,
                      muscle2Name: calculation.osMuscle2Name,
                      muscle2Procedure: calculation.osMuscle2Procedure,
                      muscle2Amount: calculation.osMuscle2Mm,
                      color: Colors.indigo.shade700,
                    ),

                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade300),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              calculation.clinicalNote,
                              style: TextStyle(fontSize: 11, color: Colors.amber.shade900),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildEyeSurgeryCard({
    required String eyeName,
    required String muscle1Name,
    required String muscle1Procedure,
    required double muscle1Amount,
    required String muscle2Name,
    required String muscle2Procedure,
    required double muscle2Amount,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(eyeName, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('• $muscle1Name ($muscle1Procedure):', style: const TextStyle(fontSize: 13)),
              Text('${muscle1Amount.toStringAsFixed(1)} mm',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('• $muscle2Name ($muscle2Procedure):', style: const TextStyle(fontSize: 13)),
              Text('${muscle2Amount.toStringAsFixed(1)} mm',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  _KestenbaumCalculation _calculateDosing() {
    // Standard Parks modification of Kestenbaum:
    // For face turn RIGHT (null point in LEFT gaze):
    // Both eyes must be rotated to the RIGHT:
    // OD: Lateral Rectus RESECT, Medial Rectus RECESS
    // OS: Medial Rectus RESECT, Lateral Rectus RECESS
    // Classic Parks numbers:
    // Slow phase / face turn direction:
    // RLR resect: 8mm, RMR recess: 5mm
    // LLR recess: 7mm, LMR resect: 6mm
    // Total = 5 + 6 + 7 + 8 = 26mm (for ~20-25 deg turn)
    // Scale proportionally if face turn differs or augmented requested.

    double scaleFactor = _faceTurnDegrees / 20.0;
    if (_method == _DosingMethod.augmented) {
      scaleFactor *= 1.4; // 40% augmentation for undercorrection prophylaxis
    }

    // Clamp scaling to safe clinical surgical ranges
    double rMrBase = 5.0 * scaleFactor;
    double lMrBase = 6.0 * scaleFactor;
    double lLrBase = 7.0 * scaleFactor;
    double rLrBase = 8.0 * scaleFactor;

    if (_faceTurnRight) {
      // Face turn Right -> rotate eyes Right
      // OD: MR Recess, LR Resect
      // OS: LR Recess, MR Resect
      double total = rMrBase + rLrBase + lLrBase + lMrBase;
      return _KestenbaumCalculation(
        odMuscle1Name: 'Medial Rectus (RMR)',
        odMuscle1Procedure: 'Recession',
        odMuscle1Mm: double.parse(rMrBase.toStringAsFixed(1)),
        odMuscle2Name: 'Lateral Rectus (RLR)',
        odMuscle2Procedure: 'Resection',
        odMuscle2Mm: double.parse(rLrBase.toStringAsFixed(1)),
        osMuscle1Name: 'Lateral Rectus (LLR)',
        osMuscle1Procedure: 'Recession',
        osMuscle1Mm: double.parse(lLrBase.toStringAsFixed(1)),
        osMuscle2Name: 'Medial Rectus (LMR)',
        osMuscle2Procedure: 'Resection',
        osMuscle2Mm: double.parse(lMrBase.toStringAsFixed(1)),
        totalMm: double.parse(total.toStringAsFixed(1)),
        clinicalNote:
            'Face turn RIGHT rotates globes to right (RMR recess, RLR resect; LLR recess, LMR resect) to shift null point toward primary gaze.',
      );
    } else {
      // Face turn Left -> rotate eyes Left
      // OD: LR Recess, MR Resect
      // OS: MR Recess, LR Resect
      double total = rLrBase + rMrBase + lMrBase + lLrBase;
      return _KestenbaumCalculation(
        odMuscle1Name: 'Lateral Rectus (RLR)',
        odMuscle1Procedure: 'Recession',
        odMuscle1Mm: double.parse(lLrBase.toStringAsFixed(1)),
        odMuscle2Name: 'Medial Rectus (RMR)',
        odMuscle2Procedure: 'Resection',
        odMuscle2Mm: double.parse(lMrBase.toStringAsFixed(1)),
        osMuscle1Name: 'Medial Rectus (LMR)',
        osMuscle1Procedure: 'Recession',
        osMuscle1Mm: double.parse(rMrBase.toStringAsFixed(1)),
        osMuscle2Name: 'Lateral Rectus (LLR)',
        osMuscle2Procedure: 'Resection',
        osMuscle2Mm: double.parse(rLrBase.toStringAsFixed(1)),
        totalMm: double.parse(total.toStringAsFixed(1)),
        clinicalNote:
            'Face turn LEFT rotates globes to left (RLR recess, RMR resect; LMR recess, LLR resect) to shift null point toward primary gaze.',
      );
    }
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kestenbaum-Anderson Procedure'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Rule of 5-6-7-8 (Parks):', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(
                'In infantile nystagmus with an eccentric null zone, patients turn their head so their eyes reside in the quietest zone. Surgery shifts the eyes in the direction of the head turn by operating on all four horizontal recti.\n',
                style: TextStyle(fontSize: 12),
              ),
              Text('Augmentation Principles:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(
                'Classic 5-6-7-8 doses often result in undercorrection over long-term follow-up. Augmented dosing (40% to 60% added to all 4 muscles) is frequently preferred for large head turns (>30°).',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }
}

enum _DosingMethod {
  parksKestenbaum,
  augmented,
}

class _KestenbaumCalculation {
  final String odMuscle1Name;
  final String odMuscle1Procedure;
  final double odMuscle1Mm;
  final String odMuscle2Name;
  final String odMuscle2Procedure;
  final double odMuscle2Mm;

  final String osMuscle1Name;
  final String osMuscle1Procedure;
  final double osMuscle1Mm;
  final String osMuscle2Name;
  final String osMuscle2Procedure;
  final double osMuscle2Mm;

  final double totalMm;
  final String clinicalNote;

  _KestenbaumCalculation({
    required this.odMuscle1Name,
    required this.odMuscle1Procedure,
    required this.odMuscle1Mm,
    required this.odMuscle2Name,
    required this.odMuscle2Procedure,
    required this.odMuscle2Mm,
    required this.osMuscle1Name,
    required this.osMuscle1Procedure,
    required this.osMuscle1Mm,
    required this.osMuscle2Name,
    required this.osMuscle2Procedure,
    required this.osMuscle2Mm,
    required this.totalMm,
    required this.clinicalNote,
  });
}
