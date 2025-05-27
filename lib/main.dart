import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'dashboard.dart';
import 'camera_screen.dart';
import 'video_upload_page.dart';

void main() {
  runApp(const PosePerfectionApp());
}

class PosePerfectionApp extends StatelessWidget {
  const PosePerfectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PosePerfectionAI',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/dashboard': (context) => const Dashboard(),
        '/camera': (context) => const CameraScreen(),
        '/upload': (_) => VideoUploadPage(),
      },
    );
  }
}
