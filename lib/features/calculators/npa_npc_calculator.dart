import 'package:flutter/material.dart';

class NpaNpcCalculatorScreen extends StatefulWidget {
  const NpaNpcCalculatorScreen({super.key});

  @override
  State<NpaNpcCalculatorScreen> createState() => _NpaNpcCalculatorScreenState();
}

class _NpaNpcCalculatorScreenState extends State<NpaNpcCalculatorScreen> {
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _npaController = TextEditingController();
  final TextEditingController _npcBreakController = TextEditingController();
  final TextEditingController _npcRecoveryController = TextEditingController();
  
  String _npaResult = '';
  String _npcResult = '';

  void _calculateNPA() {
    final int? age = int.tryParse(_ageController.text);
    final double? measuredNpaCm = double.tryParse(_npaController.text);

    if (age == null || age <= 0) {
      setState(() => _npaResult = 'Please enter a valid age.');
      return;
    }

    // Hofstetter's formulas for Amplitude of Accommodation (Diopters)
    final double minAmp = 15.0 - (0.25 * age);
    final double avgAmp = 18.5 - (0.30 * age);
    
    // Convert Amplitude (D) to near point distance (cm) = 100 / D
    final double expectedMaxDistance = minAmp > 0 ? 100 / minAmp : double.infinity;
    final double expectedAvgDistance = avgAmp > 0 ? 100 / avgAmp : double.infinity;

    String analysis = '';
    if (measuredNpaCm != null) {
      final double measuredAmp = 100 / measuredNpaCm;
      if (measuredAmp < minAmp) {
        analysis = '\n\nDiagnosis: Accommodative Insufficiency (Below minimum for age).';
      } else {
        analysis = '\n\nDiagnosis: Normal accommodation for age.';
      }
    }

    setState(() {
      _npaResult = 'Expected Minimum Amplitude: ${minAmp.toStringAsFixed(2)} D (approx. ${expectedMaxDistance.toStringAsFixed(1)} cm)\n'
          'Expected Average Amplitude: ${avgAmp.toStringAsFixed(2)} D (approx. ${expectedAvgDistance.toStringAsFixed(1)} cm)$analysis';
    });
  }

  void _calculateNPC() {
    final double? breakCm = double.tryParse(_npcBreakController.text);
    final double? recoveryCm = double.tryParse(_npcRecoveryController.text);

    if (breakCm == null) {
      setState(() => _npcResult = 'Please enter the NPC break point in cm.');
      return;
    }

    String analysis = '';
    if (breakCm > 10) {
      analysis = 'Abnormal (Receded NPC). High likelihood of Convergence Insufficiency (CI).';
    } else if (breakCm >= 6 && breakCm <= 10) {
      analysis = 'Borderline NPC. Clinical correlation required.';
    } else {
      analysis = 'Normal NPC.';
    }

    if (recoveryCm != null) {
      if (recoveryCm > 15) {
        analysis += '\nRecovery point is significantly delayed, supporting CI diagnosis.';
      } else if (recoveryCm - breakCm > 5) {
        analysis += '\nWide gap between break and recovery indicates poor vergence recovery.';
      }
    }

    setState(() {
      _npcResult = analysis;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NPA & NPC Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // NPA Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Near Point of Accommodation (NPA)', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    const Text('Uses Hofstetter\'s formulas to compare patient NPA against age-expected norms.'),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Patient Age', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _npaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Measured NPA (in cm) [Optional]', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _calculateNPA, child: const Text('Calculate NPA')),
                    if (_npaResult.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        color: Colors.blue.shade50,
                        child: Text(_npaResult, style: const TextStyle(fontSize: 16)),
                      ),
                    ]
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // NPC Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Near Point of Convergence (NPC)', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    const Text('Evaluates convergence amplitude to screen for Convergence Insufficiency.'),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _npcBreakController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'NPC Break Point (cm)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _npcRecoveryController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'NPC Recovery Point (cm) [Optional]', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _calculateNPC, child: const Text('Analyze NPC')),
                    if (_npcResult.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        color: Colors.orange.shade50,
                        child: Text(_npcResult, style: const TextStyle(fontSize: 16)),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
