import 'package:flutter/material.dart';

class MuscleAnatomyScreen extends StatelessWidget {
  const MuscleAnatomyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extraocular Muscle Anatomy'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSummaryCard(context),
          const SizedBox(height: 16),
          const Text('Spiral of Tillaux (Insertion Distances from Limbus)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          _buildSpiralCard(context),
          const SizedBox(height: 16),
          const Text('Extraocular Muscles Table', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          _buildMuscleTile('Medial Rectus (MR)', 'Adduction', 'None', 'CN III (Inferior division)', '5.5 mm', Colors.blue),
          _buildMuscleTile('Lateral Rectus (LR)', 'Abduction', 'None', 'CN VI (Abducens)', '6.9 mm', Colors.indigo),
          _buildMuscleTile('Superior Rectus (SR)', 'Elevation (in abduction)', 'Incyclotorsion, Adduction', 'CN III (Superior division)', '7.7 mm', Colors.green),
          _buildMuscleTile('Inferior Rectus (IR)', 'Depression (in abduction)', 'Excyclotorsion, Adduction', 'CN III (Inferior division)', '6.5 mm', Colors.teal),
          _buildMuscleTile('Superior Oblique (SO)', 'Incyclotorsion', 'Depression (in adduction), Abduction', 'CN IV (Trochlear)', 'Posterior to equator', Colors.purple),
          _buildMuscleTile('Inferior Oblique (IO)', 'Excyclotorsion', 'Elevation (in adduction), Abduction', 'CN III (Inferior division)', 'Posterior/Macular region', Colors.deepOrange),
          const SizedBox(height: 16),
          _buildLawsCard(context),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Innervation Mnemonic: LR6(SO4)3', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onPrimaryContainer)),
            const SizedBox(height: 6),
            const Text('• Lateral Rectus is innervated by Cranial Nerve VI (Abducens).'),
            const Text('• Superior Oblique is innervated by Cranial Nerve IV (Trochlear).'),
            const Text('• All other 4 extraocular muscles (MR, SR, IR, IO) plus Levator Palpebrae Superioris are innervated by Cranial Nerve III (Oculomotor).'),
          ],
        ),
      ),
    );
  }

  Widget _buildSpiralCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'The rectus muscle insertions form a clockwise ascending spiral starting at the medial rectus (closest to limbus) to the superior rectus (farthest):',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSpiralStep('MR', '5.5 mm'),
                const Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
                _buildSpiralStep('IR', '6.5 mm'),
                const Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
                _buildSpiralStep('LR', '6.9 mm'),
                const Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
                _buildSpiralStep('SR', '7.7 mm'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpiralStep(String muscle, String dist) {
    return Column(
      children: [
        CircleAvatar(radius: 18, child: Text(muscle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
        const SizedBox(height: 4),
        Text(dist, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
      ],
    );
  }

  Widget _buildMuscleTile(String name, String primary, String secondary, String nerve, String insertion, MaterialColor color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: CircleAvatar(backgroundColor: color.shade100, foregroundColor: color.shade800, child: const Icon(Icons.fitness_center, size: 18)),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text('Primary Action: $primary', style: const TextStyle(fontSize: 12)),
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Secondary / Tertiary Actions: $secondary', style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                Text('Cranial Nerve: $nerve', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Distance from Limbus: $insertion', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLawsCard(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Physiological Laws of Ocular Motility', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            SizedBox(height: 8),
            Text('1. Hering\'s Law of Equal Innervation:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text('During any conjugate eye movement, equal and simultaneous innervation flows to the yoke muscles of both eyes (e.g. Right LR and Left MR during dextroversion). Explains why secondary deviation > primary deviation in paretic squint.', style: TextStyle(fontSize: 12)),
            SizedBox(height: 8),
            Text('2. Sherrington\'s Law of Reciprocal Innervation:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text('Whenever an agonist muscle receives an excitatory impulse to contract, its ipsilateral antagonist muscle receives an equivalent inhibitory impulse to relax (e.g. When Right MR contracts, Right LR relaxes). Co-contraction occurs abnormally in Duane syndrome.', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
