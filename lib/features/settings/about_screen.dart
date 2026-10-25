import 'package:flutter/material.dart';
import '../../core/widgets/custom_ui_components.dart';
import 'apache_license_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('About Squint Clinical Suite'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // App Header Hero Banner
            Center(
              child: Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        colors: [Colors.cyanAccent, Colors.amberAccent, Colors.blueAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyanAccent.withValues(alpha: 0.35),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(21),
                      child: Image.asset(
                        'assets/icon.jpg',
                        width: 84,
                        height: 84,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Squint & Strabismus Clinical Suite',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.cyan.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.cyan),
                    ),
                    child: const Text(
                      'Version 3.0.0 Pro • Enterprise Clinical Edition',
                      style: TextStyle(color: Colors.cyanAccent, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Clinical Disclaimer Notice
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.amber.shade900.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.amber, width: 1.2),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber, color: Colors.amber, size: 24),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Clinical Disclaimer & Regulatory Scope',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 13)),
                        SizedBox(height: 4),
                        Text(
                          'Designed for educational, motility simulation, and surgical dose planning reference by ophthalmologists, optometrists, orthoptists, and medical residents. Final diagnostic and surgical decisions remain the sole responsibility of the licensed practitioner.',
                          style: TextStyle(fontSize: 11, color: Colors.white70, height: 1.35),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Key Modules Matrix
            SamsungOneUiGroupCard(
              title: 'FULL CLINICAL MODULE MATRIX (v3.0.0)',
              icon: Icons.hub,
              child: Column(
                children: [
                  _buildFeatureTile(
                    icon: Icons.visibility,
                    title: '4-Mirror Zeiss & Goldmann Gonioscopy Lab',
                    subtitle: 'Corneal optical wedge, dynamic indentation, Shaffer & Spaeth grading, and 9 angle pathologies.',
                  ),
                  const Divider(height: 14),
                  _buildFeatureTile(
                    icon: Icons.remove_red_eye,
                    title: '9-Gaze EOM Vector Motility Engine',
                    subtitle: 'Hering & Sherrington reciprocal innervation, CN III/IV/VI palsies, ptosis, and physiological blinking loop.',
                  ),
                  const Divider(height: 14),
                  _buildFeatureTile(
                    icon: Icons.font_download,
                    title: 'Digital Visual Acuity & Optotype Chart',
                    subtitle: 'Snellen, Sloan, Tumbling E, Lea pediatric symbols, Duochrome test, and Amblyopia crowding bars.',
                  ),
                  const Divider(height: 14),
                  _buildFeatureTile(
                    icon: Icons.grid_on,
                    title: 'Hess / Lees Screen Motility Chart',
                    subtitle: 'Red-green dissociation tangent grid with underaction & yoke muscle overaction plotting.',
                  ),
                  const Divider(height: 14),
                  _buildFeatureTile(
                    icon: Icons.filter_vintage,
                    title: 'Color Vision & Ishihara Plate Lab',
                    subtitle: 'Protanopia, Deuteranopia, Tritanopia, and early Optic Neuritis Red Desaturation detector.',
                  ),
                  const Divider(height: 14),
                  _buildFeatureTile(
                    icon: Icons.sports_gymnastics,
                    title: 'Interactive Vision Therapy Hub',
                    subtitle: 'Convergence/Divergence, Brock String 3D, Anti-Suppression Bar Reader, & Saccade Trainers.',
                  ),
                  const Divider(height: 14),
                  _buildFeatureTile(
                    icon: Icons.blur_circular,
                    title: '3D Orbital Eye Anatomy & Muscle Vector Lab',
                    subtitle: 'Raytraced specular cornea, dynamic iris stroma crypts, torchlight reflex, and 6-EOM tension vectors.',
                  ),
                  const Divider(height: 14),
                  _buildFeatureTile(
                    icon: Icons.visibility,
                    title: '3D Cover Test & Virtual Prism Bar Studio',
                    subtitle: 'Animated occluder paddle, unilateral/alternate cover test, and refixation saccade neutralization.',
                  ),
                  const Divider(height: 14),
                  _buildFeatureTile(
                    icon: Icons.pets,
                    title: 'Pediatric Vision Mascot & Fixation Studio',
                    subtitle: 'Dr. Iris (Owl), Sparky (Fox), and Barnaby (Bear) with Teller gratings and touch spark animations.',
                  ),
                  const Divider(height: 14),
                  _buildFeatureTile(
                    icon: Icons.language,
                    title: 'Global 8-Language Localization Engine',
                    subtitle: 'Real-time switching for English, Spanish, French, German, Chinese, Hindi, Arabic, and Japanese.',
                  ),
                  const Divider(height: 14),
                  _buildFeatureTile(
                    icon: Icons.biotech,
                    title: 'Smart Optometry 15-Test Chairside Suite',
                    subtitle: 'Worth 4-Dot, Schober, OKN Drum, Amsler Grid, Cobalt Blue + Wratten #12, Awaya NAT & ±2.00D Flipper.',
                  ),
                  const Divider(height: 14),
                  _buildFeatureTile(
                    icon: Icons.storage,
                    title: 'Encrypted Offline Patient Database',
                    subtitle: 'Full examination persistence, statistics summary, and 1-tap clinical referral letter export.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Legal & Open Source Licenses
            SamsungOneUiGroupCard(
              title: 'LICENSING & OPEN SOURCE COMPLIANCE',
              icon: Icons.gavel,
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.gavel, color: Colors.cyanAccent),
                    title: const Text('Apache License Version 2.0', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: const Text('View open-source license terms and permissions.', style: TextStyle(fontSize: 11)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ApacheLicenseScreen()),
                      );
                    },
                  ),
                  const Divider(height: 14),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.verified, color: Colors.tealAccent),
                    title: const Text('Third-Party Open Source Libraries', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: const Text('Flutter, Provider, SharedPreferences, Google Fonts.', style: TextStyle(fontSize: 11)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      showLicensePage(
                        context: context,
                        applicationName: 'Squint Clinical Suite',
                        applicationVersion: '3.0.0',
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Built for Worldwide Ophthalmology & Orthoptics • 2026',
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile({required IconData icon, required String title, required String subtitle}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.cyanAccent),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11, height: 1.3)),
            ],
          ),
        ),
      ],
    );
  }
}
