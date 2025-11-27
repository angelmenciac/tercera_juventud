// lib/screens/topic_list_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'video_player_screen.dart';

class TopicListScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final List<String> topics;

  const TopicListScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.topics,
  });

  @override
  State<TopicListScreen> createState() => _TopicListScreenState();
}

class _TopicListScreenState extends State<TopicListScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  static const Duration _totalAnimDuration = Duration(milliseconds: 600);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: _totalAnimDuration);
    // start animation after frame renders
    WidgetsBinding.instance.addPostFrameCallback((_) => _animController.forward());
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFFD6C9BD); // beige tone
    final bg = const Color(0xFFF7E9E9); // soft pink background

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: BackButton(color: Colors.black87),
        title: Text(
          widget.categoryName,
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        foregroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Column(
                children: [
                  // Small informative header card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 12)),
                        BoxShadow(color: Colors.white.withOpacity(0.9), blurRadius: 6, offset: const Offset(-8, -8)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: accent,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: accent.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 8))],
                          ),
                          child: Center(
                            child: Icon(Icons.play_circle_fill, color: Colors.white, size: 30),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Selecciona la acción que quieres aprender — el video correspondiente se reproducirá automáticamente.',
                            style: GoogleFonts.inter(fontSize: 14.5, color: Colors.black87, height: 1.25),
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // White card containing the topics
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 14)),
                          BoxShadow(color: Colors.white.withOpacity(0.9), blurRadius: 6, offset: const Offset(-8, -8)),
                        ],
                      ),
                      child: _buildTopicsList(accent),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopicsList(Color accent) {
    final topics = widget.topics;
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: topics.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final topic = topics[index];

        // staggered animation: compute interval slice for this item
        final start = (index * 0.08).clamp(0.0, 0.8);
        final end = (start + 0.55).clamp(0.0, 1.0);
        final itemCurve = Interval(start, end, curve: Curves.easeOut);

        final animation = CurvedAnimation(parent: _animController, curve: itemCurve);

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(animation),
            child: _TopicTile(
              topic: topic,
              accent: accent,
              onTap: () {
                // navigate to video player screen passing categoryId and topicLabel
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => VideoPlayerScreen(categoryId: widget.categoryId, topicLabel: topic),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

/// Individual topic tile with neumorphism + accessible hit area and small tap animation.
class _TopicTile extends StatefulWidget {
  final String topic;
  final Color accent;
  final VoidCallback onTap;

  const _TopicTile({
    required this.topic,
    required this.accent,
    required this.onTap,
  });

  @override
  State<_TopicTile> createState() => _TopicTileState();
}

class _TopicTileState extends State<_TopicTile> with SingleTickerProviderStateMixin {
  late final AnimationController _pressAnim;
  double _elevation = 12.0;

  @override
  void initState() {
    super.initState();
    _pressAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _pressAnim.addListener(() {
      setState(() {
        // elevation reduces slightly while pressing
        _elevation = 12 - (_pressAnim.value * 8);
      });
    });
  }

  @override
  void dispose() {
    _pressAnim.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _pressAnim.forward();
  void _onTapUp(TapUpDetails _) {
    _pressAnim.reverse();
    widget.onTap();
  }

  void _onTapCancel() => _pressAnim.reverse();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.topic,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: widget.accent,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: _elevation, offset: Offset(0, _elevation / 2)),
              const BoxShadow(color: Colors.white60, blurRadius: 6, offset: Offset(-8, -8)),
            ],
          ),
          child: Row(
            children: [
              // small bullet / icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 6))],
                ),
                child: const Icon(Icons.play_arrow, color: Colors.black87),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.topic,
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Colors.black54, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}
