import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(TerceraJuventudApp());
}

class TerceraJuventudApp extends StatelessWidget {
  const TerceraJuventudApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tercera Juventud',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.pinkBackground,
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.textPrimary),
          toolbarHeight: 0, // no mostrar AppBar visualmente
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => WelcomeScreen(),
        '/apps': (_) => AppsScreen(),
      },
      // We'll use push for detail screens with arguments
    );
  }
}

/* ---------- Colores y constantes ---------- */
class AppColors {
  static const Color pinkBackground = Color(0xFFF5AFB7); // fondo rosado
  static const Color cardWhite = Colors.white;
  static const Color pillBeige = Color(0xFFD6C9BD); // color de los botones tipo "pill"
  static const Color textPrimary = Color(0xFF0F0F10);
  static const Color subtleShadow = Color(0x44000000);
}

/* ---------- Datos (modelo simple) ---------- */
class AppInfo {
  final String id;
  final String name;
  final IconData icon; // placeholder - puedes reemplazar con imagen/SVG
  final List<String> topics;

  AppInfo({
    required this.id,
    required this.name,
    required this.icon,
    required this.topics,
  });
}

final List<AppInfo> appsList = [
  AppInfo(
    id: 'instagram',
    name: 'Instagram',
    icon: Icons.camera_alt_outlined,
    topics: [
      '¿Como crear una cuenta?',
      '¿Quieres publicar una historia?',
      '¿Quieres seguir a tu conocidos?',
      '¿Quieres subir una publicación?',
      '¿Cuenta privada o publica?',
    ],
  ),
  AppInfo(
    id: 'whatsapp',
    name: 'Whatsapp',
    icon: FaIcon(FontAwesomeIcons.whatsapp).icon!,
    topics: [
      '¿Como crear una cuenta?',
      'Enviar mensajes y fotos',
      'Crear y salir de grupos',
      'Hacer videollamadas',
      'Enviar ubicación',
    ],
  ),
  AppInfo(
    id: 'facebook',
    name: 'Facebook',
    icon: Icons.facebook,
    topics: [
      'Crear perfil',
      'Publicar estado',
      'Agregar amigos',
      'Configurar privacidad',
      'Uso de Marketplace',
    ],
  ),
  AppInfo(
    id: 'tiktok',
    name: 'Tik Tok',
    icon: Icons.music_note,
    topics: [
      'Crear cuenta y perfil',
      'Subir videos',
      'Explorar tendencias',
      'Usar efectos y sonidos',
      'Configurar privacidad',
    ],
  ),
];

/* ---------- Widgets y Pantallas ---------- */

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cardWidth = MediaQuery.of(context).size.width * 0.86;
    final cardHeight = MediaQuery.of(context).size.height * 0.55;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // El contenido centra la tarjeta
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 40),
                  // Espacio para la ilustración superior (usa tu asset)
                  SizedBox(
                    width: 160,
                    height: 120,
                    child: Image.asset(
                      'assets/illustration/elders.png',
                      fit: BoxFit.contain,
                      // si no tienes imagen, crea un placeholder en assets o comenta la línea
                    ),
                  ),
                  SizedBox(height: 8),
                  Center(
                    child: Container(
                      width: cardWidth,
                      height: cardHeight,
                      decoration: BoxDecoration(
                        color: AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.subtleShadow,
                            blurRadius: 24,
                            spreadRadius: 4,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tercera Juventud',
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Esta aplicación se creó con el fin de aprender sobre el uso de las redes sociales',
                            style: TextStyle(fontSize: 24, color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 24),
                          Text(
                            'This application was created with the purpose of learning about the use of social networks',
                            style: TextStyle(fontSize: 24, color: AppColors.textPrimary ),
                          ),
                          Spacer(),
                          Center(
                            child: SizedBox(
                              width: cardWidth * 0.72,
                              height: 64,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.pillBeige,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pushNamed('/apps');
                                },
                                child: Text(
                                  'Comencemos',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 90), // espacio para el botón circular inferior
                ],
              ),
            ),
            // botón circular inferior (solo decorativo en bienvenida)
            Positioned(
              bottom: 36,
              child: CircularIconButton(
                icon: Icons.arrow_back,
                onTap: () {
                  // en la pantalla inicial no hacemos nada, pero dejamos la posibilidad
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cardWidth = MediaQuery.of(context).size.width * 0.86;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 30),
                  Center(
                    child: Container(
                      width: cardWidth,
                      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 18),
                      decoration: BoxDecoration(
                        color: AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.subtleShadow,
                            blurRadius: 26,
                            spreadRadius: 4,
                            offset: Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              'Aplicaciones',
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                            ),
                          ),
                          SizedBox(height: 18),
                          ...appsList.map((app) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => AppDetailScreen(appInfo: app),
                                    ),
                                  );
                                },
                                child: Container(
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: AppColors.pillBeige,
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 14),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.white,
                                        child: Icon(app.icon, color: AppColors.textPrimary),
                                      ),
                                      SizedBox(width: 14),
                                      Text(
                                        app.name,
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 120),
                ],
              ),
            ),
            // botón circular inferior - volvemos a la pantalla anterior
            Positioned(
              bottom: 36,
              left: 0,
              right: 0,
              child: Center(
                child: CircularIconButton(
                  icon: Icons.arrow_back,
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppDetailScreen extends StatelessWidget {
  final AppInfo appInfo;

  const AppDetailScreen({super.key, required this.appInfo});

  @override
  Widget build(BuildContext context) {
    final cardWidth = MediaQuery.of(context).size.width * 0.86;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 24),
                  // Icono grande centrado (placeholder)
                  Container(
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.0),
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 40,
                      child: Icon(appInfo.icon, size: 50, color: AppColors.textPrimary),
                    ),
                  ),
                  SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: cardWidth,
                      padding: EdgeInsets.symmetric(vertical: 18, horizontal: 18),
                      decoration: BoxDecoration(
                        color: AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.subtleShadow,
                            blurRadius: 26,
                            spreadRadius: 4,
                            offset: Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            appInfo.name,
                            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 14),
                          ...appInfo.topics.map((t) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  color: AppColors.pillBeige,
                                  borderRadius: BorderRadius.circular(36),
                                ),
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.symmetric(horizontal: 18),
                                child: Text(
                                  t,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 140),
                ],
              ),
            ),
            // botón circular inferior - vuelve atrás
            Positioned(
              bottom: 36,
              left: 0,
              right: 0,
              child: Center(
                child: CircularIconButton(
                  icon: Icons.arrow_back,
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------- Botón circular reutilizable ---------- */
class CircularIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const CircularIconButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Material(
        elevation: 8,
        shape: CircleBorder(),
        child: Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey.shade300],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Icon(icon, size: 36, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}
