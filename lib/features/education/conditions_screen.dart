import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ConditionsScreen extends StatefulWidget {
  const ConditionsScreen({super.key});

  @override
  State<ConditionsScreen> createState() => _ConditionsScreenState();
}

class _ConditionsScreenState extends State<ConditionsScreen> {
  List<dynamic> _allConditions = [];
  List<dynamic> _filteredConditions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConditions();
  }

  Future<void> _loadConditions() async {
    try {
      final String response = await rootBundle.loadString('assets/data/conditions.json');
      final data = await json.decode(response);
      setState(() {
        _allConditions = data;
        _filteredConditions = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading conditions: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filter(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _filteredConditions = _allConditions;
      } else {
        final q = query.toLowerCase().trim();
        _filteredConditions = _allConditions.where((c) {
          final name = (c['name'] ?? '').toString().toLowerCase();
          final cat = (c['catLabel'] ?? c['cat'] ?? '').toString().toLowerCase();
          final pearl = (c['pearl'] ?? '').toString().toLowerCase();
          return name.contains(q) || cat.contains(q) || pearl.contains(q);
        }).toList();
      }
    });
  }

  void _openConditionDetails(Map<String, dynamic> condition) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConditionDetailScreen(condition: condition),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clinical Encyclopedia')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search conditions (e.g. Esotropia, Nerve Palsy, Brown)...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _filter,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredConditions.length,
                    itemBuilder: (context, index) {
                      final condition = _filteredConditions[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: ListTile(
                          leading: Icon(Icons.menu_book, color: Theme.of(context).primaryColor),
                          title: Text(condition['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(condition['catLabel'] ?? condition['cat'] ?? ''),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _openConditionDetails(condition),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class ConditionDetailScreen extends StatelessWidget {
  final Map<String, dynamic> condition;
  
  const ConditionDetailScreen({super.key, required this.condition});

  Widget _buildSection(String title, List<dynamic>? items) {
    if (items == null || items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text('• $item', style: const TextStyle(fontSize: 15)),
              )),
          const Divider(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(condition['name'] ?? 'Condition Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (condition['pearl'] != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  border: Border.all(color: Colors.amber),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb, color: Colors.amber),
                    const SizedBox(width: 8),
                    Expanded(child: Text(condition['pearl'], style: const TextStyle(fontStyle: FontStyle.italic))),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            _buildSection('Symptoms', condition['symptoms']),
            _buildSection('Clinical Findings', condition['findings']),
            _buildSection('Etiology', condition['etiology']),
            _buildSection('Red Flags', condition['redFlags']),
            _buildSection('Investigations', condition['investigations']),
            _buildSection('Action Steps', condition['actionSteps']),
            _buildSection('Treatment', condition['treatment']),
            _buildSection('Follow Up', condition['followUp']),
          ],
        ),
      ),
    );
  }
}
