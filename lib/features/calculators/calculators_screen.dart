import 'package:flutter/material.dart';
import '../../core/widgets/custom_ui_components.dart';
import 'surgical_dose_calculator.dart';
import 'npa_npc_calculator.dart';
import 'three_step_test.dart';
import 'aca_calculator.dart';
import 'prism_converter.dart';
import 'kestenbaum_calculator_screen.dart';
import 'torsion_head_tilt_calculator_screen.dart';
import 'prism_adaptation_screen.dart';
import '../screening/hirschberg_test_screen.dart';

class CalculatorsScreen extends StatefulWidget {
  const CalculatorsScreen({super.key});

  @override
  State<CalculatorsScreen> createState() => _CalculatorsScreenState();
}

class _CalculatorsScreenState extends State<CalculatorsScreen> {
  String _selectedCategory = 'all';

  final Map<String, String> _categories = const {
    'all': 'All Tools',
    'surgical': 'Surgical',
    'diagnostic': 'Diagnostic',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinical Calculators & Tools'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Apple Segmented Control Filter
          AppleSegmentedControl<String>(
            options: _categories,
            selectedValue: _selectedCategory,
            onSelected: (val) => setState(() => _selectedCategory = val),
          ),
          const SizedBox(height: 16),

          if (_selectedCategory == 'all' || _selectedCategory == 'surgical') ...[
            SamsungOneUiGroupCard(
              title: 'SURGICAL & DOSING CALCULATORS',
              icon: Icons.airline_stops,
              child: Column(
                children: [
                  _buildToolTile(
                    context,
                    title: 'Kestenbaum Nystagmus Dosing',
                    description: 'Parks 5-6-7-8 & augmented 4-muscle dosing for abnormal head turn.',
                    icon: Icons.airline_stops,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KestenbaumCalculatorScreen())),
                  ),
                  const SizedBox(height: 10),
                  _buildToolTile(
                    context,
                    title: 'Torsion & Bielschowsky Tilt Test',
                    description: 'Double Maddox Rod cyclotorsion & BHTT vertical deviation analyzer.',
                    icon: Icons.rotate_right,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TorsionHeadTiltCalculatorScreen())),
                  ),
                  const SizedBox(height: 10),
                  _buildToolTile(
                    context,
                    title: 'Prism Adaptation Test (PAT)',
                    description: 'PATS trial calculator to unmask target deviation and prevent ET undercorrection.',
                    icon: Icons.layers,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrismAdaptationScreen())),
                  ),
                  const SizedBox(height: 10),
                  _buildToolTile(
                    context,
                    title: 'Surgical Dose Calculator',
                    description: 'Recession and resection tables (Parks, Wright, Helveston).',
                    icon: Icons.healing,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SurgicalDoseCalculatorScreen())),
                  ),
                ],
              ),
            ),
          ],

          if (_selectedCategory == 'all' || _selectedCategory == 'diagnostic') ...[
            SamsungOneUiGroupCard(
              title: 'DIAGNOSTIC & ORTHOPTIC CALCULATORS',
              icon: Icons.calculate,
              child: Column(
                children: [
                  _buildToolTile(
                    context,
                    title: 'Parks-Bielschowsky 3-Step Test',
                    description: 'Isolate paretic cyclovertical muscle in acquired vertical diplopia.',
                    icon: Icons.calculate,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ThreeStepTestScreen())),
                  ),
                  const SizedBox(height: 10),
                  _buildToolTile(
                    context,
                    title: 'Digital Hirschberg Test',
                    description: 'Camera corneal light reflex screener for squint angle.',
                    icon: Icons.camera_front,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HirschbergTestScreen())),
                  ),
                  const SizedBox(height: 10),
                  _buildToolTile(
                    context,
                    title: 'AC/A Ratio Calculator',
                    description: 'Heterophoria and gradient methods for accommodative esotropia.',
                    icon: Icons.percent,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AcaRatioCalculatorScreen())),
                  ),
                  const SizedBox(height: 10),
                  _buildToolTile(
                    context,
                    title: 'NPA & NPC Calculator',
                    description: 'Near Point of Accommodation (Hofstetter) & Convergence screening.',
                    icon: Icons.straighten,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NpaNpcCalculatorScreen())),
                  ),
                  const SizedBox(height: 10),
                  _buildToolTile(
                    context,
                    title: 'Prism & Angle Converter',
                    description: 'Convert between prism diopters (Δ) & degrees (°), Prentice\'s rule.',
                    icon: Icons.change_circle,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrismConverterScreen())),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildToolTile(BuildContext context, {required String title, required String description, required IconData icon, required VoidCallback onTap}) {
    return AppleGlassCard(
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.cyanAccent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 24, color: Colors.cyanAccent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 2),
                Text(description, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
        ],
      ),
    );
  }
}

