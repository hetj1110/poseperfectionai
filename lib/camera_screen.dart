import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? controller;
  bool isCameraInitialized = false;

  final FlutterTts tts = FlutterTts();
  bool ttsEnabled = true;

  Timer? feedbackTimer;
  Timer? feedbackTextTimer;
  Timer? sessionTimer;

  bool isInCooldown = false;
  int repCount = 0;
  int postureScore = 0;
  String feedbackText = "";
  Duration elapsedTime = Duration.zero;
  late DateTime startTime;
  bool _disposed = false;

  final List<String> suggestions = [
    "Keep your back straight",
    "Lower your hips",
    "Tighten your core",
    "Good posture!",
    "Watch your knee angle",
    "Adjust arm position",
  ];

  @override
  void initState() {
    super.initState();
    loadTtsPreference();
    setupTts();
    setupCamera();
  }

  Future<void> setupTts() async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.4);
    await tts.setPitch(1.0);
    await tts.awaitSpeakCompletion(true);
  }

  Future<void> loadTtsPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      ttsEnabled = prefs.getBool('tts_enabled') ?? true;
    });
  }

  Future<void> setupCamera() async {
    final cameras = await availableCameras();

    final selectedCam = cameras.firstWhere(
      (cam) => cam.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    controller = CameraController(
      selectedCam,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await controller!.initialize();
    if (mounted && !_disposed) {
      setState(() {
        isCameraInitialized = true;
      });
      startSession();
    }
  }

  void startSession() {
    final rand = Random();

    // Score Timer
    feedbackTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_disposed) return;

      setState(() {
        postureScore = rand.nextInt(41) + 60;
      });

      if (postureScore >= 85 && !isInCooldown) {
        repCount++;
        isInCooldown = true;
        Future.delayed(const Duration(seconds: 2), () {
          if (!_disposed && mounted) {
            setState(() {
              isInCooldown = false;
            });
          }
        });
      }
    });

    // Feedback Timer
    feedbackTextTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (_disposed || !mounted || !ttsEnabled) return;

      final newFeedback = suggestions[rand.nextInt(suggestions.length)];
      setState(() {
        feedbackText = newFeedback;
      });

      try {
        await tts.stop();
        await tts.speak(newFeedback);
      } catch (e) {
        print("TTS error: $e");
      }
    });

    // Session Timer
    startTime = DateTime.now();
    sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_disposed) return;
      setState(() {
        elapsedTime = DateTime.now().difference(startTime);
      });
    });
  }

  void stopSession() async {
    _disposed = true;
    feedbackTimer?.cancel();
    feedbackTextTimer?.cancel();
    sessionTimer?.cancel();
    await tts.stop();
    controller?.dispose();

    // ✅ Save session summary
    final prefs = await SharedPreferences.getInstance();
    List<String> existing = prefs.getStringList('sessionHistory') ?? [];

    final session = {
      'dateTime': DateTime.now().toIso8601String(),
      'reps': repCount,
      'score': postureScore,
      'durationSec': elapsedTime.inSeconds,
    };

    existing.add(jsonEncode(session));
    await prefs.setStringList('sessionHistory', existing);

    Navigator.of(context).pop();
  }

  void showStopConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Stop"),
          content: const Text("Are you sure you want to stop the session?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: const Text("Stop"),
              onPressed: () {
                Navigator.of(context).pop();
                stopSession();
              },
            ),
          ],
        );
      },
    );
  }

  Color getScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.blue;
    if (score >= 70) return Colors.yellow;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  void dispose() {
    _disposed = true;
    feedbackTimer?.cancel();
    feedbackTextTimer?.cancel();
    sessionTimer?.cancel();
    tts.stop();
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isCameraInitialized ||
        controller == null ||
        !controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Score
            Text(
              "Posture Score: $postureScore",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: getScoreColor(postureScore),
              ),
            ),

            const SizedBox(height: 10),

            // Reps + Time Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Reps: $repCount", style: const TextStyle(fontSize: 18)),
                  Text(
                    "Time: ${elapsedTime.inMinutes.toString().padLeft(2, '0')}:${(elapsedTime.inSeconds % 60).toString().padLeft(2, '0')}",
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Camera Preview with Dynamic Border
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: getScoreColor(postureScore),
                    width: 3,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CameraPreview(controller!),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // TTS and Stop buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(ttsEnabled ? Icons.volume_up : Icons.volume_off),
                    label: Text(ttsEnabled ? "Mute TTS" : "Enable TTS"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                    ),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      setState(() {
                        ttsEnabled = !ttsEnabled;
                      });
                      await prefs.setBool('tts_enabled', ttsEnabled);

                      if (!ttsEnabled) {
                        await tts.stop();
                      }
                    },
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.stop),
                    label: const Text("Stop"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    onPressed: showStopConfirmationDialog,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Feedback text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  feedbackText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
