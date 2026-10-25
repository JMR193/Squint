import 'package:flutter/material.dart';

class AcaRatioCalculatorScreen extends StatefulWidget {
  const AcaRatioCalculatorScreen({super.key});

  @override
  State<AcaRatioCalculatorScreen> createState() => _AcaRatioCalculatorScreenState();
}

class _AcaRatioCalculatorScreenState extends State<AcaRatioCalculatorScreen> {
  int _methodIndex = 0; // 0 = Heterophoria Method, 1 = Gradient Method

  // Heterophoria method controllers
  final _ipdController = TextEditingController(text: '6.0'); // Interpupillary distance in cm (e.g. 60mm = 6.0cm)
  final _nearDevController = TextEditingController(text: '10'); // Near deviation at 33cm (3.0 D demand)
  final _distDevController = TextEditingController(text: '2'); // Distance deviation at 6m (0 D demand)
  bool _nearEso = true;
  bool _distEso = true;

  // Gradient method controllers
  final _baseDevController = TextEditingController(text: '12'); // Dev without lens
  final _lensDevController = TextEditingController(text: '3'); // Dev with lens
  final _lensPowerController = TextEditingController(text: '3.0'); // +3.00 D or -3.00 D
  bool _baseEso = true;
  bool _lensEso = true;

  double? _resultAca;
  String? _interpretation;

  void _calculateHeterophoria() {
    final ipd = double.tryParse(_ipdController.text) ?? 6.0;
    final nearDevVal = double.tryParse(_nearDevController.text) ?? 0.0;
    final distDevVal = double.tryParse(_distDevController.text) ?? 0.0;

    // Convention: Esodeviation is positive (+), Exodeviation is negative (-)
    final dn = _nearEso ? nearDevVal : -nearDevVal;
    final df = _distEso ? distDevVal : -distDevVal;

    // Formula: AC/A = IPD (cm) + (Dn - Df) / Accommodation (D, typically 3.0D at 33cm)
    final aca = ipd + ((dn - df) / 3.0);

    setState(() {
      _resultAca = aca;
      _interpretation = _interpretAca(aca);
    });
  }

  void _calculateGradient() {
    final baseVal = double.tryParse(_baseDevController.text) ?? 0.0;
    final lensVal = double.tryParse(_lensDevController.text) ?? 0.0;
    final lensPower = double.tryParse(_lensPowerController.text) ?? 3.0;

    if (lensPower == 0) return;

    final dBase = _baseEso ? baseVal : -baseVal;
    final dLens = _lensEso ? lensVal : -lensVal;

    // Formula: AC/A = |(D_with_lens - D_without_lens)| / Lens_Power
    final aca = (dBase - dLens).abs() / lensPower;

    setState(() {
      _resultAca = aca;
      _interpretation = _interpretAca(aca);
    });
  }

  String _interpretAca(double aca) {
    if (aca > 5.5) {
      return 'High AC/A Ratio (> 5:1): Suggests Accommodative Esotropia (Convergence Excess). Patient will likely benefit substantially from Bifocals (executive flat-top add) or Cycloplegic refraction correction.';
    } else if (aca < 3.0) {
      return 'Low AC/A Ratio (< 3:1): Characteristic of Convergence Insufficiency (near deviation much more exophoric than distance). Treatment of choice is Office-based Vision Therapy / Orthoptics.';
    } else {
      return 'Normal AC/A Ratio (3:1 to 5:1): Normal physiological linkage between accommodation and accommodative convergence.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AC/A Ratio Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Heterophoria Method')),
                ButtonSegment(value: 1, label: Text('Gradient Method')),
              ],
              selected: {_methodIndex},
              onSelectionChanged: (set) {
                setState(() {
                  _methodIndex = set.first;
                  _resultAca = null;
                });
              },
            ),
            const SizedBox(height: 16),
            if (_methodIndex == 0) _buildHeterophoriaInputs() else _buildGradientInputs(),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _methodIndex == 0 ? _calculateHeterophoria : _calculateGradient,
              icon: const Icon(Icons.calculate),
              label: const Text('Compute AC/A Ratio', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            if (_resultAca != null) ...[
              const SizedBox(height: 24),
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('Calculated AC/A Ratio', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        '${_resultAca!.toStringAsFixed(1)} : 1 Δ / D',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const Divider(height: 24),
                      Text(
                        _interpretation ?? '',
                        style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onPrimaryContainer),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeterophoriaInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Formula: AC/A = IPD + (Dn - Df) / 3.0', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13)),
        const SizedBox(height: 12),
        TextField(
          controller: _ipdController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Interpupillary Distance (IPD in cm)',
            hintText: 'e.g. 6.0 (for 60 mm)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _nearDevController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Near Dev at 33cm (Δ)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: Text(_nearEso ? 'Eso (+)' : 'Exo (-)'),
              selected: true,
              onSelected: (_) => setState(() => _nearEso = !_nearEso),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _distDevController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Distance Dev at 6m (Δ)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: Text(_distEso ? 'Eso (+)' : 'Exo (-)'),
              selected: true,
              onSelected: (_) => setState(() => _distEso = !_distEso),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGradientInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Formula: AC/A = |(D_base - D_lens)| / Lens_Power', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _baseDevController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Deviation Without Lens (Δ)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: Text(_baseEso ? 'Eso (+)' : 'Exo (-)'),
              selected: true,
              onSelected: (_) => setState(() => _baseEso = !_baseEso),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _lensDevController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Deviation With Lens (Δ)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: Text(_lensEso ? 'Eso (+)' : 'Exo (-)'),
              selected: true,
              onSelected: (_) => setState(() => _lensEso = !_lensEso),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _lensPowerController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Relaxing / Stimulating Lens Power (Diopters)',
            hintText: 'e.g. 3.0 (for +3.00D or -3.00D)',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
