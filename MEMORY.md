# SQUINT & STRABISMUS CLINICAL SUITE - MEMORY & ARCHITECTURE

## 1. Project Overview
A production-grade, offline-first clinical ophthalmology, strabismus, and neuro-ophthalmology mobile application built with Flutter & Dart. It serves ophthalmologists, strabismologists, orthoptists, pediatric optometrists, and medical residents.

## 2. Tech Stack & Key Dependencies
- **Framework:** Flutter 3.x / Dart 3.x
- **State Management & Architecture:** Layered Architecture (UI, Logic/Controllers, Services/Data). Provider + SharedPreferences.
- **UI Design System:** Hybrid Material 3 + Apple iOS Glassmorphic Cards + Samsung One UI 7 grouped card system with fluid animations and responsive layout.
- **Theme & Display Customizer (`ThemeProvider` & `AppTheme`):**
  - Theme Modes: Clean Light, Cyber Dark, AMOLED Pure Black (`#000000`), System Auto.
  - Accent Color Palettes: Cyan Neon, Electric Blue, Emerald Green, Royal Purple, Coral Orange.
  - High-Contrast Accessibility (a11y) Mode.
  - Text Scaling slider (85% to 125%).
- **Data Persistence:** Offline-first encrypted `SharedPreferences` serialization with backward-compatible JSON schema fallbacks.

## 3. Core Clinical Modules & Screen Matrix

### A. Simulators & Visual Physiology (`lib/features/simulators/`)
1. **Interactive 3D Eye Motility Simulator (`EyeSimulatorScreen` / `UnitySimulatorScreen`):**
   - 9 Diagnostic Gazes (Primary, Dextro-, Levo-, Sursum-, Deorsumversion, etc.)
   - Hering's Law of Equal Innervation & Sherrington's Law of Reciprocal Innervation
   - Cranial Nerve Palsies (CN III with/without pupil sparing, CN IV with Parks-Bielschowsky 3-step, CN VI with lateral rectus deficit)
   - Real-time physiological blinking loop & smooth saccadic interpolation
2. **Visual Pathway & Lesion Simulator (`VisualPathwaysSimulatorScreen`):**
   - Visual field defect generator (Bitemporal hemianopia, homonymous hemianopia with/without macular sparing, junctional scotoma, quadrantanopia).
3. **Pupillary Light Reflex & Neuro-Ophtho Lab (`NeuroOphthoSimulatorScreen`):**
   - Direct and consensual light response with Relative Afferent Pupillary Defect (RAPD / Marcus Gunn pupil), Horner's syndrome, and Argyll Robertson pupils.
