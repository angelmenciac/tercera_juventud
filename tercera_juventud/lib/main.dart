import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tercera_juventud/firebase_options.dart';
import 'package:tercera_juventud/views/category_list_screen.dart';
import 'package:tercera_juventud/views/inicio_screen.dart';
import 'package:tercera_juventud/views/welcome_screen.dart';
import 'package:tercera_juventud/views/login_screen.dart';
import 'package:tercera_juventud/views/signup_screen.dart';
import 'package:tercera_juventud/views/registro_videos.dart';
import 'package:google_sign_in/google_sign_in.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Configura GoogleSignIn globalmente
  final googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? '370214043232-9o7q39ea4okqfpp0ts5vl0c464qkgu6d.apps.googleusercontent.com' : null,
  );
  
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
         '/': (_) => InicioScreen(), //WelcomeScreen(),
        '/apps': (_) => AppsScreen(), //CategoryListScreen(),
        '/category': (_) => CategoryListScreen(),
        '/login': (_) => LoginScreen(),
        '/signup': (_) => SignupScreen(),
        '/registro_videos': (_) => RegistroVideosPage(),
        
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
