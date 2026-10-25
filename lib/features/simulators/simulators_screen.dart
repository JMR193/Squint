import 'package:flutter/material.dart';
import '../../core/widgets/custom_ui_components.dart';
import 'unity_simulator_screen.dart';
import 'brock_string_simulator_screen.dart';
import 'synoptophore_simulator_screen.dart';
import 'surgical_biomechanics_screen.dart';
import 'lancaster_screen_simulator.dart';
import 'neuro_ophtho_simulator_screen.dart';
import 'visual_pathways_simulator_screen.dart';
import 'gonioscopy_simulator_screen.dart';
import 'realistic_eye_3d_screen.dart';
import 'cover_test_3d_studio_screen.dart';
import '../pediatrics/pediatric_fixation_character_screen.dart';
import '../tests/visual_acuity_chart_screen.dart';
import '../tests/hess_screen_simulator.dart';
import '../tests/color_vision_simulator_screen.dart';
import '../therapy/patching_tracker_screen.dart';
import '../therapy/dichoptic_game_screen.dart';
import '../therapy/contrast_dichoptic_game_screen.dart';
import '../therapy/hart_chart_screen.dart';
import '../tests/smart_optometry_hub_screen.dart';
import '../tests/worth_four_dot_screen.dart';
import '../tests/schober_test_screen.dart';
import '../tests/okn_drum_screen.dart';
import '../tests/amsler_grid_screen.dart';
import '../tests/cobalt_blue_light_screen.dart';
import '../tests/aniseikonia_test_screen.dart';
import '../tests/accommodation_facility_screen.dart';

class SimulatorsScreen extends StatefulWidget {
  const SimulatorsScreen({super.key});

  @override
  State<SimulatorsScreen> createState() => _SimulatorsScreenState();
}

class _SimulatorsScreenState extends State<SimulatorsScreen> {
  String _selectedCategory = 'all';