4. **4-Mirror Gonioscopy & Angle Grading Lab (`GonioscopySimulatorScreen`):**
   - 4-Mirror Goldmann / Zeiss slit-lamp simulation with quadrant selection (Inferior, Superior, Nasal, Temporal).
   - Dynamic Zeiss Indentation gonioscopy physics (opens appositional closure).
   - Corneal Optical Wedge visualization (internal/external beam reflection converging at Schwalbe's line).
   - Cross-sectional chamber depth / Van Herick correlation view.
   - Comprehensive pathology models: Normal Shaffer 4, PACG, Pigment Dispersion (Sampaolesi line), Pseudoexfoliation (flake deposits), Traumatic Angle Recession (widened CBB), Neovascular Glaucoma (rubeosis), Plateau Iris (double-hump sign), ICE syndrome (broad PAS), Blood in Schlemm's canal (elevated EVP).

### B. Clinical Psychophysics & Testing Labs (`lib/features/tests/`)
1. **Digital Visual Acuity & Optotype Chart (`VisualAcuityChartScreen`):**
   - Optotypes: Snellen, Sloan Letters, Tumbling E (with directional rotation), Lea Pediatric Symbols (Circle, House, Apple, Square), and Numeric optotypes.
   - Multi-Metric Display: Snellen 20ft, Metric 6m, LogMAR, and Decimal conversions.
   - Amblyopia Crowding Bars Mode: Isolates contour interaction for sensitive amblyopia screening.
   - Red-Green Duochrome (Bichrome) Filter Split: Spherical refraction endpoint refinement.
   - 1-tap direct export to Patient Records Database.
2. **Hess / Lees Screen Motility Tangent Chart (`HessScreenSimulator`):**
   - Red-Green complementary glasses dissociation.
   - Inner 15° and Outer 30° tangent screen grid.
   - Vector plotting for paretic muscle underaction vs yoke muscle overaction (Hering's law).
   - Presets for CN VI palsy, CN IV palsy (Parks 3-step), CN III palsy, Blowout Fracture IR entrapment, and Duane Syndrome Type 1.
3. **Color Vision & Ishihara Plate Lab (`ColorVisionSimulatorScreen`):**
   - Pseudoisochromatic dot matrix generator for transformation, vanishing, and diagnostic plates.
   - Color deficiency simulators: Protanopia, Deuteranopia, Tritanopia, Achromatopsia.
   - Early Optic Neuritis Red Desaturation detector.
   - 1-tap direct export to Patient Records Database.

### C. Clinical Calculators & Surgical Planning (`lib/features/calculators/`)
1. **Strabismus Surgical Dose-Response Calculator (`SurgicalCalculatorScreen`):**
   - Parks, Helveston, and Wright surgical dose tables for Horizontal (MRc/LRr, LRc/MRr) and Vertical Rectus muscles.
   - A/V Pattern strabismus offsets (Slanted/transposed insertions).
   - Adjustable suture recommendations.
2. **AC/A Ratio & Convergence Workup (`AcaCalculatorScreen`):**
   - Heterophoria and Gradient AC/A ratio calculations with bifocal add suggestions.
3. **Prism Adaptation & Optical Neutralization (`PrismCalculatorScreen`):**
   - Fresnel and ground-in prism calculations with vector summation (horizontal + vertical resultant).

### D. Vision Therapy Hub (`lib/features/therapy/`)
1. **Convergence / Divergence Trainer (`ConvergenceTrainerScreen`):**
   - Dynamic stereogram & vergence target stepped exercise with distance accommodation.
2. **Brock String 3D Simulator (`BrockStringScreen`):**
   - Physiological diplopia feedback (X-pattern crossing at fixation bead).
3. **Anti-Suppression Bar Reader & Red-Green Fusion (`BarReaderScreen`):**
   - Visual stimulation preventing amblyogenic cortical suppression.
4. **Saccadic & Pursuit Dynamic Trainer (`SaccadePursuitTrainerScreen`):**
   - Randomized jumping targets and smooth pursuit tracking with compliance timer.
5. **Patching Compliance & Therapy Hub (`TherapyHubScreen`):**
   - Daily streak tracker, +30m occlusion logging, and progress metrics.

### E. Educational Lab & Case Vignettes (`lib/features/education/`)
1. **Interactive Case Vignettes & Board Quiz (`CaseQuizzesScreen`):**
   - 10 real-world clinical case vignettes spanning pediatric strabismus, cranial nerve palsies, myasthenia gravis, Brown syndrome, Duane retraction syndrome, and angle closure.
   - Image-based motility findings, differential diagnoses, rationales, and clinical pearls.
2. **Extraocular Muscle Anatomy 3D Explorer (`MuscleAnatomyScreen`):**
   - Origins, insertions, primary/secondary/tertiary muscle actions, and blood supply.

### F. Patient Exam Records & Screening (`lib/features/records/` & `lib/features/screening/`)
1. **Digital Hirschberg & Krimsky Test (`HirschbergTestScreen`):**
   - Corneal light reflex screening with animated pediatric fixation targets.
   - 1-tap direct export to Patient Records Database.
2. **Clinical Records Database (`PatientRecordsScreen` & `ClinicalDatabaseService`):**
   - Offline local database with search, stats, filter by diagnosis, and formatted clinical referral letters export.

### G. Pediatric Fixation & Vision Mascots (`lib/features/pediatrics/`)
1. **Pediatric Fixation Character Studio (`PediatricFixationCharacterScreen`):**
   - Animated mascots: Dr. Iris (Wise Owl with animated wing flutter), Sparky (Playful Fox with tail wag), and Barnaby (Gentle Bear with ear wiggle).
   - Teller preferential looking gratings and high-contrast acuity targets.
   - Interactive screen touch particle bursts with clinical cheer feedback.
   - 9-position fixation tracking with gaze hold timer and success counter.

### H. 3D Raytraced Orbital Simulation & Orthoptic Studio (`lib/features/simulators/`)
1. **Hyper-Realistic 3D Orbital Eye Model (`RealisticEye3dScreen`):**
   - Dynamic CustomPainter raytraced corneal specular glint reflections and radial iris stroma crypts.
   - Direct torchlight pupillary light reflex slider (2.0mm to 8.0mm dynamic constriction).
   - 6 Extraocular Muscle (EOM) biomechanical tension vectors (% load) reacting to 9 diagnostic gazes.
   - Anterior orbital anatomy, biomechanical muscle vector, and posterior fundus perspectives.
2. **3D Cover Test & Virtual Prism Bar Neutralization (`CoverTest3dStudioScreen`):**
   - Unilateral cover test (manifest tropia detection), alternate cover test (total deviation), and uncover test (latent phoria recovery).
   - Animated 3D occluder paddle with variable occlusion speed.
   - Virtual prism bar (Base-In, Base-Out, Base-Up, Base-Down) neutralization engine with refixation saccades.

## 4. Multi-Language Localization Engine (`lib/core/localization/language_provider.dart`)
- Instant switching across 8 major global languages:
  - English (EN 🇺🇸)
  - Spanish (ES 🇪🇸)
  - French (FR 🇫🇷)
  - German (DE 🇩🇪)
  - Chinese Simplified (ZH 🇨🇳)
  - Hindi (HI 🇮🇳)
  - Arabic (AR 🇸🇦)
  - Japanese (JA 🇯🇵)
- Provides real-time UI dictionary translation for clinical headers, actions, diagnoses, and test labels.

## 5. Settings & About System (`lib/features/settings/`)
- **Settings Screen (`SettingsScreen`):**
  - Global Localization 8-language choice chip selector.
  - Theme mode selector (Light, Dark, AMOLED Pure Black, System).
  - Accent Color picker (Cyan, Blue, Emerald, Purple, Orange).
  - High-contrast accessibility switch & Font scaling slider.
  - Haptic feedback & Student learning mode toggles.
  - Database purge with safety confirmation modal.
- **About Screen (`AboutScreen`):**
  - Version 3.0.0 Pro Enterprise metadata.
  - Regulatory clinical disclaimer & scope of practice.
  - Full module matrix breakdown including 3D Anatomy, Cover Test, and Pediatric Mascots.
  - Apache License 2.0 and third-party license viewers.
  - Apache License 2.0 and third-party open-source credits.

## 6. Build & Engine Configuration Upgrades
- **Android Gradle Version:** Upgraded to Gradle `9.3.1-all.zip` (aligned with Flutter 3.47.5 minimum requirement of 8.14.0+).
- **Android Gradle Plugin (AGP):** Configured to `9.1.0` with `android.newDsl=false`.
- **Kotlin Gradle Plugin (KGP):** Configured to `2.4.0` with JVM 17 target compatibility.
- **PreToolUse Telemetry Hook:** Fixed `hooks.json` to prevent subshell command timeouts on Windows.

## 7. Clinical Simulators Optimization & Deduplication Matrix
- **Deduplicated Screens Removed:**
  - `cover_test_screen.dart` (obsolete 2D prototype) -> consolidated into `CoverTest3dStudioScreen`.
  - `hess_screen.dart` (obsolete flat prototype) -> consolidated into `HessScreenSimulator`.
  - `bsv_simulator_screen.dart` (obsolete 140-line prototype) -> consolidated into `WorthFourDotScreen`.
  - `advanced_simulator_screen.dart` & `widgets/eye_model_painter.dart` (orphaned legacy prototypes) -> removed.
- **Distortion-Free Aspect Ratio Engine:**
  - `HessScreenSimulator`: Enclosed canvas in strict `1:1` `AspectRatio` and `ConstrainedBox(maxWidth: 360)` to preserve authentic tangent geometry across tablets and phones.
  - `AmslerGridScreen`: Enclosed canvas in `1:1` `AspectRatio` and `ConstrainedBox(maxWidth: 340)` preventing metamorphopsia canvas distortion.
  - `SchoberTestScreen`: Applied `1:1` `AspectRatio` constraint to concentric green circles and red cross displacement canvas.
  - `CoverTest3dStudioScreen`: Applied `3:2` binocular aspect ratio constraint to 3D ocular stage.
  - `GonioscopySimulatorScreen`: Applied `1:1` circular aperture aspect ratio constraint to Goldmann slit-lamp mirror.
  - `RealisticEye3dScreen`: Applied `1:1` viewport aspect ratio constraint to raytraced 3D globe.
  - `OknDrumScreen`: Enclosed moving stripe canvas in controlled tablet width constraint.
