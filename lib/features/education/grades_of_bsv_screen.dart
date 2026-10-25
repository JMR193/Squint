import 'package:flutter/material.dart';

class GradesOfBsvScreen extends StatelessWidget {
  const GradesOfBsvScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Worth\'s 3 Grades of BSV'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildGradeCard(
            context,
            gradeNumber: '1',
            title: 'Simultaneous Macular Perception (SMP)',
            subtitle: 'The ability of the brain to perceive two dissimilar images simultaneously, one from each eye.',
            color: Colors.blue,
            icon: Icons.filter_1,
            tests: 'Synoptophore with dissimilar slide pairs (e.g., Bird in right eye, Cage in left eye; Lion in right eye, Cage in left eye).',
            clinicalPoints: [
              'Tests whether both foveas are transmitting visual input to the visual cortex at the same time.',
              'Suppression: Patient sees only the bird OR only the cage, never both.',
              'Abnormal Retinal Correspondence (ARC): Patient places bird inside cage at an objective angle different from their subjective angle.',
            ],
          ),
          const SizedBox(height: 16),
          _buildGradeCard(
            context,
            gradeNumber: '2',
            title: 'True Fusion with Motor Amplitude',
            subtitle: 'The cerebral integration of two similar images with incomplete complementary details into a single sensory percept.',
            color: Colors.teal,
            icon: Icons.filter_2,
            tests: 'Worth 4-Dot Test, Bagolini Striated Glasses, Synoptophore fusion slides (e.g., Rabbit with ears on left, Rabbit with tail on right).',
            clinicalPoints: [
              'Sensory Fusion: Blending the two images into one complete rabbit (with both ears and tail).',
              'Motor Fusion: Ability to maintain alignment during convergence and divergence using prism bars.',
              'Normal Fusional Reserves: Convergence 25-35Δ (near), 15-20Δ (distance); Divergence 6-8Δ (distance), 12-14Δ (near).',
            ],
          ),
          const SizedBox(height: 16),
          _buildGradeCard(
            context,
            gradeNumber: '3',
            title: 'Stereopsis (3D Depth Perception)',
            subtitle: 'Highest grade of binocular vision: True binocular perception of depth based on horizontal retinal image disparity.',
            color: Colors.deepPurple,
            icon: Icons.filter_3,
            tests: 'Titmus Stereo Test (Fly, Animals, Wirt Rings), TNO Random Dot Test, Frisby Stereotest, Lang Stereotest.',
            clinicalPoints: [
              'Measured in seconds of arc (arcsec).',
              'Normal Stereopsis: 40 seconds of arc or better (resolving Wirt Ring #9).',
              'Gross Stereopsis: 3000 arcsec (Titmus Fly wings).',
              'Random Dot Stereograms (TNO/Lang) eliminate monocular contours and test pure bifoveal cyclopean stereopsis.',
            ],
          ),
          const SizedBox(height: 16),
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sensory Adaptations to Strabismus', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onPrimaryContainer)),
                  const SizedBox(height: 8),
                  const Text('1. Suppression: Active cortical inhibition of the deviating eye\'s visual field to eliminate diplopia and visual confusion.'),
                  const SizedBox(height: 4),
                  const Text('2. Abnormal Retinal Correspondence (ARC): Pseudo-fovea develops where an extrafoveal retinal point of the squinting eye acquires common visual direction with the fovea of the fixing eye.'),
                  const SizedBox(height: 4),
                  const Text('3. Amblyopia: Unilateral or bilateral reduction of visual acuity caused by form vision deprivation or abnormal binocular interaction during the sensitive visual development period (birth to 7-8 years).'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeCard(
    BuildContext context, {
    required String gradeNumber,
    required String title,
    required String subtitle,
    required MaterialColor color,
    required IconData icon,
    required String tests,
    required List<String> clinicalPoints,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.shade100,
                  foregroundColor: color.shade800,
                  child: Icon(icon),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('GRADE $gradeNumber', style: TextStyle(fontWeight: FontWeight.bold, color: color.shade700, fontSize: 12, letterSpacing: 1.2)),
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(subtitle, style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
            const Divider(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Clinical Tests: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Expanded(child: Text(tests, style: const TextStyle(fontSize: 12))),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Key Diagnostic Features:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 4),
            ...clinicalPoints.map((pt) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(child: Text(pt, style: const TextStyle(fontSize: 12))),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
