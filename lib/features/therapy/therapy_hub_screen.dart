import 'package:flutter/material.dart';
import '../../core/widgets/custom_ui_components.dart';
import 'dichoptic_game_screen.dart';
import 'contrast_dichoptic_game_screen.dart';
import 'hart_chart_screen.dart';
import 'patching_tracker_screen.dart';
import '../records/patient_records_screen.dart';

class TherapyHubScreen extends StatefulWidget {
  const TherapyHubScreen({super.key});

  @override
  State<TherapyHubScreen> createState() => _TherapyHubScreenState();
}

class _TherapyHubScreenState extends State<TherapyHubScreen> {
  final int _complianceStreakDays = 14;
  double _todayPatchedHours = 1.5;
  final double _prescribedHours = 2.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vision Therapy & Patient Records'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Compliance Streak & Quick Stats
          SamsungOneUiGroupCard(
            title: 'AMBLYOPIA COMPLIANCE & THERAPY STREAK',
            icon: Icons.local_fire_department,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCol('Daily Streak', '$_complianceStreakDays Days', Colors.orangeAccent),
                    _buildStatCol('Today\'s Occlusion', '${_todayPatchedHours.toStringAsFixed(1)}h / ${_prescribedHours}h', Colors.cyanAccent),
                    _buildStatCol('Adherence', '${((_todayPatchedHours / _prescribedHours) * 100).toInt()}%', Colors.tealAccent),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: (_todayPatchedHours / _prescribedHours).clamp(0.0, 1.0),
                  backgroundColor: Colors.grey.shade800,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.tealAccent),
                  minHeight: 6,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.add_circle_outline, size: 16),
                      label: const Text('Log +30 Mins Occlusion', style: TextStyle(fontSize: 11)),
                      onPressed: () {
                        setState(() {
                          _todayPatchedHours = (_todayPatchedHours + 0.5).clamp(0.0, 8.0);
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Patient Examination Database Card
          SamsungOneUiGroupCard(
            title: 'CLINICAL PATIENT RECORDS',
            icon: Icons.folder_shared,
            child: Column(
              children: [
                _buildActionTile(
                  context,
                  title: 'Patient Examination Database',
                  subtitle: 'View, search, create, and export cryptographic patient examination records.',
                  icon: Icons.assignment_ind,
                  color: Colors.cyanAccent,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PatientRecordsScreen())),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Vision Therapy Modules
          SamsungOneUiGroupCard(
            title: 'DIGITAL THERAPEUTIC (DTX) EXERCISES',
            icon: Icons.sports_esports,
            child: Column(
              children: [
                _buildActionTile(
                  context,
                  title: 'Dichoptic Anti-Suppression Game',
                  subtitle: 'Red-Cyan anaglyph perceptual training to overcome foveal suppression scotoma.',
                  icon: Icons.videogame_asset,
                  color: Colors.redAccent,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DichopticGameScreen())),
                ),
                const SizedBox(height: 10),
                _buildActionTile(
                  context,
                  title: 'Contrast Dichoptic Depth Game',
                  subtitle: 'Pediatric depth perception and contrast balancing anti-suppression trainer.',
                  icon: Icons.contrast,
                  color: Colors.amberAccent,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContrastDichopticGameScreen())),
                ),
                const SizedBox(height: 10),
                _buildActionTile(
                  context,
                  title: 'Saccadic Hart Chart Trainer',
                  subtitle: 'Randomized letter matrix for saccadic speed, vergence jumps, and visual searching.',
                  icon: Icons.grid_view,
                  color: Colors.tealAccent,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HartChartScreen())),
                ),
                const SizedBox(height: 10),
                _buildActionTile(
                  context,
                  title: 'Amblyopia Occlusion Patching Tracker',
                  subtitle: 'Log daily patching hours, calendar compliance milestones, and rewards.',
                  icon: Icons.healing,
                  color: Colors.purpleAccent,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PatchingTrackerScreen())),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCol(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AppleGlassCard(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }
}
