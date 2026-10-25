import 'package:flutter/material.dart';

class PrismAdaptationScreen extends StatefulWidget {
  const PrismAdaptationScreen({super.key});

  @override
  State<PrismAdaptationScreen> createState() => _PrismAdaptationScreenState();
}

class _PrismAdaptationScreenState extends State<PrismAdaptationScreen> {
  // Baseline simultaneous prism and cover test (SPCT) & alternating prism cover test (APCT)
  double _baselineDistanceDelta = 25.0; // Prism Diopters (Base Out for ET)
  double _baselineNearDelta = 30.0;

  // Prism Adaptation Trial Parameters
  // Patient is fitted with Fresnel press-on prism neutralizing full angle
  double _fresnelPrismPower = 25.0;
  int _wearDurationDays = 7; // Usually 3-7 days or 1-2 hours in office

  // Post-adaptation measurement
  double _adaptedAngleWithPrism = 8.0; // Residual esotropia through the prism

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final calculation = _computePatRecommendation();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prism Adaptation Test (PAT)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'PAT Trial Protocol',
            onPressed: _showProtocolInfo,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Clinical Overview
            Card(
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(Icons.layers, color: theme.colorScheme.onPrimaryContainer, size: 30),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Prism Adaptation Protocol (PATS / ET Study)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Identifies anomalous fusional convergence ("prism eaters") to prevent postoperative esotropia undercorrection.',
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

            // Step 1: Baseline Measurements
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Step 1: Baseline Pre-Operative Angle',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Baseline Distance ET (Δ):'),
                        Text('${_baselineDistanceDelta.toInt()}Δ Base-Out',
                            style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                      ],
                    ),
                    Slider(
                      value: _baselineDistanceDelta,
                      min: 10,
                      max: 60,
                      divisions: 50,
                      label: '${_baselineDistanceDelta.toInt()}Δ',
                      onChanged: (val) {
                        setState(() {
                          _baselineDistanceDelta = val;
                          _fresnelPrismPower = val; // auto update fresnel
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Baseline Near ET (Δ):'),
                        Text('${_baselineNearDelta.toInt()}Δ Base-Out',
                            style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                      ],
                    ),
                    Slider(
                      value: _baselineNearDelta,
                      min: 10,
                      max: 65,
                      divisions: 55,
                      label: '${_baselineNearDelta.toInt()}Δ',
                      onChanged: (val) => setState(() => _baselineNearDelta = val),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Step 2: Fresnel Prism Adaptation Trial
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Step 2: Trial with Fresnel Membrane Prism',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Fitted Fresnel Prism Power:'),
                        Text('${_fresnelPrismPower.toInt()}Δ Base-Out',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Slider(
                      value: _fresnelPrismPower,
                      min: 10,
                      max: 60,
                      divisions: 50,
                      onChanged: (val) => setState(() => _fresnelPrismPower = val),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Wear Duration:'),
                        Text('$_wearDurationDays days', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Slider(
                      value: _wearDurationDays.toDouble(),
                      min: 1,
                      max: 14,
                      divisions: 13,
                      onChanged: (val) => setState(() => _wearDurationDays = val.toInt()),
                    ),
                    const Divider(height: 20),
                    const Text('Follow-up Measurement through Prism:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Residual ET through Prism:'),
                        Text('${_adaptedAngleWithPrism.toInt()}Δ Base-Out',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                      ],
                    ),
                    Slider(
                      value: _adaptedAngleWithPrism,
                      min: 0,
                      max: 25,
                      divisions: 25,
                      onChanged: (val) => setState(() => _adaptedAngleWithPrism = val),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Step 3: Surgical Target Recommendation
            Card(
              elevation: 3,
              color: Colors.grey.shade900,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          calculation.isPrismAdapter ? Icons.trending_up : Icons.check_circle,
                          color: calculation.isPrismAdapter ? Colors.amberAccent : Colors.greenAccent,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          calculation.categoryTitle,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Target Surgical Angle: ${calculation.targetSurgicalAngle.toInt()}Δ Base-Out',
                              style: const TextStyle(
                                  color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text('Baseline vs Adapted Difference: +${calculation.adaptedIncrease.toInt()}Δ',
                              style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      calculation.surgicalPlanText,
                      style: TextStyle(color: Colors.grey.shade300, fontSize: 12),
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

  _PatResult _computePatRecommendation() {
    double totalAdaptedAngle = _fresnelPrismPower + _adaptedAngleWithPrism;
    double difference = totalAdaptedAngle - _baselineDistanceDelta;

    if (_adaptedAngleWithPrism >= 4.0) {
      // Prism Eater / Responder
      return _PatResult(
        isPrismAdapter: true,
        categoryTitle: 'PAT Positive ("Prism Eater / Adapter")',
        targetSurgicalAngle: totalAdaptedAngle,
        adaptedIncrease: difference,
        surgicalPlanText:
            'PAT Positive finding: Target surgery for the ADAPTED angle (${totalAdaptedAngle.toInt()}Δ) rather than the baseline (${_baselineDistanceDelta.toInt()}Δ). Operating solely on the baseline angle carries a 65% risk of undercorrection due to motor fusion spasm.',
      );
    } else {
      // Stable responder / Non-adapter
      return _PatResult(
        isPrismAdapter: false,
        categoryTitle: 'PAT Negative (Stable Binocular Alignment)',
        targetSurgicalAngle: _baselineDistanceDelta,
        adaptedIncrease: 0.0,
        surgicalPlanText:
            'PAT Negative finding: The angle remained stable through prism neutralization. Dose surgery for the initial baseline angle (${_baselineDistanceDelta.toInt()}Δ). Excellent motor prognosis with standard recession-resection.',
      );
    }
  }

  void _showProtocolInfo() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Prism Adaptation Test Protocol'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('PATS Study (Prism Adaptation Study):', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(
                'Patients with acquired esotropia frequently harbor latent deviation held in check by anomalous retinal correspondence or vergence adaptation. When neutralized with base-out prism, true total deviation unmasks ("prism eating").\n',
                style: TextStyle(fontSize: 12),
              ),
              Text('Clinical Decision Tree:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(
                '• If residual esotropia reappears: Increase prism by +5Δ to +10Δ until motor fusion (ortho or slight exophoria) is attained.\n'
                '• Dose surgery for the maximum adapted prism angle to achieve a significantly higher success rate (>88% vs 66%).',
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

class _PatResult {
  final bool isPrismAdapter;
  final String categoryTitle;
  final double targetSurgicalAngle;
  final double adaptedIncrease;
  final String surgicalPlanText;

  _PatResult({
    required this.isPrismAdapter,
    required this.categoryTitle,
    required this.targetSurgicalAngle,
    required this.adaptedIncrease,
    required this.surgicalPlanText,
  });
}
