// lib/screens/category_list_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tercera_juventud/models/app_info.dart';
import 'topic_list_screen.dart';

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appsList = AppInfo.defaultList();
    final accent = const Color(0xFFD6C9BD); // beige pills
    final bg = const Color(0xFFF7E9E9); // soft pink background

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Aplicaciones',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            letterSpacing: 0.2,
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
                  // Intro card
                  _IntroCard(accent: accent),

                  const SizedBox(height: 18),

                  // Search / filter row (visual only, could be wired to logic)
                  _SearchAndFilterRow(),

                  const SizedBox(height: 14),

                  // The white rounded container holding list
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          // soft outer shadow
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 30,
                            offset: const Offset(0, 18),
                          ),
                          // light top-left highlight for neumorphism feel
                          BoxShadow(
                            color: Colors.white.withOpacity(0.9),
                            blurRadius: 8,
                            offset: const Offset(-8, -8),
                          ),
                        ],
                      ),
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: appsList.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final app = appsList[index];
                          return _AppPillButton(
                            appName: app.name,
                            iconData: app.iconData,
                            accent: accent,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (_) => TopicListScreen(
                                        categoryId: app.id,
                                        categoryName: app.name,
                                        topics: app.topics,
                                      ),
                                ),
                              );
                            },
                          );
                        },
                      ),
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
}

/// Intro card with short description and subtle illustration
class _IntroCard extends StatelessWidget {
  final Color accent;
  const _IntroCard({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent.withOpacity(0.98), accent.withOpacity(0.85)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.25),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
          const BoxShadow(
            color: Colors.white70,
            blurRadius: 8,
            offset: Offset(-8, -8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular illustration (icon)
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.apps_outlined,
              size: 36,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explora las aplicaciones',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Selecciona una app para ver sus actividades y reproducir los videos asociados.',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Search bar + small filter chip (visual)
class _SearchAndFilterRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFFD6C9BD);
    Row(
      children: [
        Positioned(
          bottom: -150,
          left: 0,
          right: 0,
          child: Center(
            child: FloatingActionButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Icon(Icons.arrow_back),
            ),
          ),
        ),
      ],
    );
    return Stack(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 54,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F5F4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.black45),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Buscar aplicación...',
                        style: GoogleFonts.inter(
                          color: Colors.black45,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const Icon(Icons.tune, color: Colors.black38),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: accent.withOpacity(0.18),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.filter_list, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Filtros',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// The pill-shaped button used in the list
class _AppPillButton extends StatefulWidget {
  final String appName;
  final IconData iconData;
  final Color accent;
  final VoidCallback onTap;

  const _AppPillButton({
    required this.appName,
    required this.iconData,
    required this.accent,
    required this.onTap,
  });

  @override
  State<_AppPillButton> createState() => _AppPillButtonState();
}

class _AppPillButtonState extends State<_AppPillButton>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.05,
    )..addListener(() {
      setState(() {
        _scale = 1 - _anim.value;
      });
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) => _anim.forward();
  void _onTapUp(TapUpDetails details) => _anim.reverse();
  void _onTapCancel() => _anim.reverse();

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: _scale,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: (d) {
          _onTapUp(d);
          widget.onTap();
        },
        onTapCancel: _onTapCancel,
        child: Material(
          color: Colors.transparent,
          child: Container(
            height: 78,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: widget.accent,
              borderRadius: BorderRadius.circular(36),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 12),
                ),
                const BoxShadow(
                  color: Colors.white60,
                  blurRadius: 6,
                  offset: Offset(-8, -8),
                ),
              ],
            ),
            child: Row(
              children: [
                // icon circle
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(widget.iconData, color: Colors.black87, size: 26),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Text(
                    widget.appName,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.black54,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
