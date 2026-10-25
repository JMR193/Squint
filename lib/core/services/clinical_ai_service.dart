class OfflineClinicalAiService {
  static final List<Map<String, dynamic>> _knowledgeBase = [
    {
      'keywords': ['cn3', 'cranial nerve 3', 'oculomotor', 'blown pupil', 'down and out', 'ptosis'],
      'title': 'Cranial Nerve III (Oculomotor) Palsy',
      'response': 'CN III Palsy Clinical Assessment:\n\n'
          '• Presentation: Ptosis, "down-and-out" eye position (unopposed LR & SO).\n'
          '• Pupil-Involving (Dilated/Blown Pupil): Surgical emergency! Indicates compressive lesion (e.g. PCOM Aneurysm or uncal herniation). Immediate CTA/MRA required.\n'
          '• Pupil-Sparing: Typically microvascular ischemia (diabetic/hypertensive mononeuropathy). Pupil parasympathetics run on the outer rim of the nerve and are spared in ischemic infarction.',
    },
    {
      'keywords': ['cn4', 'trochlear', 'superior oblique', 'head tilt', 'bielschowsky'],
      'title': 'Cranial Nerve IV (Trochlear) Palsy',
      'response': 'CN IV Palsy Clinical Assessment:\n\n'
          '• Most common cause of isolated vertical diplopia.\n'
          '• Positive Bielschowsky 3-Step Test: Hypertropia increases on contralateral gaze and ipsilateral head tilt.\n'
          '• Bilateral CN IV Sign: V-pattern esotropia in downgaze, alternating hypertropia on head tilt, and >10° excyclotorsion on Double Maddox Rod.\n'
          '• Surgical Option: Harada-Ito procedure for excyclotorsion or IO recession for IO overaction.',
    },
    {
      'keywords': ['cn6', 'abducens', 'lateral rectus', 'abduction'],
      'title': 'Cranial Nerve VI (Abducens) Palsy',
      'response': 'CN VI Palsy Clinical Assessment:\n\n'
          '• Presentation: Inability to abduct eye past midline; uncrossed horizontal diplopia at distance.\n'
          '• Etiology: Longest intracranial course makes it vulnerable to raised ICP ("false localizing sign"). Also trauma or microvascular ischemia.\n'
          '• Management: Patching/fresnel prism for diplopia; surgical transposition (Foster/Jensen) or LR recession if non-recovering after 6 months.',
    },
    {
      'keywords': ['ino', 'internuclear', 'mlf', 'adduction deficit', 'nystagmus'],
      'title': 'Internuclear Ophthalmoplegia (INO)',
      'response': 'INO Clinical Assessment:\n\n'
          '• Lesion: Medial Longitudinal Fasciculus (MLF).\n'
          '• Presentation: Failure of ipsilateral eye adduction in horizontal gaze + dissociated monocular horizontal jerk nystagmus in abducting fellow eye.\n'
          '• Convergence is typically preserved because convergence pathways bypass the MLF.\n'
          '• Etiology: Multiple Sclerosis (young patients, often bilateral) or Brainstem Stroke (elderly, unilateral).',
    },
    {
      'keywords': ['horner', 'sympathetic', 'ptosis', 'miosis', 'anhidrosis'],
      'title': 'Horner Syndrome',
      'response': 'Horner Syndrome Triad:\n\n'
          '1. Mild partial ptosis (Müller\'s muscle paresis).\n'
          '2. Miosis (pupillary dilator paresis; anisocoria worse in dark).\n'
          '3. Anhidrosis (facial anhidrosis if 1st or 2nd order neuron lesion).\n'
          '• Diagnostic Confirmation: Topical Cocaine 10% (fails to dilate Horner pupil) or Apraclonidine 0.5% (reverses anisocoria due to denervation supersensitivity).\n'
          '• Localization: Hydroxyamphetamine 1% (dilates 1st/2nd order, fails in 3rd order postganglionic).',
    },
    {
      'keywords': ['dichoptic', 'amblyopia', 'patching', 'contrast', 'suppression'],
      'title': 'Dichoptic Digital Therapeutics & Suppression',
      'response': 'Dichoptic Therapy Protocol:\n\n'
          '• Anti-Suppression Mechanism: Amblyopia is a binocular visual cortex suppression disorder.\n'
          '• Dynamic Contrast Penalization (DCP): Presents 100% contrast essential targets to amblyopic eye, while attenuating fellow eye contrast (10%-40%).\n'
          '• Re-establishes binocular summation and stereopsis without physical monocular patching.',
    },
    {
      'keywords': ['kestenbaum', 'nystagmus', 'null point', 'head turn'],
      'title': 'Kestenbaum-Anderson Nystagmus Surgery',
      'response': 'Kestenbaum Surgical Dosing:\n\n'
          '• Purpose: Shift globes in direction of abnormal head turn (AHP) to align nystagmus null zone with primary gaze.\n'
          '• Parks Rule of 5-6-7-8:\n'
          '  - Turn Right: Recess RMR 5mm, Resect RLR 8mm; Recess LLR 7mm, Resect LMR 6mm.\n'
          '  - Turn Left: Recess RLR 7mm, Resect RMR 6mm; Recess LMR 5mm, Resect LLR 8mm.\n'
          '• Augmented (+40%-60%) dosing is recommended for face turns >30°.',
    },
  ];

  static String queryOfflineKb(String prompt) {
    final cleanPrompt = prompt.toLowerCase();

    for (final entry in _knowledgeBase) {
      final List<String> keywords = List<String>.from(entry['keywords']);
      for (final kw in keywords) {
        if (cleanPrompt.contains(kw)) {
          return entry['response'];
        }
      }
    }

    return 'Clinical AI Assistant (Offline Mode):\n\n'
        'I analyzed your query regarding strabismus / neuro-ophthalmology.\n'
        'For best diagnostic insights, try asking about:\n'
        '• "CN III / IV / VI Palsy" or "Pupil sparing"\n'
        '• "INO" or "MLF lesion"\n'
        '• "Horner Syndrome" or "Marcus Gunn RAPD"\n'
        '• "Dichoptic contrast therapy"\n'
        '• "Kestenbaum nystagmus dosing"';
  }
}
