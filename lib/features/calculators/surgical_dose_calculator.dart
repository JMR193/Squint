import 'package:flutter/material.dart';

class SurgicalDoseCalculatorScreen extends StatefulWidget {
  const SurgicalDoseCalculatorScreen({super.key});

  @override
  State<SurgicalDoseCalculatorScreen> createState() => _SurgicalDoseCalculatorScreenState();
}

class _SurgicalDoseCalculatorScreenState extends State<SurgicalDoseCalculatorScreen> {
  final TextEditingController _pdController = TextEditingController();
  String _strabismusType = 'Esotropia'; // Esotropia or Exotropia
  String _result = '';

  void _calculateDose() {
    final double? pd = double.tryParse(_pdController.text);
    if (pd == null || pd <= 0) {
      setState(() {
        _result = 'Please enter a valid Prism Diopter (PD) value.';
      });
      return;
    }

    // Simplified Parks Tables logic (for demonstration purposes)
    // Esotropia: Medial Rectus Recession + Lateral Rectus Resection
    // Exotropia: Lateral Rectus Recession + Medial Rectus Resection
    String plan = '';
    
    if (_strabismusType == 'Esotropia') {
      if (pd <= 15) {
        plan = 'Bilateral Medial Rectus Recession: 3.0 mm';
      } else if (pd <= 20) {
        plan = 'Bilateral Medial Rectus Recession: 3.5 mm';
      } else if (pd <= 25) {
        plan = 'Bilateral Medial Rectus Recession: 4.0 mm';
      } else if (pd <= 30) {
        plan = 'Bilateral Medial Rectus Recession: 4.5 mm';
      } else if (pd <= 35) {
        plan = 'Bilateral Medial Rectus Recession: 5.0 mm';
      } else if (pd <= 40) {
        plan = 'Bilateral Medial Rectus Recession: 5.5 mm';
      } else if (pd <= 50) {
        plan = 'Bilateral Medial Rectus Recession: 6.0 mm\nOR\nMR Recession 5.5mm + LR Resection 6.0mm (One eye)';
      } else {
        plan = 'Consider 3 or 4 muscle surgery.';
      }
    } else {
      // Exotropia
      if (pd <= 15) {
        plan = 'Bilateral Lateral Rectus Recession: 4.0 mm';
      } else if (pd <= 20) {
        plan = 'Bilateral Lateral Rectus Recession: 5.0 mm';
      } else if (pd <= 25) {
        plan = 'Bilateral Lateral Rectus Recession: 6.0 mm';
      } else if (pd <= 30) {
        plan = 'Bilateral Lateral Rectus Recession: 7.0 mm';
      } else if (pd <= 35) {
        plan = 'Bilateral Lateral Rectus Recession: 7.5 mm';
      } else if (pd <= 40) {
        plan = 'Bilateral Lateral Rectus Recession: 8.0 mm';
      } else if (pd <= 50) {
        plan = 'LR Recession 7.0mm + MR Resection 6.0mm (One eye)';
      } else {
        plan = 'Consider 3 or 4 muscle surgery.';
      }
    }

    setState(() {
      _result = 'Suggested Surgical Plan (Parks Guidelines):\n\n$plan\n\n*Note: This is a guideline only and should be adjusted based on clinical judgment.*';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Surgical Dose Calculator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _strabismusType,
              decoration: const InputDecoration(labelText: 'Strabismus Type'),
              items: ['Esotropia', 'Exotropia'].map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _strabismusType = val!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pdController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Measured Deviation (Prism Diopters)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _calculateDose,
              child: const Text('Calculate Dose'),
            ),
            const SizedBox(height: 24),
            if (_result.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  _result,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
