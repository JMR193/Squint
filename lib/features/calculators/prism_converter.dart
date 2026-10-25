import 'dart:math';
import 'package:flutter/material.dart';

class PrismConverterScreen extends StatefulWidget {
  const PrismConverterScreen({super.key});

  @override
  State<PrismConverterScreen> createState() => _PrismConverterScreenState();
}

class _PrismConverterScreenState extends State<PrismConverterScreen> {
  final _prismController = TextEditingController(text: '10');
  final _degreesController = TextEditingController(text: '5.71');

  // Prentice Rule: P = c * F
  final _lensPowerController = TextEditingController(text: '4.00'); // Diopters
  final _decentrationController = TextEditingController(text: '5.0'); // mm
  double? _prenticeResult;

  void _onPrismChanged(String val) {
    final prism = double.tryParse(val);
    if (prism != null) {
      // 1 Prism Diopter displaces light 1cm at 1 meter.
      // angle (radians) = atan(prism / 100)
      // angle (degrees) = angle (radians) * 180 / pi
      final deg = atan(prism / 100.0) * (180.0 / pi);
      _degreesController.text = deg.toStringAsFixed(2);
    }
  }

  void _onDegreesChanged(String val) {
    final deg = double.tryParse(val);
    if (deg != null) {
      // prism = 100 * tan(deg * pi / 180)
      final prism = 100.0 * tan(deg * (pi / 180.0));
      _prismController.text = prism.toStringAsFixed(2);
    }
  }

  void _calculatePrentice() {
    final f = double.tryParse(_lensPowerController.text) ?? 0.0;
    final cMm = double.tryParse(_decentrationController.text) ?? 0.0;
    final cCm = cMm / 10.0; // convert mm to cm
    // P = c (cm) * F (D)
    setState(() {
      _prenticeResult = cCm * f;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prism & Angle Converter')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Prism Diopters (Δ) ⇄ Degrees (°)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    const Text('Clinical Rule of Thumb: 1° ≈ 1.75 Δ (or 1Δ ≈ 0.57°)', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _prismController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Prism Diopters (Δ)',
                        border: OutlineInputBorder(),
                        suffixText: 'Δ',
                      ),
                      onChanged: _onPrismChanged,
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _degreesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Degrees of Arc (°)',
                        border: OutlineInputBorder(),
                        suffixText: '°',
                      ),
                      onChanged: _onDegreesChanged,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Prentice\'s Rule (Induced Prismatic Effect)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 6),
                    const Text('Formula: P = c × F\nWhere P = Induced Prism (Δ), c = Decentration (cm), F = Lens Power (D)', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _lensPowerController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Spectacle Lens Power (D)',
                        hintText: 'e.g. +4.00 or -3.50',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _decentrationController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Decentration from Optical Center (mm)',
                        hintText: 'e.g. 5.0 mm',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _calculatePrentice,
                      icon: const Icon(Icons.calculate),
                      label: const Text('Compute Induced Prism'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                      ),
                    ),
                    if (_prenticeResult != null) ...[
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          'Induced Prism: ${_prenticeResult!.abs().toStringAsFixed(2)} Δ',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                      ),
                    ],
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
