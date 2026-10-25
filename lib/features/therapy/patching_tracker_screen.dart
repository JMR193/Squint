import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

class PatchingTrackerScreen extends StatefulWidget {
  const PatchingTrackerScreen({super.key});

  @override
  State<PatchingTrackerScreen> createState() => _PatchingTrackerScreenState();
}

class _PatchingTrackerScreenState extends State<PatchingTrackerScreen> {
  int _secondsPatched = 0;
  Timer? _timer;
  bool _isPatching = false;
  List<double> _weeklyLogs = List.filled(7, 0.0);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _secondsPatched = prefs.getInt('patching_seconds_today') ?? 0;
      List<String>? logs = prefs.getStringList('patching_weekly_logs');
      if (logs != null && logs.length == 7) {
        _weeklyLogs = logs.map(double.parse).toList();
      }
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('patching_seconds_today', _secondsPatched);
    // In a real app, logic to rotate the weekly log array would be here.
    // For demo, we just update today's log (let's say today is index 6).
    _weeklyLogs[6] = _secondsPatched / 3600.0; // log in hours
    await prefs.setStringList('patching_weekly_logs', _weeklyLogs.map((e) => e.toString()).toList());
  }

  void _startPatching() {
    setState(() {
      _isPatching = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsPatched++;
      });
      if (_secondsPatched % 10 == 0) { // save every 10 seconds to avoid too many writes
        _saveData();
      }
    });
  }

  void _stopPatching() {
    _timer?.cancel();
    setState(() {
      _isPatching = false;
    });
    _saveData();
  }

  String _formatTime(int seconds) {
    int h = seconds ~/ 3600;
    int m = (seconds % 3600) ~/ 60;
    int s = seconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patching Tracker')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Daily Goal: 2 Hours', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: _secondsPatched / (2 * 3600), // 2 hours
                    strokeWidth: 12,
                    backgroundColor: Colors.grey.shade300,
                    color: Colors.green,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Time Patched', style: TextStyle(color: Colors.grey)),
                    Text(_formatTime(_secondsPatched), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _isPatching ? _stopPatching : _startPatching,
              icon: Icon(_isPatching ? Icons.stop : Icons.play_arrow),
              label: Text(_isPatching ? 'Stop Timer' : 'Start Patching'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isPatching ? Colors.red : Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 40),
            const Align(alignment: Alignment.centerLeft, child: Text('Weekly Compliance (Hours)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 3,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(days[value.toInt() % 7], style: const TextStyle(fontWeight: FontWeight.bold)),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 28),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: _weeklyLogs.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value,
                          color: entry.value >= 2.0 ? Colors.green : Colors.blue,
                          width: 16,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        )
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
