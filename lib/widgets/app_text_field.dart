import 'package:flutter/material.dart';
import '../theme/app_text.dart';
import '../theme/palette.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final Widget? trailing;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.maxLines = 1,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppText.overline),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          maxLines: obscureText ? 1 : maxLines,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          style: AppText.label.copyWith(fontSize: 15, height: 1.4),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppText.body.copyWith(color: Palette.inkFaint),
            suffixIcon: trailing,
            suffixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            filled: true,
            fillColor: Palette.surface,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            border: _border(Palette.line),
            enabledBorder: _border(Palette.line),
            focusedBorder: _border(Palette.ink, width: 1.4),
            errorBorder: _border(Palette.danger),
            focusedErrorBorder: _border(Palette.danger, width: 1.4),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color, width: width),
      );
}

class AppSearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;

  const AppSearchField({
    super.key,
    required this.hint,
    required this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: AppText.label.copyWith(fontSize: 15, height: 1.4),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppText.body.copyWith(color: Palette.inkFaint, fontSize: 14.5),
        prefixIcon: const Icon(Icons.search, size: 19, color: Palette.inkFaint),
        prefixIconConstraints: const BoxConstraints(minWidth: 42, minHeight: 42),
        filled: true,
        fillColor: Palette.fill,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Palette.ink, width: 1.2),
        ),
      ),
    );
  }
}
