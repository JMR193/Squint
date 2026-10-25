import 'package:flutter/material.dart';

enum AppLanguage { en, es, fr, de, zh, hi, ar, ja }

class LanguageProvider extends ChangeNotifier {
  AppLanguage _currentLanguage = AppLanguage.en;

  AppLanguage get currentLanguage => _currentLanguage;

  String get languageCode {
    switch (_currentLanguage) {
      case AppLanguage.en:
        return 'en';
      case AppLanguage.es:
        return 'es';
      case AppLanguage.fr:
        return 'fr';
      case AppLanguage.de:
        return 'de';
      case AppLanguage.zh:
        return 'zh';
      case AppLanguage.hi:
        return 'hi';
      case AppLanguage.ar:
        return 'ar';
      case AppLanguage.ja:
        return 'ja';
    }
  }

  String get languageName {
    switch (_currentLanguage) {
      case AppLanguage.en:
        return 'English 🇺🇸';
      case AppLanguage.es:
        return 'Español 🇪🇸';
      case AppLanguage.fr:
        return 'Français 🇫🇷';
      case AppLanguage.de:
        return 'Deutsch 🇩🇪';
      case AppLanguage.zh:
        return '中文 (Mandarin) 🇨🇳';
      case AppLanguage.hi:
        return 'हिन्दी (Hindi) 🇮🇳';
      case AppLanguage.ar:
        return 'العربية (Arabic) 🇸🇦';
      case AppLanguage.ja:
        return '日本語 (Japanese) 🇯🇵';
    }
  }

  bool get isRtl => _currentLanguage == AppLanguage.ar;

  void setLanguage(AppLanguage language) {
    _currentLanguage = language;
    notifyListeners();
  }

  String translate(String key) {
    return _translations[languageCode]?[key] ?? _translations['en']?[key] ?? key;
  }

