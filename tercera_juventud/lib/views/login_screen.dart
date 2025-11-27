import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tercera_juventud/views/registro_videos.dart';
import 'package:tercera_juventud/views/upload_video_screen.dart';
import '../widgets/wave_header.dart';
import '../widgets/gradient_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  final Color accent = const Color(0xFFefae78);

  // Puedes añadir scopes si necesitas más que el email
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>['email'],
    // You can provide a webClientId here if needed:
    // clientId: '<YOUR_WEB_CLIENT_ID>',
  );

  @override
  void initState() {
    super.initState();

    // Listener para cambios en el usuario (útil si quieres reaccionar a sign-in desde otro sitio)
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) async {
      if (account != null) {
        try {
          if (!mounted) return;
          setState(() => _loading = true);

          final GoogleSignInAuthentication auth = await account.authentication;
          final credential = GoogleAuthProvider.credential(
            idToken: auth.idToken,
            accessToken: auth.accessToken,
          );

          await FirebaseAuth.instance.signInWithCredential(credential);

          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const RegistroVideosPage()),
          );
        } catch (e) {
          _showError(e.toString());
        } finally {
          if (!mounted) return;
          setState(() => _loading = false);
        }
      }
    });

    // Intenta sign-in silencioso (restaura sesión si existe)
    _googleSignIn.signInSilently().catchError((_) {
      // Ignorar errores silenciosos
    });
  }

  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    if (!mounted) return;

    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const RegistroVideosPage()),
      );
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Auth error');
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  /// Sign in with Google (works on web & mobile with google_sign_in: ^7.2.0)
  Future<void> _signInWithGoogle() async {
    if (!mounted) return;
    setState(() => _loading = true);

    try {
      // Abre el flujo de selección de cuenta / popup en web
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      // Si el usuario canceló
      if (account == null) {
        if (!mounted) return;
        setState(() => _loading = false);
        return;
      }

      final GoogleSignInAuthentication auth = await account.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: auth.idToken,
        accessToken: auth.accessToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const RegistroVideosPage()),
      );
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Firebase auth failed');
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final widthCard = MediaQuery.of(context).size.width * 0.88;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            WaveHeader(
              startColor: accent,
              endColor: accent.withOpacity(0.85),
              height: 240,
              child: Padding(
                padding: const EdgeInsets.only(left: 20, top: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Hello,\nSign in!',
                    style: GoogleFonts.poppins(
                      color: const Color.fromARGB(255, 51, 3, 40),
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: Container(
                width: widthCard,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 18,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Enter Your Email',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: UnderlineInputBorder(),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Enter email' : null,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline),
                          border: UnderlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (v) => (v == null || v.length < 6) ? 'Min 6 characters' : null,
                      ),
                      const SizedBox(height: 18),
                      if (_loading)
                        const CircularProgressIndicator()
                      else
                        GradientButton(
                          text: 'Sign in',
                          onPressed: _signInWithEmail,
                          width: double.infinity,
                          height: 48,
                        ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          // Acción recuperar contraseña
                        },
                        child: const Text('Forgot Password'),
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _loading ? null : _signInWithGoogle,
                        icon: Image.asset(
                          'icons/google.png',
                          width: 20,
                          height: 20,
                        ), // Asegúrate de declarar este asset
                        label: const Text('Sign in with Google'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have account?"),
                          TextButton(
                            onPressed: () => Navigator.of(context).pushNamed('/signup'),
                            child: const Text('Sign up'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
