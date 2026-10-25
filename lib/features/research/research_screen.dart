import 'package:flutter/material.dart';

class ResearchStudy {
  final String title;
  final String trialName;
  final String year;
  final String journal;
  final String objective;
  final String keyFindings;
  final String clinicalImplication;
  final String category;

  const ResearchStudy({
    required this.title,
    required this.trialName,
    required this.year,
    required this.journal,
    required this.objective,
    required this.keyFindings,
    required this.clinicalImplication,
    required this.category,
  });
}

class ResearchScreen extends StatefulWidget {
  const ResearchScreen({super.key});

  @override
  State<ResearchScreen> createState() => _ResearchScreenState();
}

class _ResearchScreenState extends State<ResearchScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<ResearchStudy> _studies = const [
    ResearchStudy(
      trialName: 'PEDIG ATS-1',
      year: '2002',
      journal: 'Ophthalmology',
      title: 'Patching vs. Atropine for Moderate Amblyopia in Children (3 to <7 Years)',
      objective: 'To compare occlusion therapy (patching for ≥6 hours/day) with pharmacological penalization (1 drop 1% atropine daily).',
      keyFindings: 'Visual acuity improved by an average of 3.16 lines in the patching group and 2.84 lines in the atropine group. At 6 months and 2 years, visual outcomes were statistically and clinically equivalent.',
      clinicalImplication: 'Daily atropine is an equally effective first-line therapy to patching for moderate amblyopia (20/40 to 20/100) and offers superior treatment compliance.',
      category: 'Amblyopia',
    ),
    ResearchStudy(
      trialName: 'PEDIG ATS-2B',
      year: '2003',
      journal: 'Arch Ophthalmol',
      title: 'Two Hours vs. Six Hours of Daily Patching for Moderate Amblyopia',
      objective: 'To determine whether 2 hours of daily patching is as effective as 6 hours for children aged 3 to 7 with moderate amblyopia.',
      keyFindings: 'Visual acuity improvement after 4 months was 2.40 lines in the 2-hour group vs 2.39 lines in the 6-hour group.',
      clinicalImplication: 'Two hours of prescribed daily patching achieves visual acuity improvement of similar magnitude to 6 hours, vastly improving child quality of life and parent adherence.',
      category: 'Amblyopia',
    ),
    ResearchStudy(
      trialName: 'PEDIG ATS-2A',
      year: '2003',
      journal: 'Ophthalmology',
      title: 'Full-time vs. Six Hours of Daily Patching for Severe Amblyopia',
      objective: 'To evaluate full-time patching (all waking hours except 1) vs. 6 hours/day for severe amblyopia (20/100 to 20/400).',
      keyFindings: 'Both groups demonstrated identical visual improvement: 4.8 lines in the 6-hour group vs 4.7 lines in the full-time group.',
      clinicalImplication: 'Severe amblyopia does not require traumatic full-time occlusion; 6 hours daily is equally efficacious.',
      category: 'Amblyopia',
    ),
    ResearchStudy(
      trialName: 'CITT Study',
      year: '2008',
      journal: 'Arch Ophthalmol',
      title: 'Convergence Insufficiency Treatment Trial (CITT)',
      objective: 'To compare office-based vergence/accommodative therapy with home-based computer therapy, home-based pencil push-ups, and placebo therapy.',
      keyFindings: 'Office-based vision therapy resulted in 73% success/improvement rate, significantly superior to home pencil push-ups (43%) and placebo (35%).',
      clinicalImplication: 'Office-based vergence/accommodative therapy with home reinforcement is the gold-standard treatment for symptomatic convergence insufficiency in children.',
      category: 'Binocular Vision',
    ),
    ResearchStudy(
      trialName: 'PEDIG ATS-3',
      year: '2005',
      journal: 'Arch Ophthalmol',
      title: 'Treatment of Amblyopia in Children Aged 7 to 17 Years',
      objective: 'To assess the efficacy of amblyopia treatment in older children and adolescents.',
      keyFindings: 'Treatment with patching (2-6 hours/day) with or without optical correction improved visual acuity in 53% of children aged 7-12, and in 25% of adolescents aged 13-17 not previously treated.',
      clinicalImplication: 'Neural visual plasticity persists beyond the traditional "critical period". Older children and teenagers should be offered an amblyopia treatment trial.',
      category: 'Amblyopia',
    ),
    ResearchStudy(
      trialName: 'IXT Study (PEDIG)',
      year: '2019',
      journal: 'JAMA Ophthalmol',
      title: 'Part-Time Patching vs. Observation for Intermittent Exotropia in Children',
      objective: 'To determine whether part-time patching (3 hours/day) reduces the rate of deterioration in untreated basic or divergence excess IXT.',
      keyFindings: 'Deterioration rate at 6 months was low in both groups (0.6% in patching vs 6.1% in observation). At 3 years, surgical rates and sensory status were similar.',
      clinicalImplication: 'Observation without active patching is an acceptable initial management strategy for children 12 to 35 months with intermittent exotropia.',
      category: 'Strabismus',
    ),
    ResearchStudy(
      trialName: 'Botox vs Incisional Surgery',
      year: '2017',
      journal: 'Cochrane Database',
      title: 'Botulinum Toxin for Strabismus Management in Infantile and Adult Esotropia',
      objective: 'To evaluate the efficacy of Botulinum toxin type A injection into the medial rectus vs. surgical recession.',
      keyFindings: 'Botox injection showed comparable success rates in small-to-moderate angle deviations (<30Δ) and acute 6th nerve palsies, with faster recovery but higher re-injection rate.',
      clinicalImplication: 'Botox is an outstanding alternative in acute abducens palsy and small-angle infantile esotropia where general anesthesia carries risks.',
      category: 'Surgery',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final categories = ['All', 'Amblyopia', 'Binocular Vision', 'Strabismus', 'Surgery'];

    final filtered = _studies.where((s) {
      final matchesCat = _selectedCategory == 'All' || s.category == _selectedCategory;
      final matchesQuery = _searchQuery.isEmpty ||
          s.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.trialName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.keyFindings.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesQuery;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Landmark Clinical Trials'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search PEDIG, CITT, ATS, surgery trials...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                isDense: true,
              ),
              onChanged: (q) => setState(() => _searchQuery = q),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: categories.map((c) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(c),
                    selected: _selectedCategory == c,
                    onSelected: (v) => setState(() => _selectedCategory = c),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final st = filtered[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 1.5,
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                      child: const Icon(Icons.science, size: 20),
                    ),
                    title: Text(st.trialName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    subtitle: Text('${st.journal} (${st.year}) • ${st.category}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(st.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 8),
                            _buildField('Trial Objective:', st.objective),
                            const SizedBox(height: 8),
                            _buildField('Key Results:', st.keyFindings),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: _buildField('Clinical Practice Takeaway:', st.clinicalImplication),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blueGrey)),
        const SizedBox(height: 2),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
