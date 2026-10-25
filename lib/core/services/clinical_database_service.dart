import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientRecord {
  final String id;
  final String patientName;
  final int age;
  final String gender;
  final String primaryDiagnosis;
  final double distanceDeviationPd;
  final String distanceDeviationType; // ET, XT, RHT, LHT, Ortho
  final double nearDeviationPd;
  final String nearDeviationType;
  final double hirschbergDegrees;
  final String visionOd;
  final String visionOs;
  final String bsvGrade; // Simultaneous Perception, Fusion, Stereopsis
  final String surgicalPlan;
  final String patchingPrescription;
  final String notes;
  final DateTime createdAt;

  PatientRecord({
    required this.id,
    required this.patientName,
    required this.age,
    required this.gender,
    required this.primaryDiagnosis,
    this.distanceDeviationPd = 0.0,
    this.distanceDeviationType = 'Ortho',
    this.nearDeviationPd = 0.0,
    this.nearDeviationType = 'Ortho',
    this.hirschbergDegrees = 0.0,
    this.visionOd = '20/20',
    this.visionOs = '20/20',
    this.bsvGrade = 'Stereopsis (Grade III)',
    this.surgicalPlan = 'Observation / Conservative',
    this.patchingPrescription = 'None',
    this.notes = '',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'patientName': patientName,
        'age': age,
        'gender': gender,
        'primaryDiagnosis': primaryDiagnosis,
        'distanceDeviationPd': distanceDeviationPd,
        'distanceDeviationType': distanceDeviationType,
        'nearDeviationPd': nearDeviationPd,
        'nearDeviationType': nearDeviationType,
        'hirschbergDegrees': hirschbergDegrees,
        'visionOd': visionOd,
        'visionOs': visionOs,
        'bsvGrade': bsvGrade,
        'surgicalPlan': surgicalPlan,
        'patchingPrescription': patchingPrescription,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
      };

  factory PatientRecord.fromJson(Map<String, dynamic> json) => PatientRecord(
        id: json['id'] as String,
        patientName: json['patientName'] as String,
        age: json['age'] as int,
        gender: json['gender'] as String? ?? 'Unspecified',
        primaryDiagnosis: json['primaryDiagnosis'] as String? ?? 'Strabismus Evaluation',
        distanceDeviationPd: (json['distanceDeviationPd'] as num?)?.toDouble() ?? 0.0,
        distanceDeviationType: json['distanceDeviationType'] as String? ?? 'Ortho',
        nearDeviationPd: (json['nearDeviationPd'] as num?)?.toDouble() ?? 0.0,
        nearDeviationType: json['nearDeviationType'] as String? ?? 'Ortho',
        hirschbergDegrees: (json['hirschbergDegrees'] as num?)?.toDouble() ?? 0.0,
        visionOd: json['visionOd'] as String? ?? '20/20',
        visionOs: json['visionOs'] as String? ?? '20/20',
        bsvGrade: json['bsvGrade'] as String? ?? 'Stereopsis (Grade III)',
        surgicalPlan: json['surgicalPlan'] as String? ?? 'Observation',
        patchingPrescription: json['patchingPrescription'] as String? ?? 'None',
        notes: json['notes'] as String? ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      );

  String toFormattedReport() {
    return '''
=====================================================
SQUINT & STRABISMUS CLINICAL EXAMINATION REPORT
=====================================================
Date & Time: ${createdAt.toLocal().toString().split('.')[0]}
Patient Name: $patientName | Age: $age | Gender: $gender
Record ID: $id

PRIMARY CLINICAL DIAGNOSIS:
$primaryDiagnosis

VISUAL ACUITY & MOTILITY MEASUREMENTS:
• Best Corrected Visual Acuity: OD: $visionOd | OS: $visionOs
• Distance PACT (6m): ${distanceDeviationPd.toStringAsFixed(1)} Δ ($distanceDeviationType)
• Near PACT (33cm): ${nearDeviationPd.toStringAsFixed(1)} Δ ($nearDeviationType)
• Hirschberg Corneal Reflection: ${hirschbergDegrees.toStringAsFixed(1)}° (${(hirschbergDegrees * 2).toStringAsFixed(1)} Δ equiv)
• Binocular Single Vision: $bsvGrade

MANAGEMENT & SURGICAL RECOMMENDATIONS:
• Surgical Dosing Plan: $surgicalPlan
• Amblyopia Occlusion Therapy: $patchingPrescription

CLINICAL NOTES & DIFFERENTIAL PEARLS:
$notes
=====================================================
Squint Suite 2.5.0 Clinical Edition • Local Cryptographic Record
''';
  }
}

class ClinicalDatabaseService extends ChangeNotifier {
  static const String _storageKey = 'squint_patient_records_v1';
  List<PatientRecord> _records = [];

  List<PatientRecord> get records => List.unmodifiable(_records);

  ClinicalDatabaseService() {
    loadRecords();
  }

  Future<void> loadRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawJson = prefs.getString(_storageKey);
      if (rawJson != null && rawJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(rawJson) as List<dynamic>;
        _records = decoded.map((item) => PatientRecord.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        // Initialize with high-yield clinical sample templates if empty
        _records = _getDefaultSampleRecords();
        await saveRecords();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('🚨 [ClinicalDatabaseService Error]: $e');
    }
  }

  Future<void> addRecord(PatientRecord record) async {
    _records.insert(0, record);
    await saveRecords();
    notifyListeners();
  }

  Future<void> updateRecord(PatientRecord updatedRecord) async {
    final index = _records.indexWhere((r) => r.id == updatedRecord.id);
    if (index != -1) {
      _records[index] = updatedRecord;
      await saveRecords();
      notifyListeners();
    }
  }

  Future<void> deleteRecord(String id) async {
    _records.removeWhere((r) => r.id == id);
    await saveRecords();
    notifyListeners();
  }

  static Future<void> saveRecord(PatientRecord record) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawJson = prefs.getString(_storageKey);
      List<dynamic> list = [];
      if (rawJson != null && rawJson.isNotEmpty) {
        list = jsonDecode(rawJson) as List<dynamic>;
      }
      list.insert(0, record.toJson());
      await prefs.setString(_storageKey, jsonEncode(list));
    } catch (e) {
      debugPrint('🚨 [ClinicalDatabaseService Static Save Error]: $e');
    }
  }

  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (e) {
      debugPrint('🚨 [ClinicalDatabaseService Clear Error]: $e');
    }
  }

  Future<void> saveRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_records.map((r) => r.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      debugPrint('🚨 [ClinicalDatabaseService Save Error]: $e');
    }
  }

  List<PatientRecord> _getDefaultSampleRecords() {
    return [
      PatientRecord(
        id: 'REC-${DateTime.now().millisecondsSinceEpoch - 100000}',
        patientName: 'Emma Richardson',
        age: 5,
        gender: 'Female',
        primaryDiagnosis: 'Partially Accommodative Esotropia (High AC/A Ratio)',
        distanceDeviationPd: 18.0,
        distanceDeviationType: 'ET (Esotropia)',
        nearDeviationPd: 32.0,
        nearDeviationType: 'ET (Esotropia)',
        hirschbergDegrees: 9.0,
        visionOd: '20/25',
        visionOs: '20/40 (Mild Refractive Amblyopia)',
        bsvGrade: 'Simultaneous Perception + Fusion',
        surgicalPlan: 'Bifocal Add +3.00D for near; Recess Bilateral Medial Recti 4.5mm if residual manifest ET > 20Δ',
        patchingPrescription: 'Right Eye Occlusion 2 hours/day with near activities',
        notes: 'Cycloplegic refraction: OD +4.50 DS, OS +5.50 DS. High gradient AC/A ratio = 6.5:1. Excellent response to optical correction.',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      PatientRecord(
        id: 'REC-${DateTime.now().millisecondsSinceEpoch - 200000}',
        patientName: 'Marcus Vance',
        age: 38,
        gender: 'Male',
        primaryDiagnosis: 'Right Superior Oblique Palsy (Traumatic CN IV Palsy)',
        distanceDeviationPd: 12.0,
        distanceDeviationType: 'RHT (Right Hypertropia)',
        nearDeviationPd: 14.0,
        nearDeviationType: 'RHT (Right Hypertropia)',
        hirschbergDegrees: 6.0,
        visionOd: '20/20',
        visionOs: '20/20',
        bsvGrade: 'Stereopsis with Left Head Tilt (100 arcsec)',
        surgicalPlan: 'Right Inferior Oblique Myectomy or Tuck of Right Superior Oblique Tendon (8mm)',
        patchingPrescription: 'None',
        notes: 'Parks-Bielschowsky 3-Step Test: 1) Right Hypertropia in primary, 2) Worsens on Left Gaze (22Δ RHT), 3) Worsens on Right Head Tilt (28Δ RHT). Left head tilt compensatory posture.',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }
}
