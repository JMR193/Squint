import 'package:flutter/material.dart';
import '../../core/widgets/custom_ui_components.dart';
import 'worth_four_dot_screen.dart';
import 'schober_test_screen.dart';
import 'okn_drum_screen.dart';
import 'amsler_grid_screen.dart';
import 'cobalt_blue_light_screen.dart';
import 'aniseikonia_test_screen.dart';
import 'accommodation_facility_screen.dart';
import 'visual_acuity_chart_screen.dart';
import 'color_vision_simulator_screen.dart';
import 'hess_screen_simulator.dart';
import '../screening/hirschberg_test_screen.dart';
import '../simulators/gonioscopy_simulator_screen.dart';
import '../simulators/realistic_eye_3d_screen.dart';
import '../simulators/cover_test_3d_studio_screen.dart';

class SmartOptometryHubScreen extends StatelessWidget {
  const SmartOptometryHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Optometry Clinical Suite'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Hero Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.8),
                  Colors.indigo.shade900.withValues(alpha: 0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.biotech, size: 40, color: Colors.white),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Smart Optometry Screening Tools',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '15 standardized chairside ophthalmic & optometric tests calibrated for clinical examination, residency training, and board certification.',
                        style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 1. Binocular Vision & Orthoptics Tests
          SamsungOneUiGroupCard(
            title: 'BINOCULAR VISION & SUPPRESSION TESTS',
            icon: Icons.visibility,
            child: Column(
              children: [
                _buildTestTile(
                  context,
                  icon: Icons.adjust,
                  color: Colors.redAccent,
                  title: 'Worth 4-Dot Test (W4D)',
                  subtitle: 'Near 33cm / Distance 6m red-green dissociation fusion & suppression test',
                  screen: const WorthFourDotScreen(),
                ),
                const Divider(height: 12),
                _buildTestTile(
                  context,
                  icon: Icons.control_camera,
                  color: Colors.greenAccent,
                  title: 'Schober Test',
                  subtitle: 'Concentric green rings & red cross for horizontal/vertical phoria neutralization',
                  screen: const SchoberTestScreen(),
                ),
                const Divider(height: 12),
                _buildTestTile(
                  context,
                  icon: Icons.layers,
                  color: Colors.purpleAccent,
                  title: 'Awaya New Aniseikonia Test (NAT)',
                  subtitle: 'Red-green half-moon size comparison brackets (0.5% to 24% disparity)',
                  screen: const AniseikoniaTestScreen(),
                ),
                const Divider(height: 12),
                _buildTestTile(
                  context,
                  icon: Icons.grid_on,
                  color: Colors.cyanAccent,
                  title: 'Hess / Lees Screen Motility Chart',
                  subtitle: 'Tangent dissociation grid for paretic muscle underaction & yoke overaction',
                  screen: const HessScreenSimulator(),
                ),
                const Divider(height: 12),
                _buildTestTile(
                  context,
                  icon: Icons.flaky,
                  color: Colors.deepPurpleAccent,
                  title: '3D Cover Test & Prism Neutralization',
                  subtitle: 'Unilateral, alternate, and uncover test with refixation saccades',
                  screen: const CoverTest3dStudioScreen(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 2. Visual Acuity, Contrast & Macular Psychophysics
          SamsungOneUiGroupCard(
            title: 'PSYCHOPHYSICS & MACULOPATHY',
            icon: Icons.font_download,
            child: Column(
              children: [
                _buildTestTile(
                  context,
                  icon: Icons.font_download,
                  color: Colors.blueAccent,
                  title: 'Digital Visual Acuity & LogMAR Chart',
                  subtitle: 'Snellen, Sloan, Tumbling E, Lea pediatric symbols, Duochrome & Crowding bars',
                  screen: const VisualAcuityChartScreen(),
                ),
                const Divider(height: 12),
                _buildTestTile(
                  context,
                  icon: Icons.filter_vintage,
                  color: Colors.amberAccent,
                  title: 'Color Vision & Ishihara Plate Lab',
                  subtitle: 'Protan, Deutan, Tritan plates and Optic Neuritis Red Desaturation test',
                  screen: const ColorVisionSimulatorScreen(),
                ),
                const Divider(height: 12),
                _buildTestTile(
                  context,
                  icon: Icons.grid_4x4,
                  color: Colors.tealAccent,
                  title: 'Amsler Grid & Maculopathy Canvas',
                  subtitle: 'Standard, Red 3, and Fine 7 charts with interactive touch scotoma drawer',
                  screen: const AmslerGridScreen(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 3. Neurological & Pediatric Screening
          SamsungOneUiGroupCard(
            title: 'NEUROLOGY & PEDIATRIC TESTS',
            icon: Icons.psychology,
            child: Column(
              children: [
                _buildTestTile(
                  context,
                  icon: Icons.speed,
                  color: Colors.cyanAccent,
                  title: 'Optokinetic Nystagmus (OKN) Drum',
                  subtitle: 'Variable velocity stripes & pediatric mascots for infant & cortical screening',
                  screen: const OknDrumScreen(),
                ),
                const Divider(height: 12),
                _buildTestTile(
                  context,
                  icon: Icons.camera_alt,
                  color: Colors.pinkAccent,
                  title: 'Digital Hirschberg & Krimsky Test',
                  subtitle: 'Corneal light reflex camera alignment with prism diopter estimation',
                  screen: const HirschbergTestScreen(),
                ),
                const Divider(height: 12),
                _buildTestTile(
                  context,
                  icon: Icons.blur_circular,
                  color: Colors.amber,
                  title: '3D Orbital Eye & Pupillary Reflex Lab',
                  subtitle: 'Raytraced cornea, iris crypts, torchlight reflex, and 6-EOM tension vectors',
                  screen: const RealisticEye3dScreen(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 4. Anterior Segment, Contact Lens & Refraction
          SamsungOneUiGroupCard(
            title: 'CORNEA, CONTACT LENS & REFRACTION',
            icon: Icons.lens,
            child: Column(
              children: [
                _buildTestTile(
                  context,
                  icon: Icons.light_mode,
                  color: const Color(0xFF0038FF),
                  title: 'Cobalt Blue Light & Wratten #12 Filter',
                  subtitle: 'Fluorescein excitation illuminator, Seidel sign, TBUT, and RGP fit evaluation',
                  screen: const CobaltBlueLightScreen(),
                ),
                const Divider(height: 12),
                _buildTestTile(
                  context,
                  icon: Icons.timer,
                  color: Colors.orangeAccent,
                  title: 'Accommodation & ±2.00D Flipper Lab',
                  subtitle: 'Hofstetter formulas, 60s BAF/MAF cycle counter, and Push-Up RAF rule',
                  screen: const AccommodationFacilityScreen(),
                ),
                const Divider(height: 12),
                _buildTestTile(
                  context,
                  icon: Icons.lens_blur,
                  color: Colors.green,
                  title: '4-Mirror Gonioscopy & Angle Lab',
                  subtitle: 'Zeiss indentation physics, optical wedge, and 9 angle pathologies',
                  screen: const GonioscopySimulatorScreen(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestTile(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required Widget screen,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.cyanAccent),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      },
    );
  }
}
