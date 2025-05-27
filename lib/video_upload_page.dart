import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class VideoUploadPage extends StatefulWidget {
  const VideoUploadPage({super.key});

  @override
  VideoUploadPageState createState() => VideoUploadPageState();
}

class VideoUploadPageState extends State<VideoUploadPage> {
  String? processedVideoUrl;
  List<Map<String, dynamic>> classifications = [];
  bool isUploading = false;
  VideoPlayerController? _videoController;

  Future<void> uploadVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile == null) return;
    File file = File(pickedFile.path);

    final uri = Uri.parse(
      'http://10.139.78.5:5000/api/process_video',
    ); // Replace <your-ip>
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('video', file.path));

    setState(() {
      isUploading = true;
    });

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final videoUrl = "http://10.139.78.5:5000${data['video_url']}";
      // final results =
      //     (data['classification'] as List)
      //         .map((e) => Map<String, dynamic>.from(e))
      //         .toList();

      setState(() {
        processedVideoUrl = videoUrl;
        // classifications = results;
        isUploading = false;
      });

      // await logSession(results);
      loadVideo(videoUrl);
    } else {
      setState(() {
        isUploading = false;
      });
      print("Upload failed: ${response.body}");
    }
  }

  void loadVideo(String url) {
    _videoController?.dispose();
    _videoController = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        setState(() {});
        _videoController!.play();
      });
  }

  Future<void> logSession(List<Map<String, dynamic>> results) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('session_history') ?? [];

    final now = DateTime.now();
    final session = {
      'dateTime': now.toIso8601String(),
      'reps': 0,
      'score': 0,
      'durationSec': 0,
      'notes': results.map((e) => e['class']).join(', '),
    };

    stored.add(jsonEncode(session));
    await prefs.setStringList('session_history', stored);
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upload & Analyze Video")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.upload),
              label: Text("Upload Video"),
              onPressed: isUploading ? null : uploadVideo,
            ),
            const SizedBox(height: 20),
            if (isUploading) CircularProgressIndicator(),
            if (_videoController != null &&
                _videoController!.value.isInitialized)
              AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
            const SizedBox(height: 20),
            if (classifications.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: classifications.length,
                  itemBuilder: (context, index) {
                    final item = classifications[index];
                    return ListTile(
                      title: Text("Class: ${item['class']}"),
                      subtitle: Text(
                        "Prob: ${(item['probability'] * 100).toStringAsFixed(2)}%",
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
