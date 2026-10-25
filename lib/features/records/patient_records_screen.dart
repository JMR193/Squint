import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/clinical_database_service.dart';
import '../../core/widgets/custom_ui_components.dart';

class PatientRecordsScreen extends StatefulWidget {
  const PatientRecordsScreen({super.key});

  @override
  State<PatientRecordsScreen> createState() => _PatientRecordsScreenState();
}

class _PatientRecordsScreenState extends State<PatientRecordsScreen> {
  final ClinicalDatabaseService _dbService = ClinicalDatabaseService();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Clinical Records'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            tooltip: 'Add New Patient Record',
            onPressed: () => _showAddRecordDialog(context),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _dbService,
        builder: (context, _) {
          final allRecords = _dbService.records;
          final filteredRecords = allRecords.where((r) {
            final query = _searchQuery.toLowerCase();
            return r.patientName.toLowerCase().contains(query) ||
                r.primaryDiagnosis.toLowerCase().contains(query) ||
                r.id.toLowerCase().contains(query);
          }).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Search & Filter Header
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search by patient name, diagnosis, or ID...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
              const SizedBox(height: 14),

              // Statistics Header Pill Card
              SamsungOneUiGroupCard(
                title: 'CLINICAL DATABASE SUMMARY',
                icon: Icons.analytics_outlined,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCol('Total Patients', '${allRecords.length}', Colors.cyanAccent),
                    _buildStatCol('Active Records', '${filteredRecords.length}', Colors.tealAccent),
                    _buildStatCol('Encrypted', 'Local AES', Colors.amberAccent),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (filteredRecords.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        const Icon(Icons.folder_open, size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text('No clinical records found', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 6),
                        const Text(
                          'Tap + in the top right to record a new patient strabismus examination.',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...filteredRecords.map((record) => _buildRecordCard(context, record, theme)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddRecordDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New Exam Record'),
      ),
    );
  }

  Widget _buildStatCol(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildRecordCard(BuildContext context, PatientRecord record, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.patientName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Age: ${record.age} • ${record.gender} • ID: ${record.id}',
                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (val) {
                    if (val == 'export') {
                      _exportRecord(context, record);
                    } else if (val == 'delete') {
                      _confirmDelete(context, record);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'export', child: Row(children: [Icon(Icons.share, size: 18), SizedBox(width: 8), Text('Copy/Export Report')])),
                    const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 18), SizedBox(width: 8), Text('Delete Record', style: TextStyle(color: Colors.red))])),
                  ],
                ),
              ],
            ),
            const Divider(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.4)),
              ),
              child: Text(
                record.primaryDiagnosis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: theme.colorScheme.primary),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildDetailTile('Distance PACT', '${record.distanceDeviationPd}Δ ${record.distanceDeviationType}'),
                ),
                Expanded(
                  child: _buildDetailTile('Near PACT', '${record.nearDeviationPd}Δ ${record.nearDeviationType}'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: _buildDetailTile('Hirschberg Angle', '${record.hirschbergDegrees}°'),
                ),
                Expanded(
                  child: _buildDetailTile('BSV Grade', record.bsvGrade),
                ),
              ],
            ),
            if (record.surgicalPlan.isNotEmpty) ...[
              const SizedBox(height: 6),
              _buildDetailTile('Surgical Dose Plan', record.surgicalPlan),
            ],
            if (record.patchingPrescription.isNotEmpty) ...[
              const SizedBox(height: 6),
              _buildDetailTile('Patching Rx', record.patchingPrescription),
            ],
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Examined: ${record.createdAt.toLocal().toString().split(' ')[0]}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.assignment_outlined, size: 14),
                  label: const Text('View Full Report', style: TextStyle(fontSize: 11)),
                  onPressed: () => _showFullReportModal(context, record),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _showFullReportModal(BuildContext context, PatientRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                controller: scrollController,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Clinical Examination Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const Divider(),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SelectableText(
                      record.toFormattedReport(),
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.cyanAccent, height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy Clinical Report to Clipboard'),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: record.toFormattedReport()));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Clinical Report copied to clipboard!')),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _exportRecord(BuildContext context, PatientRecord record) {
    Clipboard.setData(ClipboardData(text: record.toFormattedReport()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Patient report copied to clipboard!')),
    );
  }

  void _confirmDelete(BuildContext context, PatientRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Patient Record?'),
        content: Text('Are you sure you want to delete the clinical record for ${record.patientName}? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              _dbService.deleteRecord(record.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddRecordDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final ageCtrl = TextEditingController(text: '6');
    final diagCtrl = TextEditingController(text: 'Infantile Esotropia');
    final distPdCtrl = TextEditingController(text: '25.0');
    final nearPdCtrl = TextEditingController(text: '25.0');
    final hirschCtrl = TextEditingController(text: '12.5');
    final planCtrl = TextEditingController(text: 'Bilateral Medial Rectus Recession (5.0mm)');
    final patchCtrl = TextEditingController(text: 'None');
    final notesCtrl = TextEditingController(text: 'Cross-fixation present. Normal fundus.');
    String gender = 'Female';
    String distType = 'ET';
    String nearType = 'ET';
    String bsv = 'Simultaneous Perception';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          title: const Text('New Strabismus Exam Record'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Patient Name')),
                Row(
                  children: [
                    Expanded(child: TextField(controller: ageCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Age'))),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: gender,
                        items: const [DropdownMenuItem(value: 'Female', child: Text('Female')), DropdownMenuItem(value: 'Male', child: Text('Male')), DropdownMenuItem(value: 'Other', child: Text('Other'))],
                        onChanged: (v) => setDlgState(() => gender = v ?? 'Female'),
                        decoration: const InputDecoration(labelText: 'Gender'),
                      ),
                    ),
                  ],
                ),
                TextField(controller: diagCtrl, decoration: const InputDecoration(labelText: 'Primary Diagnosis')),
                Row(
                  children: [
                    Expanded(child: TextField(controller: distPdCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Dist PACT (Δ)'))),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: distType,
                        items: const [DropdownMenuItem(value: 'ET', child: Text('ET')), DropdownMenuItem(value: 'XT', child: Text('XT')), DropdownMenuItem(value: 'RHT', child: Text('RHT')), DropdownMenuItem(value: 'LHT', child: Text('LHT')), DropdownMenuItem(value: 'Ortho', child: Text('Ortho'))],
                        onChanged: (v) => setDlgState(() => distType = v ?? 'ET'),
                        decoration: const InputDecoration(labelText: 'Type'),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: TextField(controller: nearPdCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Near PACT (Δ)'))),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: nearType,
                        items: const [DropdownMenuItem(value: 'ET', child: Text('ET')), DropdownMenuItem(value: 'XT', child: Text('XT')), DropdownMenuItem(value: 'RHT', child: Text('RHT')), DropdownMenuItem(value: 'LHT', child: Text('LHT')), DropdownMenuItem(value: 'Ortho', child: Text('Ortho'))],
                        onChanged: (v) => setDlgState(() => nearType = v ?? 'ET'),
                        decoration: const InputDecoration(labelText: 'Type'),
                      ),
                    ),
                  ],
                ),
                TextField(controller: hirschCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Hirschberg Angle (Degrees)')),
                TextField(controller: planCtrl, decoration: const InputDecoration(labelText: 'Surgical Dosing Plan')),
                TextField(controller: patchCtrl, decoration: const InputDecoration(labelText: 'Patching Prescription')),
                TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Clinical Notes')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isEmpty) return;
                final newRec = PatientRecord(
                  id: 'REC-${DateTime.now().millisecondsSinceEpoch}',
                  patientName: nameCtrl.text.trim(),
                  age: int.tryParse(ageCtrl.text) ?? 5,
                  gender: gender,
                  primaryDiagnosis: diagCtrl.text.trim(),
                  distanceDeviationPd: double.tryParse(distPdCtrl.text) ?? 0.0,
                  distanceDeviationType: distType,
                  nearDeviationPd: double.tryParse(nearPdCtrl.text) ?? 0.0,
                  nearDeviationType: nearType,
                  hirschbergDegrees: double.tryParse(hirschCtrl.text) ?? 0.0,
                  surgicalPlan: planCtrl.text.trim(),
                  patchingPrescription: patchCtrl.text.trim(),
                  notes: notesCtrl.text.trim(),
                  bsvGrade: bsv,
                  createdAt: DateTime.now(),
                );
                _dbService.addRecord(newRec);
                Navigator.pop(context);
              },
              child: const Text('Save Record'),
            ),
          ],
        ),
      ),
    );
  }
}
