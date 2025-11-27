import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tercera_juventud/controller/services/video_service.dart';


class UploadVideoScreen extends StatefulWidget {
  final String categoryId;
  final String activityId;
  const UploadVideoScreen({super.key, required this.categoryId, required this.activityId});

  @override
  State<UploadVideoScreen> createState() => _UploadVideoScreenState();
}

class _UploadVideoScreenState extends State<UploadVideoScreen> {
  bool _loading = false;
  double _progress = 0.0;
  final VideoService _service = VideoService();

  Future<void> pickAndUpload() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (res == null) return;
    final path = res.files.single.path;
    if (path == null) return;
    final file = File(path);

    setState(() {
      _loading = true;
      _progress = 0.0;
    });

    final user = FirebaseAuth.instance.currentUser;
    final uploaderId = user?.uid ?? 'anonymous';

    try {
      await _service.uploadVideoForActivity(
        file: file,
        categoryId: widget.categoryId,
        activityId: widget.activityId,
        uploaderId: uploaderId,
        title: 'Video para ${widget.activityId}',
        onProgress: (p) {
          setState(() => _progress = p);
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload complete')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subir video')),
      body: Center(
        child: _loading
            ? Column(mainAxisSize: MainAxisSize.min, children: [
                CircularProgressIndicator(value: _progress),
                SizedBox(height: 16),
                Text('${(_progress * 100).toStringAsFixed(0)}%'),
              ])
            : ElevatedButton.icon(
                icon: Icon(Icons.upload_file),
                label: Text('Seleccionar y subir video'),
                onPressed: pickAndUpload,
              ),
      ),
    );
  }
}