  final Map<String, String> _categories = const {
    'all': 'All Labs',
    'smart': 'Smart Tests',
    'neuro': 'Neuro-Ophtho',
    'orthoptic': 'Orthoptics',
    'dtx': 'DTx Therapy',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Therapy & Clinical Simulators'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Apple iOS 18 Segmented Control Bar
          AppleSegmentedControl<String>(
            options: _categories,
            selectedValue: _selectedCategory,
            onSelected: (val) => setState(() => _selectedCategory = val),
          ),
          const SizedBox(height: 16),

          // Category Filter Logic
          if (_selectedCategory == 'all' || _selectedCategory == 'smart') ...[
            SamsungOneUiGroupCard(
              title: 'SMART OPTOMETRY CLINICAL SUITE',
              icon: Icons.biotech,
              child: Column(
                children: [
                  _buildGlassTile(
                    context,
                    title: 'Smart Optometry Testing Hub (All 15 Tests)',
                    description: 'Worth 4-Dot, Schober, OKN Drum, Amsler, Cobalt Blue & Aniseikonia.',
                    icon: Icons.hub,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SmartOptometryHubScreen())),
                  ),
                  const SizedBox(height: 10),
                  _buildGlassTile(
                    context,
                    title: 'Worth 4-Dot Test (W4D)',
                    description: 'Near 33cm / Distance 6m red-green dissociation fusion & suppression test.',
                    icon: Icons.adjust,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WorthFourDotScreen())),
                  ),
                  const SizedBox(height: 10),
                  _buildGlassTile(
                    context,
                    title: 'Schober Test',
                    description: 'Concentric green rings & red cross for horizontal/vertical phoria neutralization.',
                    icon: Icons.control_camera,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SchoberTestScreen())),
                  ),
                  const SizedBox(height: 10),
                  _buildGlassTile(
                    context,
                    title: 'Optokinetic Nystagmus (OKN) Drum',
                    description: 'Moving stripes with variable velocity, spatial frequency & pediatric mascots.',
                    icon: Icons.speed,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OknDrumScreen())),
                  ),
                  const SizedBox(height: 10),
                  _buildGlassTile(
                    context,
                    title: 'Amsler Grid & Maculopathy Canvas',
                    description: 'Standard, Red 3, Fine 7 charts with interactive touch scotoma drawer.',
                    icon: Icons.grid_4x4,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AmslerGridScreen())),
                  ),
                  const SizedBox(height: 10),
                  _buildGlassTile(
                    context,
                    title: 'Cobalt Blue Light & Wratten #12 Filter',
                    description: 'Fluorescein excitation illuminator, Seidel sign, TBUT & RGP tear film pooling.',
                    icon: Icons.light_mode,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CobaltBlueLightScreen())),
                  ),
                  const SizedBox(height: 10),
                  _buildGlassTile(
                    context,
                    title: 'Awaya New Aniseikonia Test (NAT)',
                    description: 'Red-green half-moon size comparison brackets (0.5% to 24% disparity).',
                    icon: Icons.layers,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AniseikoniaTestScreen())),
                  ),
                  const SizedBox(height: 10),
                  _buildGlassTile(
                    context,
                    title: 'Accommodation & ±2.00D Flipper Lab',
                    description: 'Hofstetter formulas, 60s BAF/MAF cycle counter & Push-Up RAF rule.',
                    icon: Icons.timer,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AccommodationFacilityScreen())),
                  ),
                ],
              ),
            ),
          ],

          if (_selectedCategory == 'all' || _selectedCategory == 'neuro') ...[
            SamsungOneUiGroupCard(
              title: 'NEURO-OPHTHALMIC LABS',
              icon: Icons.psychology,
              child: Column(
                children: [
                  _buildGlassTile(
                    context,
                    title: 'Neuro-Ophthalmic Examination Lab',
                    description: '2D vector globes with torchlight, Marcus Gunn swing, cover test & 42 pathologies.',
                    icon: Icons.remove_red_eye,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NeuroOphthoSimulatorScreen())),
                  ),
                  const SizedBox(height: 10),
                  _buildGlassTile(
                    context,
                    title: 'Visual Pathways & Perimetry Lab',
                    description: 'Afferent visual pathways, Wilbrand knee, LGN, Meyer\'s loop & 30-2 perimetry.',
                    icon: Icons.timeline,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VisualPathwaysSimulatorScreen())),
                  ),
                  const SizedBox(height: 10),
                  _buildGlassTile(
                    context,
                    title: '3D Eye Motility Simulator',
                    description: '3D interactive globe with 6 extraocular muscles & cranial nerve palsies.',
                    icon: Icons.view_in_ar,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UnitySimulatorScreen())),
                  ),
                  const SizedBox(height: 10),
                  _buildGlassTile(
                    context,
                    title: 'Gonioscopy & Angle Grading Lab',
                    description: '4-Mirror Goldmann angle structures, Shaffer grading & dynamic indentation.',
                    icon: Icons.lens,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GonioscopySimulatorScreen())),
                  ),
                  const SizedBox(height: 10),
                  _buildGlassTile(
                    context,
                    title: '3D Hyper-Realistic Orbital Eye Lab',
                    description: 'Raytraced specular cornea, dynamic iris crypts, 6-EOM tension & fundus view.',
                    icon: Icons.visibility,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RealisticEye3dScreen())),
                  ),
                  const SizedBox(height: 10),
                  _buildGlassTile(
                    context,
                    title: 'Pediatric Fixation Mascot Studio',
                    description: 'Animated 3D characters (Dr. Iris, Sparky, Barnaby) & Teller preferential looking.',
                    icon: Icons.face,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PediatricFixationCharacterScreen())),
                  ),
                ],
              ),
            ),
          ],

          if (_selectedCategory == 'all' || _selectedCategory == 'orthoptic') ...[
            SamsungOneUiGroupCard(
              title: 'ADVANCED ORTHOPTIC LABS',
              icon: Icons.biotech,
              child: Column(
                children: [
                  _buildGlassTile(
                    context,
                    title: '3D Cover Test & Prism Studio',
                    description: 'Interactive occluder paddle, refixation saccades & virtual prism bar.',
                    icon: Icons.shield,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CoverTest3dStudioScreen())),
                  ),
                  const SizedBox(height: 10),
                  _buildGlassTile(
                    context,
                    title: 'Virtual Brock String (3D Vergence)',
                    description: 'Interactive 3D strings, physiological diplopia ("X" & "V"), vergence jumps.',
                    icon: Icons.linear_scale,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BrockStringSimulatorScreen())),
                  ),
                  const SizedBox(height: 10),
                  _buildGlassTile(
                    context,
                    title: 'Virtual Synoptophore (Amblyoscope)',
                    description: 'Dual optical tubes, Angle Kappa (κ), Haidinger brushes, NRC vs ARC.',
                    icon: Icons.biotech,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SynoptophoreSimulatorScreen())),
                  ),
                  const SizedBox(height: 10),
                  _buildGlassTile(
                    context,
                    title: 'Surgical Biomechanics & Orbit™',
                    description: 'Recession/resection vectors, arc of contact & alignment prediction.',
                    icon: Icons.healing,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SurgicalBiomechanicsScreen())),
                  ),
                  const SizedBox(height: 10),
                  _buildGlassTile(
                    context,
                    title: 'Lancaster Red-Green Screen',
                    description: 'Tangent screen with cyclotorsion streaks and paretic presets.',
                    icon: Icons.border_all,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LancasterScreenSimulator())),
                  ),
                ],
              ),
            ),
          ],

          if (_selectedCategory == 'all' || _selectedCategory == 'dtx') ...[
            SamsungOneUiGroupCard(
              title: 'DIGITAL THERAPEUTICS (DTx)',
              icon: Icons.videogame_asset,
              child: Column(
                children: [
                  _buildGlassTile(
                    context,
                    title: 'Balanced Dichoptic Therapy (DCP)',
                    description: 'Dynamic Contrast Penalization for breaking amblyopic suppression.',
                    icon: Icons.videogame_asset,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContrastDichopticGameScreen())),
                  ),
                  const SizedBox(height: 10),
                  _buildGlassTile(
                    context,
                    title: 'Hart Chart Accommodative Facility',
                    description: '10x10 metronome-paced saccadic rock & accommodative trainer.',
                    icon: Icons.grid_3x3,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HartChartScreen())),
                  ),
                  const SizedBox(height: 10),
                  _buildGlassTile(
                    context,
                    title: 'Amblyopia Patching Tracker',
                    description: 'Log occlusion hours & view 7-day compliance chart.',
                    icon: Icons.timer,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PatchingTrackerScreen())),
                  ),
                  const SizedBox(height: 10),
                  _buildGlassTile(
                    context,
                    title: 'Red/Green Dichoptic Therapy Game',
                    description: 'Red/Green anaglyph anti-suppression puzzle game.',
                    icon: Icons.gamepad,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DichopticGameScreen())),
                  ),
                ],
              ),
            ),
          ],

          if (_selectedCategory == 'all') ...[
            SamsungOneUiGroupCard(
              title: 'CLINICAL MOTILITY & VISION TESTS',
              icon: Icons.grid_on,
              child: Column(
                children: [
                  _buildGlassTile(
                    context,
                    title: '3D Cover Test & Prism Neutralization Studio',
                    description: 'Cover-uncover & alternate test with virtual prism bar neutralization.',
                    icon: Icons.shield,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CoverTest3dStudioScreen())),
                  ),
                  const SizedBox(height: 10),
                  _buildGlassTile(
                    context,
                    title: 'Hess / Lees Motility Tangent Screen',
                    description: 'Red-green dissociation with underaction & yoke muscle overaction vectors.',
                    icon: Icons.grid_on,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HessScreenSimulator())),
                  ),
                  const SizedBox(height: 10),
                  _buildGlassTile(
                    context,
                    title: 'Worth 4-Dot Test (W4D)',
                    description: 'Near 33cm / Distance 6m red-green dissociation fusion & suppression test.',
                    icon: Icons.adjust,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WorthFourDotScreen())),
                  ),
                  const SizedBox(height: 10),
                  _buildGlassTile(
                    context,
                    title: 'Digital Visual Acuity & Optotype Chart',
                    description: 'Snellen, Sloan, Tumbling E, Lea symbols, Duochrome & Crowding bars.',
                    icon: Icons.font_download,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VisualAcuityChartScreen())),
                  ),
                  const SizedBox(height: 10),
                  _buildGlassTile(
                    context,
                    title: 'Color Vision & Ishihara Plate Lab',
                    description: 'Protan/Deutan congenital dyschromatopsia & Optic Neuritis Red Desaturation.',
                    icon: Icons.filter_vintage,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ColorVisionSimulatorScreen())),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGlassTile(BuildContext context, {required String title, required String description, required IconData icon, required VoidCallback onTap}) {
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

