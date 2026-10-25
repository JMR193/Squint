import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FlowchartsScreen extends StatefulWidget {
  const FlowchartsScreen({super.key});

  @override
  State<FlowchartsScreen> createState() => _FlowchartsScreenState();
}

class _FlowchartsScreenState extends State<FlowchartsScreen> {
  List<dynamic> _flowcharts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFlowcharts();
  }

  Future<void> _loadFlowcharts() async {
    try {
      final String response = await rootBundle.loadString('assets/data/flowcharts.json');
      final data = await json.decode(response);
      setState(() {
        _flowcharts = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading flowcharts: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openInteractiveFlowchart(BuildContext context, Map<String, dynamic> chart) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InteractiveFlowchartViewer(chart: chart),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clinical Flowcharts')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _flowcharts.isEmpty
              ? const Center(child: Text('No flowcharts found.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _flowcharts.length,
                  itemBuilder: (context, index) {
                    final chart = _flowcharts[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                          child: const Icon(Icons.account_tree, size: 20),
                        ),
                        title: Text(chart['title'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(chart['description'] ?? chart['start'] ?? ''),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => _openInteractiveFlowchart(context, chart),
                      ),
                    );
                  },
                ),
    );
  }
}

class InteractiveFlowchartViewer extends StatefulWidget {
  final Map<String, dynamic> chart;
  const InteractiveFlowchartViewer({super.key, required this.chart});

  @override
  State<InteractiveFlowchartViewer> createState() => _InteractiveFlowchartViewerState();
}

class _InteractiveFlowchartViewerState extends State<InteractiveFlowchartViewer> {
  late String _currentNodeId;
  final List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _currentNodeId = widget.chart['start'] ?? 'start';
  }

  Map<String, dynamic>? _getNode(String id) {
    final nodes = widget.chart['nodes'];
    if (nodes is Map<String, dynamic>) {
      return nodes[id];
    } else if (nodes is List) {
      for (final n in nodes) {
        if (n is Map<String, dynamic> && n['id'] == id) return n;
      }
    }
    return null;
  }

  void _chooseOption(String nextId) {
    setState(() {
      _history.add(_currentNodeId);
      _currentNodeId = nextId;
    });
  }

  void _goBack() {
    if (_history.isNotEmpty) {
      setState(() {
        _currentNodeId = _history.removeLast();
      });
    }
  }

  void _restart() {
    setState(() {
      _history.clear();
      _currentNodeId = widget.chart['start'] ?? 'start';
    });
  }

  @override
  Widget build(BuildContext context) {
    final node = _getNode(_currentNodeId);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chart['title'] ?? 'Flowchart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Restart Flowchart',
            onPressed: _restart,
          ),
        ],
      ),
      body: node == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Node not found.'),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _restart, child: const Text('Restart')),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_history.isNotEmpty)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _goBack,
                        icon: const Icon(Icons.arrow_back, size: 16),
                        label: const Text('Previous Step'),
                      ),
                    ),
                  const SizedBox(height: 8),
                  // Progress indicator
                  LinearProgressIndicator(
                    value: (_history.length + 1) / ((_history.length + 3).toDouble()),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 20),
                  // Question or Outcome Card
                  Card(
                    elevation: 2,
                    color: (node['type'] == 'outcome' || node['isOutcome'] == true)
                        ? Colors.green.shade50
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                (node['type'] == 'outcome' || node['isOutcome'] == true)
                                    ? Icons.check_circle
                                    : Icons.help_outline,
                                color: (node['type'] == 'outcome' || node['isOutcome'] == true)
                                    ? Colors.green
                                    : Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                (node['type'] == 'outcome' || node['isOutcome'] == true)
                                    ? 'DIAGNOSTIC OUTCOME'
                                    : 'CLINICAL DECISION POINT',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 1.2,
                                  color: (node['type'] == 'outcome' || node['isOutcome'] == true)
                                      ? Colors.green.shade800
                                      : Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            node['text'] ?? node['question'] ?? node['label'] ?? '',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          if (node['details'] != null || node['pearl'] != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              node['details'] ?? node['pearl'] ?? '',
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade800, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Options
                  if (node['options'] is List) ...[
                    const Text('Select Clinical Finding:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: (node['options'] as List).length,
                        itemBuilder: (context, i) {
                          final opt = (node['options'] as List)[i];
                          final label = opt is Map ? (opt['text'] ?? opt['label'] ?? '') : opt.toString();
                          final nextId = opt is Map ? (opt['next'] ?? opt['nextId'] ?? '') : '';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                alignment: Alignment.centerLeft,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: nextId.isNotEmpty ? () => _chooseOption(nextId) : null,
                              child: Row(
                                children: [
                                  Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
                                  const Icon(Icons.arrow_forward_ios, size: 14),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ] else if (node['type'] == 'outcome' || node['isOutcome'] == true) ...[
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: _restart,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Restart Algorithm'),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
    );
  }
}
