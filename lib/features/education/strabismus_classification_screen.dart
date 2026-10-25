import 'package:flutter/material.dart';

class StrabismusClassificationScreen extends StatelessWidget {
  const StrabismusClassificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Strabismus Classification'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCategoryCard(
            title: '1. By Direction of Deviation',
            icon: Icons.swap_horiz,
            color: Colors.blue,
            items: [
              _Item('Esotropia / Esophoria', 'Inward nasal turning of the eye (convergent).'),
              _Item('Exotropia / Exophoria', 'Outward temporal turning of the eye (divergent).'),
              _Item('Hypertropia / Hypotropia', 'Vertical deviation: higher eye is hyper, lower eye is hypo.'),
              _Item('Incyclotropia / Excyclotropia', 'Torsional rotation about the anteroposterior visual axis (12 o\'clock cornea rotates nasally vs temporally).'),
            ],
          ),
          const SizedBox(height: 14),
          _buildCategoryCard(
            title: '2. By Fusion & Constancy',
            icon: Icons.visibility,
            color: Colors.teal,
            items: [
              _Item('Phoria (Latent)', 'Deviation kept aligned under normal binocular viewing conditions by motor fusion; only manifests when fusion is broken (e.g. cover test).'),
              _Item('Tropia (Manifest)', 'Deviation present under binocular viewing conditions; cannot be controlled by fusional convergence.'),
              _Item('Intermittent Strabismus', 'Spontaneously alternates between phoria (straight) and tropia (deviated), e.g. Intermittent Exotropia (IXT) during fatigue or daydreaming.'),
            ],
          ),
          const SizedBox(height: 14),
          _buildCategoryCard(
            title: '3. By Variation in Different Gazes',
            icon: Icons.grid_view,
            color: Colors.purple,
            items: [
              _Item('Concomitant (Comitant)', 'Angle of deviation remains identical (within 5Δ) in all 9 diagnostic positions of gaze and regardless of which eye fixates.'),
              _Item('Incomitant', 'Angle of deviation varies depending on direction of gaze or which eye is fixating (Primary vs Secondary deviation). Hallmark of paretic or restrictive strabismus.'),
              _Item('Primary vs Secondary Deviation', 'Secondary deviation (paretic eye fixating) is always GREATER than primary deviation (normal eye fixating) due to Hering\'s law of equal innervation.'),
            ],
          ),
          const SizedBox(height: 14),
          _buildCategoryCard(
            title: '4. Special Patterns & Syndromes',
            icon: Icons.auto_awesome,
            color: Colors.deepOrange,
            items: [
              _Item('A-Pattern', 'Deviation becomes more convergent in upgaze and more divergent in downgaze (difference ≥ 10Δ).'),
              _Item('V-Pattern', 'Deviation becomes more divergent in upgaze and more convergent in downgaze (difference ≥ 15Δ). Usually secondary to Inferior Oblique overaction.'),
              _Item('Duane Retraction Syndrome', 'Congenital cranial dysinnervation disorder (CCDD): Agenesis of CN VI with anomalous innervation of LR by CN III branches. Globe retraction and palpebral fissure narrowing on adduction.'),
              _Item('Brown Syndrome', 'Inability to elevate the adducted eye due to mechanical restriction of the Superior Oblique tendon through the trochlea.'),
              _Item('Thyroid Eye Disease (Graves)', 'Autoimmune extraocular muscle fibrosis (Inferior Rectus most commonly affected, causing restrictive hypotropia).'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required IconData icon,
    required MaterialColor color,
    required List<_Item> items,
  }) {
    return Card(
      elevation: 2,
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: CircleAvatar(backgroundColor: color.shade100, foregroundColor: color.shade800, child: Icon(icon)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        children: items.map((it) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(it.term, style: TextStyle(fontWeight: FontWeight.bold, color: color.shade900, fontSize: 13)),
              const SizedBox(height: 2),
              Text(it.definition, style: const TextStyle(fontSize: 12, color: Colors.black87)),
              const Divider(height: 12),
            ],
          ),
        )).toList(),
      ),
    );
  }
}

class _Item {
  final String term;
  final String definition;
  _Item(this.term, this.definition);
}
