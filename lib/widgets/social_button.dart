import 'package:flutter/material.dart';
import '../theme/app_text.dart';
import '../theme/palette.dart';

class SocialButton extends StatelessWidget {
  final String imagePath;
  final String label;
  final VoidCallback? onPressed;

  const SocialButton({
    super.key,
    required this.imagePath,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Palette.surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Palette.line),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(imagePath, height: 17),
              const SizedBox(width: 9),
              Text(label, style: AppText.button.copyWith(color: Palette.ink)),
            ],
          ),
        ),
      ),
    );
  }
}
