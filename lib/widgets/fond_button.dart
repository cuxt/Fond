import 'package:flutter/material.dart';

class FondButton extends StatelessWidget {
  final VoidCallback onTap;
  final String buttonText;
  final Color? color;

  const FondButton({
    super.key,
    required this.onTap,
    required this.buttonText,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 12),
        backgroundColor: color ?? Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onTap,
      child: Text(
        buttonText,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