  static final Map<String, Map<String, String>> _translations = {
    'en': {
      'app_title': 'Squint & Strabismus Suite',
      'simulators': 'Simulators',
      'calculators': 'Calculators',
      'therapy': 'Therapy',
      'education': 'Education',
      'research': 'Research',
      'settings': 'Settings',
      'about': 'About',
      'patient_records': 'Patient Records',
      'pediatric_characters': 'Pediatric Fixation Mascots',
      'realistic_3d_eye': '3D Hyper-Realistic Eye Lab',
      'cover_test_3d': '3D Cover Test & Prism Studio',
      'visual_acuity': 'Visual Acuity Chart',
      'gonioscopy_lab': 'Gonioscopy & Angle Lab',
      'color_vision': 'Color Vision Lab',
      'hess_screen': 'Hess Tangent Screen',
      'dark_mode': 'Dark Mode',
      'light_mode': 'Light Mode',
      'amoled_mode': 'AMOLED Pure Black',
      'student_mode': 'Student Mode',
      'offline_ready': '100% Offline Autonomous',
    },
    'es': {
      'app_title': 'Suite de Estrabismo y Visión',
      'simulators': 'Simuladores',
      'calculators': 'Calculadoras',
      'therapy': 'Terapia',
      'education': 'Educación',
      'research': 'Investigación',
      'settings': 'Ajustes',
      'about': 'Acerca de',
      'patient_records': 'Registros de Pacientes',
      'pediatric_characters': 'Mascotas de Fijación Pediátrica',
      'realistic_3d_eye': 'Ojo 3D Hiperrealista',
      'cover_test_3d': 'Cover Test 3D y Prismas',
      'visual_acuity': 'Cartilla de Agudeza Visual',
      'gonioscopy_lab': 'Gonioscopia y Ángulo',
      'color_vision': 'Visión de Colores (Ishihara)',
      'hess_screen': 'Pantalla de Hess',
      'dark_mode': 'Modo Oscuro',
      'light_mode': 'Modo Claro',
      'amoled_mode': 'Negro Puro AMOLED',
      'student_mode': 'Modo Estudiante',
      'offline_ready': '100% Autónomo Sin Conexión',
    },
    'fr': {
      'app_title': 'Suite Clinique Strabisme',
      'simulators': 'Simulateurs',
      'calculators': 'Calculateurs',
      'therapy': 'Thérapie',
      'education': 'Éducation',
      'research': 'Recherche',
      'settings': 'Paramètres',
      'about': 'À propos',
      'patient_records': 'Dossiers Patients',
      'pediatric_characters': 'Mascottes de Fixation Pédiatrique',
      'realistic_3d_eye': 'Œil 3D Hyper-Réaliste',
      'cover_test_3d': 'Cover Test 3D & Prismes',
      'visual_acuity': 'Échelle d\'Acuité Visuelle',
      'gonioscopy_lab': 'Gonioscopie & Angle',
      'color_vision': 'Vision des Couleurs',
      'hess_screen': 'Écran de Hess',
      'dark_mode': 'Mode Sombre',
      'light_mode': 'Mode Clair',
      'amoled_mode': 'Noir Pur AMOLED',
      'student_mode': 'Mode Étudiant',
      'offline_ready': '100% Hors Ligne Autonome',
    },
    'de': {
      'app_title': 'Schielen & Strabismus Suite',
      'simulators': 'Simulatoren',
      'calculators': 'Rechner',
      'therapy': 'Therapie',
      'education': 'Ausbildung',
      'research': 'Forschung',
      'settings': 'Einstellungen',
      'about': 'Über',
      'patient_records': 'Patientenakten',
      'pediatric_characters': 'Pädiatrische Fixationsmaskottchen',
      'realistic_3d_eye': '3D Hyperrealistisches Auge',
      'cover_test_3d': '3D Abdecktest & Prismen',
      'visual_acuity': 'Sehschärfetafel',
      'gonioscopy_lab': 'Gonioskopie & Kammerwinkel',
      'color_vision': 'Farbsehen (Ishihara)',
      'hess_screen': 'Hess-Schirm',
      'dark_mode': 'Dunkelmodus',
      'light_mode': 'Hellmodus',
      'amoled_mode': 'AMOLED Reines Schwarz',
      'student_mode': 'Studentenmodus',
      'offline_ready': '100% Offline Autonom',
    },
    'zh': {
      'app_title': '斜视与双眼视觉临床套件',
      'simulators': '模拟器',
      'calculators': '计算器',
      'therapy': '视觉训练',
      'education': '医学教育',
      'research': '学术研究',
      'settings': '系统设置',
      'about': '关于软件',
      'patient_records': '患者病历档案',
      'pediatric_characters': '儿童注视动画吉祥物',
      'realistic_3d_eye': '超真实3D眼球解剖实验室',
      'cover_test_3d': '3D遮盖试验与三棱镜工作室',
      'visual_acuity': '数字视力表 (LogMAR)',
      'gonioscopy_lab': '前房角镜检查实验室',
      'color_vision': '色觉与石原氏色盲检查',
      'hess_screen': '海斯氏双眼运动屏',
      'dark_mode': '深色模式',
      'light_mode': '浅色模式',
      'amoled_mode': 'AMOLED 纯黑',
      'student_mode': '学生指导模式',
      'offline_ready': '100% 离线自主运行',
    },
    'hi': {
      'app_title': 'भैंगापन और दृष्टि क्लिनिकल सूट',
      'simulators': 'सिमुलेटर',
      'calculators': 'कैलकुलेटर',
      'therapy': 'थेरेपी',
      'education': 'शिक्षा',
      'research': 'अनुसंधान',
      'settings': 'सेटिंग्स',
      'about': 'बारे में',
      'patient_records': 'रोगी रिकॉर्ड',
      'pediatric_characters': 'बाल चिकित्सा फिक्सेशन मास्कॉट',
      'realistic_3d_eye': '3D यथार्थवादी नेत्र प्रयोगशाला',
      'cover_test_3d': '3D कवर टेस्ट और प्रिज्म स्टूडियो',
      'visual_acuity': 'दृष्टि तीक्ष्णता चार्ट',
      'gonioscopy_lab': 'गोनियोस्कोपी और कोण लैब',
      'color_vision': 'रंग दृष्टि परीक्षण',
      'hess_screen': 'हेस स्क्रीन',
      'dark_mode': 'डार्क मोड',
      'light_mode': 'लाइट मोड',
      'amoled_mode': 'एमोलेड शुद्ध काला',
      'student_mode': 'छात्र मोड',
      'offline_ready': '100% ऑफ़लाइन स्वायत्त',
    },
    'ar': {
      'app_title': 'مجموعة الحول وطب العيون السريرية',
      'simulators': 'المحاكاة',
      'calculators': 'الحاسبات',
      'therapy': 'العلاج البصري',
      'education': 'التعليم الطبي',
      'research': 'الأبحاث',
      'settings': 'الإعدادات',
      'about': 'حول التطبيق',
      'patient_records': 'سجلات المرضى',
      'pediatric_characters': 'شخصيات تثبيت نظر الأطفال',
      'realistic_3d_eye': 'مختبر العين ثلاثي الأبعاد الواقعي',
      'cover_test_3d': 'اختبار التغطية ثلاثي الأبعاد والموشور',
      'visual_acuity': 'لوحة قياس حدة البصر',
      'gonioscopy_lab': 'مختبر تنظير زاوية العين',
      'color_vision': 'اختبار رؤية الألوان',
      'hess_screen': 'شاشة هيس الحركية',
      'dark_mode': 'الوضع الداكن',
      'light_mode': 'الوضع الفاتح',
      'amoled_mode': 'أسود نقي AMOLED',
      'student_mode': 'وضع الطلاب',
      'offline_ready': 'يعمل بدون اتصال 100%',
    },
    'ja': {
      'app_title': '斜視・両眼視臨床スイート',
      'simulators': 'シミュレーター',
      'calculators': '計算機',
      'therapy': '視能訓練',
      'education': '教育',
      'research': '研究',
      'settings': '設定',
      'about': 'アプリについて',
      'patient_records': '患者カルテ',
      'pediatric_characters': '小児固視アニメーション',
      'realistic_3d_eye': '超高精度3D眼球解剖ラボ',
      'cover_test_3d': '3D遮蔽試験＆プリズムスタジオ',
      'visual_acuity': 'デジタル視力検査表',
      'gonioscopy_lab': '隅角鏡検査ラボ',
      'color_vision': '色覚・石原表検査',
      'hess_screen': 'ヘス赤緑スクリーン',
      'dark_mode': 'ダークモード',
      'light_mode': 'ライトモード',
      'amoled_mode': 'AMOLED ピュアブラック',
      'student_mode': '学習モード',
      'offline_ready': '100% オフライン自律動作',
    },
  };
}
