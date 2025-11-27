import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final double height;
  final double width;

  const GradientButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.height = 46,
    this.width = 160,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color c = const Color(0xFFefae78); // tema
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          padding: EdgeInsets.zero,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              // ignore: deprecated_member_use
              colors: [c.withAlpha((c.opacity * 0.95).toInt()), c.withAlpha((c.opacity * 0.8).toInt())],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Text(text, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}
