import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_text.dart';
import '../theme/palette.dart';

class ChoicePill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const ChoicePill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Palette.ink : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? Palette.ink : Palette.line),
        ),
        child: Text(
          label,
          style: AppText.label.copyWith(
            fontSize: 13.5,
            color: selected ? Colors.white : Palette.inkSoft,
          ),
        ),
      ),
    );
  }
}
