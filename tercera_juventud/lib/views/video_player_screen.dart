// lib/screens/video_player_screen.dart
import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';

/// VideoPlayerScreen:
/// - Busca en Firestore el documento más reciente en `videos` con:
///     where('categoria', isEqualTo: categoryId)
///     where('topics', arrayContains: topicLabel)
/// - Toma `downloadUrl` y reproduce.
/// - Si el video es vertical (aspectRatio < 1.0) usa un layout tipo "vertical"
///   con controles personalizados; si es horizontal, usa Chewie con fullscreen.
class VideoPlayerScreen extends StatefulWidget {
  final String categoryId;
  final String topicLabel;

  const VideoPlayerScreen({
    super.key,
    required this.categoryId,
    required this.topicLabel,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  bool _loading = true;
  String? _error;
  String? _downloadUrl;
  bool _isVertical = false;
  bool _showOverlay = false;
  bool _initialized = false;

  late final AnimationController _entryAnim;

  @override
  void initState() {
    super.initState();
    _entryAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _entryAnim.forward();
    });
    _loadVideoFromFirestore();
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    _entryAnim.dispose();
    // Ensure orientations unlocked
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  Future<void> _loadVideoFromFirestore() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final q = await FirebaseFirestore.instance
          .collection('videos')
          .where('categoria', isEqualTo: widget.categoryId)
          .where('topics', arrayContains: widget.topicLabel)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (q.docs.isEmpty) {
        setState(() {
          _error = 'No video found for this activity.';
          _loading = false;
        });
        return;
      }

      final data = q.docs.first.data();
      final url = data['downloadUrl'] as String?;
      if (url == null || url.isEmpty) {
        setState(() {
          _error = 'Video exists but no download URL found.';
          _loading = false;
        });
        return;
      }

      _downloadUrl = url;
      await _initializeController(url);
    } catch (e, st) {
      debugPrint('Error loading video doc: $e\n$st');
      setState(() {
        _error = 'Error loading video: $e';
        _loading = false;
      });
    }
  }

  Future<void> _initializeController(String url) async {
    try {
      // Dispose previous
      _chewieController?.dispose();
      await _videoController?.dispose();

      // Initialize video controller
      _videoController = VideoPlayerController.networkUrl(Uri.parse(url));

      // Prepare, allow errors to surface
      await _videoController!.initialize();

      // Evaluate aspect ratio
      final aspect = _videoController!.value.aspectRatio;
      _isVertical = aspect < 1.0;

      if (!_isVertical) {
        // Use Chewie for horizontal videos (better fullscreen handling)
        _chewieController = ChewieController(
          videoPlayerController: _videoController!,
          autoPlay: true,
          looping: false,
          allowFullScreen: true,
          showControlsOnInitialize: true,
          allowedScreenSleep: false,
          // We don't pass aspectRatio here; Chewie will read from controller
        );
      } else {
        // For vertical videos, don't use Chewie: we'll use custom controls and keep orientation portrait
        // Ensure app stays in portrait when viewing vertical video (optional)
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        _videoController!.setLooping(true);
        _videoController!.play();
        _showOverlay = false;
      }

      setState(() {
        _initialized = true;
        _loading = false;
      });
    } catch (e, st) {
      debugPrint('Error initializing controller: $e\n$st');
      setState(() {
        _error = 'Error initializing video: $e';
        _loading = false;
      });
    }
  }

  void _togglePlay() {
    if (_videoController == null) return;
    if (_videoController!.value.isPlaying) {
      _videoController!.pause();
      setState(() => _showOverlay = true);
    } else {
      _videoController!.play();
      setState(() => _showOverlay = false);
    }
  }

  String _formatDuration(Duration d) {
    final two = (int v) => v.toString().padLeft(2, '0');
    final h = d.inHours;
    final m = two(d.inMinutes.remainder(60));
    final s = two(d.inSeconds.remainder(60));
    if (h > 0) return '$h:$m:$s';
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFFD6C9BD);
    final bg = const Color(0xFFF7E9E9);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: BackButton(color: Colors.black87),
        title: Text(
          widget.topicLabel,
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: CurvedAnimation(parent: _entryAnim, curve: Curves.easeOut),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 12)),
                      BoxShadow(color: Colors.white.withOpacity(0.9), blurRadius: 6, offset: const Offset(-8, -8)),
                    ],
                  ),
                  padding: const EdgeInsets.all(14),
                  child: _buildBody(accent),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(Color accent) {
    if (_loading) {
      return SizedBox(
        height: 360,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: accent),
              const SizedBox(height: 12),
              Text('Cargando video...', style: GoogleFonts.inter(color: Colors.black54)),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return SizedBox(
        height: 260,
        child: Center(
          child: Text(_error!, style: GoogleFonts.inter(color: Colors.redAccent, fontWeight: FontWeight.w600)),
        ),
      );
    }

    if (!_initialized || _videoController == null) {
      return SizedBox(
        height: 260,
        child: Center(child: Text('Inicializando reproductor...', style: GoogleFonts.inter())),
      );
    }

    // Now we have controller initialized
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Video area
        Center(child: _isVertical ? _buildVerticalPlayer() : _buildHorizontalPlayer()),

        const SizedBox(height: 14),

        // Info row
        _buildInfoRow(),

        const SizedBox(height: 10),

        // Action row: play/pause, rewind, forward, duration
        _buildControlRow(),

        const SizedBox(height: 6),

        // Progress indicator
        VideoProgressIndicator(
          _videoController!,
          allowScrubbing: true,
          padding: const EdgeInsets.symmetric(vertical: 6),
          colors: VideoProgressColors(
            playedColor: accent,
            backgroundColor: Colors.grey.shade300,
            bufferedColor: Colors.grey.shade200,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalPlayer() {
    // We want a visually pleasing vertical container that adapts to screen height
    final aspect = _videoController!.value.aspectRatio;
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;
    // compute container width: prefer 70% of width up to 420, min 320
    final containerWidth = (screenW * 0.75).clamp(320.0, 520.0);
    // compute height from aspect ratio but limit it to 85% of screen height
    final desiredHeight = (containerWidth / aspect).clamp(360.0, screenH * 0.85);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 360),
      width: containerWidth,
      height: desiredHeight,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 18, offset: const Offset(0, 12))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Use FittedBox + SizedBox to preserve video's native resolution and aspect
            FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: _videoController!.value.size.width,
                height: _videoController!.value.size.height,
                child: VideoPlayer(_videoController!),
              ),
            ),

            // Center big play/pause button overlay when paused
            Positioned.fill(
              child: GestureDetector(
                onTap: _togglePlay,
                behavior: HitTestBehavior.opaque,
                child: AnimatedOpacity(
                  opacity: _videoController!.value.isPlaying ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 220),
                  child: Container(
                    color: Colors.black26,
                    child: Center(
                      child: Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                        child: Icon(
                          _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 44,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // small top-left label with duration
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(8)),
                child: Text(
                  _formatDuration(_videoController!.value.duration),
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
                ),
              ),
            ),

            // bottom gradient hint
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 80,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.transparent, Colors.black26], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalPlayer() {
    // Use Chewie for horizontal videos (offers fullscreen button and native-like controls)
    return AspectRatio(
      aspectRatio: _videoController!.value.aspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _chewieController != null
            ? Chewie(controller: _chewieController!)
            : VideoPlayer(_videoController!),
      ),
    );
  }

  Widget _buildInfoRow() {
    final sizeBytes = _videoController!.value.isInitialized ? null : null;
    final duration = _videoController!.value.duration;
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.topicLabel,
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        if (duration != null)
          Text(
            _formatDuration(duration),
            style: GoogleFonts.inter(fontSize: 13, color: Colors.black54),
          ),
      ],
    );
  }

  Widget _buildControlRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // rewind 10s
        _controlButton(Icons.replay_10, 'Rewind 10s', () {
          if (_videoController == null) return;
          final pos = _videoController!.value.position;
          final target = pos - const Duration(seconds: 10);
          _videoController!.seekTo(target >= Duration.zero ? target : Duration.zero);
        }),

        // Play/Pause (big)
        ElevatedButton(
          onPressed: _togglePlay,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFefae78),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          ),
          child: Row(
            children: [
              Icon(_videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
              const SizedBox(width: 8),
              Text(_videoController!.value.isPlaying ? 'Pause' : 'Play', style: GoogleFonts.inter(color: Colors.white)),
            ],
          ),
        ),

        // forward 10s
        _controlButton(Icons.forward_10, 'Forward 10s', () {
          if (_videoController == null) return;
          final pos = _videoController!.value.position;
          final target = pos + const Duration(seconds: 10);
          final max = _videoController!.value.duration;
          _videoController!.seekTo(target <= max ? target : max);
        }),
      ],
    );
  }

  Widget _controlButton(IconData icon, String tooltip, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: Colors.black87),
      ),
    );
  }
}
