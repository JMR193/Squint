import 'package:flutter/material.dart';
import '../../core/widgets/custom_ui_components.dart';
import 'flowcharts_screen.dart';
import 'conditions_screen.dart';
import 'grades_of_bsv_screen.dart';
import 'strabismus_classification_screen.dart';
import 'muscle_anatomy_screen.dart';
import 'case_quizzes_screen.dart';

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Educational Library & Clinical Knowledge'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SamsungOneUiGroupCard(
            title: 'CLINICAL CASE VIGNETTES & QUIZ LAB',
            icon: Icons.quiz,
            child: Column(
              children: [
                _buildEduTile(
                  context,
                  title: 'Interactive Clinical Case Quiz Bank',
                  description: '10 real-world patient vignettes with 9-gaze motility, differential diagnosis & rationales.',
                  icon: Icons.psychology,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CaseQuizzesScreen())),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SamsungOneUiGroupCard(
            title: 'ORTHOPTIC FUNDAMENTALS',
            icon: Icons.menu_book,
            child: Column(
              children: [
                _buildEduTile(
                  context,
                  title: 'Grades of Binocular Single Vision (BSV)',
                  description: 'Simultaneous Perception, Fusion, Stereopsis & adaptations.',
                  icon: Icons.auto_stories,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GradesOfBsvScreen())),
                ),
                const SizedBox(height: 10),
                _buildEduTile(
                  context,
                  title: 'Strabismus Classification',
                  description: 'Concomitant vs. Incomitant, Restrictive, Paralytic, A/V patterns.',
                  icon: Icons.category,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StrabismusClassificationScreen())),
                ),
              ],
            ),
          ),
          SamsungOneUiGroupCard(
            title: 'CLINICAL ENCYCLOPEDIA & ANATOMY',
            icon: Icons.menu_book,
            child: Column(
              children: [
                _buildEduTile(
                  context,
                  title: 'Clinical Encyclopedia',
                  description: 'Searchable conditions database, symptoms & clinical pearls.',
                  icon: Icons.menu_book,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConditionsScreen())),
                ),
                const SizedBox(height: 10),
                _buildEduTile(
                  context,
                  title: 'Clinical Flowcharts',
                  description: 'Interactive decision trees for pediatric & adult strabismus.',
                  icon: Icons.account_tree,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FlowchartsScreen())),
                ),
                const SizedBox(height: 10),
                _buildEduTile(
                  context,
                  title: 'Extraocular Muscle Anatomy',
                  description: 'Spiral of Tillaux, origins, insertions, actions & innervation laws.',
                  icon: Icons.accessibility_new,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MuscleAnatomyScreen())),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEduTile(BuildContext context, {required String title, required String description, required IconData icon, required VoidCallback onTap}) {
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

