import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/session_summary.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class SessionHistoryWidget extends StatefulWidget {
  const SessionHistoryWidget({super.key});

  @override
  State<SessionHistoryWidget> createState() => _SessionHistoryWidgetState();
}

class _SessionHistoryWidgetState extends State<SessionHistoryWidget> {
  List<SessionSummary> sessions = [];

  @override
  void initState() {
    super.initState();
    loadSessions();
  }

  Future<void> loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('sessionHistory') ?? [];

    setState(() {
      sessions =
          stored
              .map((e) => SessionSummary.fromJson(jsonDecode(e)))
              .toList()
              .reversed
              .toList();
    });
  }

  String formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final sec = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const Center(child: Text("No session history yet."));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(12.0),
          child: Text("Workout History", style: TextStyle(fontSize: 20)),
        ),
        SizedBox(
          height: 200,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: sessions.map((s) => s.reps).fold(0, max).toDouble() + 5,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.black87,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        'Reps: ${rod.toY.round()}',
                        const TextStyle(color: Colors.white),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index < sessions.length) {
                          final date =
                              sessions[index].dateTime.split("T").first;
                          return Text(date.substring(5)); // MM-DD
                        }
                        return const Text('');
                      },
                      interval: 1,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups:
                    sessions
                        .asMap()
                        .entries
                        .map(
                          (e) => BarChartGroupData(
                            x: e.key,
                            barRods: [
                              BarChartRodData(
                                toY: e.value.reps.toDouble(),
                                width: 18,
                                borderRadius: BorderRadius.circular(6),
                                gradient: const LinearGradient(
                                  colors: [Colors.blueAccent, Colors.lightBlue],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: LineChart(
              LineChartData(
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index < sessions.length) {
                          final date =
                              sessions[index].dateTime.split("T").first;
                          return Text(date.substring(5));
                        }
                        return const Text('');
                      },
                      interval: 1,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, _) => Text("${value.toInt()}m"),
                    ),
                  ),
                ),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: true),
                minY: 0,
                maxY:
                    sessions
                        .map((s) => s.durationSec ~/ 60)
                        .fold(0, max)
                        .toDouble() +
                    1,
                lineBarsData: [
                  LineChartBarData(
                    spots:
                        sessions.asMap().entries.map((e) {
                          final minutes =
                              (e.value.durationSec / 60)
                                  .clamp(0, 60)
                                  .toDouble();
                          return FlSpot(e.key.toDouble(), minutes);
                        }).toList(),
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [Colors.greenAccent, Colors.lightGreen],
                    ),
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.greenAccent.withOpacity(0.4),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    barWidth: 3,
                  ),
                ],
              ),
            ),
          ),
        ),
        const Divider(),
        ...sessions.map((session) {
          return ListTile(
            leading: const Icon(Icons.fitness_center),
            title: Text("Reps: ${session.reps}"),
            subtitle: Text("Duration: ${formatDuration(session.durationSec)}"),
            trailing: Text(session.dateTime.split("T").first),
          );
        }),
      ],
    );
  }
}
