import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/wave_header.dart';
import '../widgets/gradient_button.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  final Color accent = const Color(0xFFefae78);

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );
      await cred.user?.updateDisplayName(_nameCtrl.text.trim());
      // Navegar o mostrar éxito
      Navigator.of(context).pop(); // vuelve al login
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Signup error');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
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
                    'Create Your\nAccount',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
            SizedBox(height: 18),
            Center(
              child: Container(
                width: widthCard,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 18, offset: Offset(0, 10))],
                ),
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: InputDecoration(
                          hintText: 'Full Name',
                          prefixIcon: Icon(Icons.person_outline),
                          border: UnderlineInputBorder(),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Enter name' : null,
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _emailCtrl,
                        decoration: InputDecoration(
                          hintText: 'Phone or Email',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: UnderlineInputBorder(),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Enter contact' : null,
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _passCtrl,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline),
                          border: UnderlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (v) => (v == null || v.length < 6) ? 'Min 6 chars' : null,
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _confirmCtrl,
                        decoration: InputDecoration(
                          hintText: 'Confirm Password',
                          prefixIcon: Icon(Icons.lock_outline),
                          border: UnderlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (v) => v != _passCtrl.text ? 'Passwords do not match' : null,
                      ),
                      SizedBox(height: 16),
                      _loading ? CircularProgressIndicator() : GradientButton(
                        text: 'Sign up',
                        onPressed: _signup,
                        width: double.infinity,
                        height: 48,
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Already have an account?'),
                          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Sign in')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
