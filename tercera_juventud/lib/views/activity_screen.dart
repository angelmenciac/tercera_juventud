import 'package:flutter/material.dart';
import 'package:tercera_juventud/controller/services/video_service.dart';
import 'package:tercera_juventud/views/upload_video_screen.dart';
import 'package:video_player/video_player.dart';
import '../models/video_model.dart';

class ActivityScreen extends StatefulWidget {
  final String categoryId;
  final String activityId;

  const ActivityScreen({super.key, required this.categoryId, required this.activityId});
  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final VideoService _service = VideoService();
  VideoPlayerController? _controller;
  ActivityVideo? _video;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLatest();
  }

  Future<void> _loadLatest() async {
    // Si quieres reacción en tiempo real usa streamLatestVideo y setState cuando cambie
    final v = await _service.getLatestVideo(widget.categoryId, widget.activityId);
    if (v != null) {
      _video = v;
      _controller = VideoPlayerController.networkUrl(Uri.parse(v.downloadUrl));
      await _controller!.initialize();
      setState(() {
        _loading = false;
      });
      _controller!.setLooping(false);
      // opcional: _controller!.play();
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.activityId),
      ),
      body: Center(
        child: _loading
            ? CircularProgressIndicator()
            : _video == null
                ? Text('No hay video para esta actividad. Puedes subir uno.')
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: VideoPlayer(_controller!),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(_controller!.value.isPlaying ? Icons.pause : Icons.play_arrow),
                            onPressed: () {
                              setState(() {
                                _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.replay),
                            onPressed: () {
                              _controller!.seekTo(Duration.zero);
                            },
                          ),
                        ],
                      )
                    ],
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.upload),
        onPressed: () {
          // Navegar a pantalla de upload para esta activity
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => UploadVideoScreen(categoryId: widget.categoryId, activityId: widget.activityId),
          ));
        },
      ),
    );
  }
}