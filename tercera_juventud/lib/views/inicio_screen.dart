// lib/screens/welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tercera_juventud/views/login_screen.dart';

/// Beautiful redesigned Welcome screen for "Tercera Juventud".
/// - Use asset: assets/illustration/elders.png (recommended)
/// - Navigates to '/apps' when pressing the main CTA
/// - Self-contained AppColors and CircularIconButton widgets for easy reuse
class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  bool _ctaPressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    WidgetsBinding.instance.addPostFrameCallback((_) => _ctrl.forward());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onCTA() async {
    // small tap animation for CTA
    setState(() => _ctaPressed = true);
    await Future.delayed(const Duration(milliseconds: 160));
    if (!mounted) return;
    setState(() => _ctaPressed = false);
    Navigator.of(context).pushNamed('/category');
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final cardWidth = (mq.size.width > 700) ? 600.0 : mq.size.width * 0.88;
    final cardHeight = (mq.size.height > 800) ? 520.0 : mq.size.height * 0.58;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background gradient + subtle vignette
            Positioned.fill(child: _buildBackground()),

            // Content (scrollable for small heights)
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 6),

                      // Illustration (Hero for later animations if needed)
                      Center(
                        child: Hero(
                          tag: 'elders-illustration',
                          child: Container(
                            width: 180,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 18, offset: const Offset(0, 12)),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                'assets/illustration/elders.png',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) {
                                  // graceful fallback if asset missing
                                  return Container(
                                    color: Colors.white,
                                    child: const Center(child: Icon(Icons.people_alt, size: 56, color: Colors.black26)),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Elevated card with content
                      Center(
                        child: Container(
                          width: cardWidth,
                          height: cardHeight,
                          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 22),
                          decoration: BoxDecoration(
                            color: AppColors.cardWhite,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(color: AppColors.shadowColor, blurRadius: 34, spreadRadius: 2, offset: const Offset(0, 18)),
                              const BoxShadow(color: Colors.white70, blurRadius: 8, offset: Offset(-10, -10)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              Text(
                                'Tercera Juventud',
                                style: GoogleFonts.poppins(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  height: 1.02,
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Subtitle Spanish (larger, friendly)
                              Text(
                                'Aprendamos juntos sobre el uso de las redes sociales',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary.withOpacity(0.95),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Body bilingual - nice spacing
                              Text(
                                'Esta aplicación fue creada para que adultos mayores practiquen paso a paso funcionalidades comunes como crear cuentas, publicar y configurar privacidad.',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  color: AppColors.textPrimary.withOpacity(0.85),
                                  height: 1.4,
                                ),
                              ),

                              const Spacer(),

                              // CTA centered
                              Center(
                                child: Transform.scale(
                                  scale: _ctaPressed ? 0.98 : 1.0,
                                  child: Semantics(
                                    button: true,
                                    label: 'Comencemos, abrir lista de aplicaciones',
                                    child: ElevatedButton(
                                      onPressed: _onCTA,
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                                        backgroundColor: AppColors.pillBeige,
                                        foregroundColor: AppColors.textPrimary,
                                        elevation: 8,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                                        shadowColor: AppColors.shadowColor.withOpacity(0.2),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Comencemos',
                                            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700),
                                          ),
                                          const SizedBox(width: 10),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.9),
                                              shape: BoxShape.circle,
                                            ),
                                            padding: const EdgeInsets.all(6),
                                            child: Icon(Icons.chevron_right, color: AppColors.textPrimary),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 6),
                              // small helper text
                              Center(
                                child: Text(
                                  'Toca para ver las aplicaciones y tutoriales',
                                  style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 28,
              right: 28,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LoginScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pillBeige,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                ),
                child: Text(
                  'Iniciar sesión',
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
            ),

            // Circular bottom button (floating decorative / optional back)
            Positioned(
              bottom: 28,
              child: CircularIconButton(
                icon: Icons.arrow_back,
                onTap: () {
                  // optionally navigate or show toast; on welcome screen keep decorative
                },
                tooltip: 'Atrás',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.pinkLight, AppColors.pinkDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          // subtle radial vignette
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.4),
                  radius: 1.1,
                  colors: [Colors.white.withOpacity(0.08), Colors.transparent],
                  stops: const [0.0, 0.6],
                ),
              ),
            ),
          ),
          // Soft rounded corner overlay (decor)
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(60),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(80),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small reusable circular button used in designs (3D feel)
class CircularIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  const CircularIconButton({required this.icon, required this.onTap, this.tooltip, super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip ?? 'Botón',
      child: GestureDetector(
        onTap: onTap,
        child: Material(
          elevation: 10,
          shape: const CircleBorder(),
          child: Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Colors.white, Colors.grey.shade300], begin: Alignment.topLeft, end: Alignment.bottomRight),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 8)),
              ],
            ),
            child: Center(child: Icon(icon, size: 34, color: AppColors.textPrimary)),
          ),
        ),
      ),
    );
  }
}

/// Colors used in the screen
class AppColors {
  static const Color pinkLight = Color(0xFFF8D4D9);
  static const Color pinkDark = Color(0xFFF2A9B4);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color pillBeige = Color(0xFFD6C9BD);
  static const Color textPrimary = Color(0xFF1B1B1F);
  static const Color shadowColor = Color(0x33000000);
}
