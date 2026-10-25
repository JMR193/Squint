import 'package:flutter/material.dart';

class ThreeStepTestScreen extends StatefulWidget {
  const ThreeStepTestScreen({super.key});

  @override
  State<ThreeStepTestScreen> createState() => _ThreeStepTestScreenState();
}

class _ThreeStepTestScreenState extends State<ThreeStepTestScreen> {
  // Step 1: Which eye is higher in primary position?
  String _step1 = 'Right'; // 'Right', 'Left'
  // Step 2: Is the hyperdeviation worse in right or left gaze?
  String _step2 = 'Left'; // 'Right', 'Left'
  // Step 3: Is the hyperdeviation worse on right or left head tilt?
  String _step3 = 'Right'; // 'Right', 'Left'

  String _result = '';

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    String pareticMuscle = '';

    if (_step1 == 'Right') { // Right Hypertropia
      if (_step2 == 'Left') {
        if (_step3 == 'Right') {
          pareticMuscle = 'Right Superior Oblique (RSO)\n[Classic Cranial Nerve IV Palsy]';
        } else if (_step3 == 'Left') {
          pareticMuscle = 'Right Inferior Rectus (RIR)';
        }
      } else if (_step2 == 'Right') {
        if (_step3 == 'Right') {
          pareticMuscle = 'Left Superior Rectus (LSR)';
        } else if (_step3 == 'Left') {
          pareticMuscle = 'Left Inferior Oblique (LIO)';
        }
      }
    } else if (_step1 == 'Left') { // Left Hypertropia
      if (_step2 == 'Right') {
        if (_step3 == 'Left') {
          pareticMuscle = 'Left Superior Oblique (LSO)\n[Classic Cranial Nerve IV Palsy]';
        } else if (_step3 == 'Right') {
          pareticMuscle = 'Left Inferior Rectus (LIR)';
        }
      } else if (_step2 == 'Left') {
        if (_step3 == 'Left') {
          pareticMuscle = 'Right Superior Rectus (RSR)';
        } else if (_step3 == 'Right') {
          pareticMuscle = 'Right Inferior Oblique (RIO)';
        }
      }
    }

    setState(() {
      _result = pareticMuscle.isNotEmpty 
          ? pareticMuscle 
          : 'Inconclusive or non-cyclovertical etiology.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parks-Bielschowsky 3-Step Test')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Algorithmic isolation of paretic cyclovertical extraocular muscle in vertical diplopia.',
              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13),
            ),
            const SizedBox(height: 16),
            
            // Step 1
            Card(
              elevation: 1.5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Step 1: Which eye is higher in primary position?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 10),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'Right', label: Text('Right Hypertropia (RHT)'), icon: Icon(Icons.arrow_upward)),
                        ButtonSegment(value: 'Left', label: Text('Left Hypertropia (LHT)'), icon: Icon(Icons.arrow_upward)),
                      ],
                      selected: {_step1},
                      onSelectionChanged: (set) {
                        setState(() => _step1 = set.first);
                        _calculate();
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Step 2
            Card(
              elevation: 1.5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Step 2: Hyperdeviation increases in which horizontal gaze?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 10),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'Right', label: Text('Right Gaze (Dextroversion)'), icon: Icon(Icons.arrow_forward)),
                        ButtonSegment(value: 'Left', label: Text('Left Gaze (Levoversion)'), icon: Icon(Icons.arrow_back)),
                      ],
                      selected: {_step2},
                      onSelectionChanged: (set) {
                        setState(() => _step2 = set.first);
                        _calculate();
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Step 3
            Card(
              elevation: 1.5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Step 3: Bielschowsky Head Tilt Test (BHTT)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const Text('Hyperdeviation increases on which head tilt?', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 10),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'Right', label: Text('Right Head Tilt'), icon: Icon(Icons.rotate_right)),
                        ButtonSegment(value: 'Left', label: Text('Left Head Tilt'), icon: Icon(Icons.rotate_left)),
                      ],
                      selected: {_step3},
                      onSelectionChanged: (set) {
                        setState(() => _step3 = set.first);
                        _calculate();
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
              ),
              child: Column(
                children: [
                  Text(
                    'ISOLATED PARETIC MUSCLE',
                    style: TextStyle(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _result,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
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
}
