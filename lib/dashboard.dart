import 'package:flutter/material.dart';
import 'session_history.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Key sessionHistoryKey = UniqueKey(); // forces widget rebuild

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PosePerfectionAI"),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            tooltip: "Start Session",
            onPressed: () {
              Navigator.of(context).pushNamed('/camera').then((_) {
                // After returning from Camera screen, rebuild SessionHistoryWidget
                setState(() {
                  sessionHistoryKey = UniqueKey();
                });
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: SessionHistoryWidget(key: sessionHistoryKey),
      ),
    );
  }
}
