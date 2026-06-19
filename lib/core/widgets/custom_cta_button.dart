import 'package:flutter/material.dart';


class CustomCtaButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomCtaButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(30)),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(fontSize: 18, color: colorScheme.onPrimary, inherit: true),
        ),
      ),
    );
  }
}
