# 👁️ Squint & Strabismus Pro — Clinical Ophthalmology & Smart Optometry Suite

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Android](https://img.shields.io/badge/Android-SDK%2035-3DDC84?logo=android&logoColor=white)](https://developer.android.com)
[![Gradle](https://img.shields.io/badge/Gradle-9.3.1-02303A?logo=gradle&logoColor=white)](https://gradle.org)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Offline-First](https://img.shields.io/badge/Database-100%25%20Offline-success)](#)
[![Languages](https://img.shields.io/badge/Languages-8%20Global%20Locales-orange)](#multi-language-localization)

A production-grade, offline-first mobile clinical suite engineered for **ophthalmologists, strabismologists, pediatric optometrists, orthoptists, and eye care residents**. 

Built with **Flutter & Dart**, this application combines hyper-realistic **3D orbital eye motility simulation**, a chairside **Smart Optometry screening suite (15 clinical tests)**, surgical dose-response calculators, neuro-ophthalmic tangent screen plotting, pediatric fixation mascots, and an encrypted offline patient database.

---

## 🌟 Key Features & Module Overview

```
                            ┌──────────────────────────────────────────────┐
                            │      SQUINT & STRABISMUS CLINICAL SUITE      │
                            └──────────────────────┬───────────────────────┘
                                                   │
         ┌───────────────────┬─────────────────────┼─────────────────────┬──────────────────┐
         │                   │                     │                     │                  │
┌────────▼────────┐ ┌────────▼─────────┐ ┌─────────▼──────────┐ ┌────────▼────────┐ ┌───────▼────────┐
│ SMART OPTOMETRY │ │ 3D ORBITAL LABS  │ │ SURGICAL & DOSING  │ │ VISION THERAPY  │ │ CLINICAL QUIZ &│
│ SCREENING SUITE │ │ & EYE SIMULATORS │ │    CALCULATORS     │ │   (DTx HUB)     │ │ PATIENT RECORDS│
└─────────────────┘ └──────────────────┘ └────────────────────┘ └─────────────────┘ └────────────────┘
```

---

### 1. 🔬 Smart Optometry Clinical Suite (Chairside Testing)

A complete digital optical screening arsenal calibrated for chairside examination without requiring bulky dedicated hardware:

- **Worth 4-Dot Test (W4D):** Near (33 cm / 6° visual angle) and Distance (6 m / 1.25° foveal angle) red-green dissociation test for fusion, suppression, and uncrossed/crossed diplopia. Direct 1-tap export to patient records.
- **Schober Test:** Concentric green rings with red cross target for horizontal (Eso/Exo) and vertical (Hyper/Hypo) phoria neutralization in prism diopters ($\Delta$).
- **Optokinetic Nystagmus (OKN) Drum:** Dynamic moving stripe canvas with variable angular velocity (0.2x–3.5x), spatial frequency selector (Broad, Standard, Fine stripes), and pediatric mascot targets (Stars, Owls, Smiley).
- **Amsler Grid & Maculopathy Canvas:** Standard 1, Red 3 (toxic optic neuropathy / early maculopathy), Diagonal 2, and Fine 7 charts with interactive touchscreen scotoma and metamorphopsia drawing.
- **Cobalt Blue Light & Wratten #12 Filter:** Fullscreen 450 nm blue illuminator with high-contrast Wratten #12 yellow filter toggle for tear film break-up time (TBUT), Seidel corneal perforation test, and RGP contact lens fluorescein pooling patterns.
- **Awaya New Aniseikonia Test (NAT):** Calibrated red-green semicircular bracket comparison measuring size disparity from 0.5% up to 24% with horizontal and vertical disparity modes and anisometropia prediction.
- **Accommodation & $\pm2.00\text{D}$ Flipper Lab:** Hofstetter age-expected amplitude formulas (Minimum, Average, Maximum), 60-second Binocular/Monocular Accommodative Facility (BAF/MAF) cycle counter, and Push-Up RAF Rule calculator.
- **Digital Visual Acuity & Optotype Chart:** Multi-optotype engine (Snellen, Sloan Letters, Tumbling E, Lea Pediatric Symbols, Numbers) supporting Snellen (20ft / 6m), LogMAR, and Decimal metrics, with Amblyopia Crowding Bars and Red-Green Duochrome endpoint refraction.
- **Color Vision & Ishihara Plate Lab:** High-fidelity pseudoisochromatic dot matrix simulating Protanopia, Deuteranopia, Tritanopia, Achromatopsia, and Optic Neuritis Red Desaturation detection.

---

### 2. 👁️ 3D Raytraced Orbital Motility & Pathology Simulators

- **Hyper-Realistic 3D Orbital Eye Model:**
  - Raytraced corneal specular glints and radial iris stroma crypts.
  - Interactive torchlight pupillary light reflex slider (2.0 mm to 8.0 mm dynamic constriction).
  - Real-time 6 Extraocular Muscle (EOM) biomechanical load vectors (% tension) reacting to 9 diagnostic gazes.
  - Layer views: Anterior orbital anatomy, Biomechanical muscle vectors, and Posterior retinal fundus.
- **3D Cover Test & Virtual Prism Bar Studio:**
  - Unilateral cover test (manifest tropia detection), alternate cover test (latent phoria unmasking), and uncover recovery test.
  - Animated 3D occluder paddle with variable occlusion timing.
  - Virtual Prism Bar (Base-In, Base-Out, Base-Up, Base-Down) neutralization engine with refixation saccadic physics.
- **Lees / Hess Tangent Motility Screen:**
  - Inner 15° and Outer 30° tangent screen grid with red-green dissociation.
  - Vector plotting for paretic muscle underaction vs. yoke muscle overaction (Hering’s Law of Equal Innervation).
  - Clinical pathology presets: CN VI palsy, CN IV palsy (Parks 3-step correlation), CN III palsy, Orbital Blowout Fracture (IR entrapment), and Duane Retraction Syndrome Type 1.
- **4-Mirror Gonioscopy & Angle Grading Lab:**
  - 4-Mirror Goldmann / Zeiss slit-lamp simulation with quadrant navigation (Inferior, Superior, Nasal, Temporal).
  - Dynamic Zeiss Indentation gonioscopy physics (differentiating appositional vs. synechial angle closure).
  - Corneal Optical Wedge visualization (internal and external corneal beam reflection converging at Schwalbe’s line).
  - Van Herick cross-sectional anterior chamber depth correlation.
  - Pathologies: Shaffer Grade 0–4, PACG, Pigment Dispersion (Sampaolesi line), Pseudoexfoliation, Angle Recession, Neovascular Glaucoma (NVI/NVA), and Plateau Iris.
- **Visual Pathways & Perimetry Lab:**
  - Interactive neuro-pathway lesions producing classic visual field defects: Bitemporal hemianopia, Homonymous hemianopia with/without macular sparing, Junctional scotoma, and Quadrantanopia (Parietal vs. Temporal Meyer loop).

---

### 3. 📐 Clinical Calculators & Surgical Dose-Response

- **Strabismus Surgical Dose-Response Calculator:** Parks, Wright, and Helveston dose tables for Medial/Lateral Rectus recession/resection, Vertical rectus surgery, and A/V pattern transposition offsets.
- **AC/A Ratio Workup:** Gradient method (with $\pm2.00\text{D}$ spheres) and Heterophoria method with bifocal executive add recommendations.
- **Kestenbaum Nystagmus Dosing:** Parks 5-6-7-8 and augmented 4-muscle dosing for abnormal compensatory head turns.
- **Parks-Bielschowsky 3-Step Test:** Step-by-step diagnostic algorithm isolating the paretic cyclovertical muscle in acquired vertical diplopia.
- **Torsion & Bielschowsky Head Tilt Test (BHTT):** Double Maddox Rod subjective cyclotorsion analyzer and head-tilt vertical deviation comparison.
- **Prism Adaptation Test (PAT / PATS):** Target deviation calculation to prevent postoperative esotropia undercorrection.
- **Digital Hirschberg & Krimsky Test:** Millimeter-to-prism-diopter corneal light reflex screening.

---

### 4. 🎮 Digital Therapeutics (DTx) & Vision Therapy

- **Balanced Dichoptic Therapy (DCP):** Dynamic contrast penalization game designed to break amblyopic suppression while training binocular summation.
- **Hart Chart Saccadic Rock:** 10x10 metronome-paced saccadic rock and accommodative trainer with auditory pacing.
- **Amblyopia Patching Compliance Tracker:** Daily occlusion logger, progress streak counter, and 7-day compliance bar chart.
- **Brock String 3D Simulator:** Interactive bead placement with physiological diplopia feedback (crossing "X" and "V" patterns).
- **Virtual Synoptophore (Amblyoscope):** Optical tube angle adjustment, Angle Kappa ($\kappa$), and Haidinger brush simulation.

---

### 5. 🦊 Pediatric Fixation Character Studio

- **Animated Mascot Companions:**
  - **Dr. Iris:** The Wise Owl with animated wing flutter.
  - **Sparky:** The Playful Fox with tail wag and friendly expressions.
  - **Barnaby:** The Gentle Bear with animated ear wiggle.
- **Pediatric Engagement:** Teller preferential looking high-contrast gratings, interactive screen-touch particle bursts, and 9-position fixation tracking with gaze hold timer.

---

### 6. 📁 Encrypted Offline Patient Records & Referral Exporter

- **100% Offline Database:** Patient examinations, diagnosis histories, and test scores persist encrypted on-device.
- **1-Tap Clinical Referral Letters:** Formats comprehensive clinical letters with patient MRN, visual acuity, motility findings, and surgeon notes ready for copy/print/export.

---

## 🎨 Design System & Distortion-Free Architecture

- **Glassmorphic UI:** Apple iOS 18 blur cards combined with Material 3 dynamic color tokens and Samsung One UI 7 grouped card architecture.
- **Anti-Distortion Engine:** All optical canvases (Hess Screen, Amsler Grid, Schober Test, Gonioscopy, 3D Eye, Cover Test) are governed by strict `AspectRatio` and `ConstrainedBox` viewport boundaries to guarantee authentic `1:1` optical geometry across small phones, foldables, and large widescreen tablets without distortion or clipping.
- **Theme Modes:**
  - ☀️ **Clean Light Mode**
  - 🌙 **Cyber Dark Mode**
  - 🖤 **AMOLED Pure Black Mode (`#000000`)** (Zero battery drain on OLED screens)
- **High-Contrast Accessibility Mode:** Designed for visually impaired patients and clinical low-vision work.

---

## 🌍 Multi-Language Localization

Instant real-time switching between 8 major global languages across all clinical calculators, simulator labels, and patient findings:

| Language | Locale Code | Native Name |
|:---|:---:|:---|
| **English** | `EN` | English 🇺🇸 |
| **Spanish** | `ES` | Español 🇪🇸 |
| **French** | `FR` | Français 🇫🇷 |
| **German** | `DE` | Deutsch 🇩🇪 |
| **Chinese (Simplified)** | `ZH` | 简体中文 🇨🇳 |
| **Hindi** | `HI` | हिन्दी 🇮🇳 |
| **Arabic** | `AR` | العربية 🇸🇦 |
| **Japanese** | `JA` | 日本語 🇯🇵 |

---

## 🛠️ Tech Stack & Build Specifications

| Component | Specification |
|:---|:---|
| **Framework** | Flutter 3.47.x (Channel Stable) |
| **Language** | Dart 3.13.x |
| **Android Gradle Plugin (AGP)** | `9.1.0` |
| **Gradle Version** | `9.3.1-all` |
| **Kotlin Gradle Plugin (KGP)** | `2.4.0` |
| **Java Compatibility** | JDK 17 (Microsoft HotSpot LTS) |
| **Target Platforms** | Android (SDK 23–35), iOS, macOS, Windows, Linux, Web |
| **State Management** | Layered Architecture (UI / Controllers / Services) + `Provider` |
| **Persistence** | Encrypted `SharedPreferences` + Offline JSON Schema |

---

## 🚀 Getting Started

### Prerequisites
1. Install [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.x or higher).
2. Install [JDK 17](https://learn.microsoft.com/en-us/java/openjdk/download#openjdk-17).
3. Ensure Android Studio or VS Code is configured with Flutter & Dart extensions.

### Installation & Run

```bash
# 1. Clone the repository
git clone https://github.com/JMR193/Squint.git
cd Squint

# 2. Install project dependencies
flutter pub get

# 3. Verify static analysis (0 errors)
dart analyze lib

# 4. Run on your connected device or emulator
flutter run
```

### Building Release APK / App Bundle

```bash
# Build release APK
flutter build apk --release

# Build release App Bundle (Google Play Store)
flutter build appbundle --release
```

---

## ⚖️ Clinical Disclaimer & Regulatory Notice

> [!WARNING]
> **FOR PROFESSIONAL CLINICAL REFERENCE & EDUCATIONAL USE ONLY.**  
> Squint & Strabismus Pro is intended as a clinical decision support and training tool for qualified ophthalmologists, strabismologists, optometrists, and medical residents. It does not replace comprehensive in-person ophthalmic examination, standardized goldmann prism bar neutralization in a clinical setting, or expert surgical judgment. Surgical doses calculated by this application are reference guidelines based on published literature (Parks, Wright, Helveston) and must be individualized for each patient.

---

## 📄 License

This project is licensed under the **Apache License 2.0**. See the [LICENSE](LICENSE) file for complete details.

```
Copyright 2026 JMR193 & OcuLearning Contributors

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0
```
