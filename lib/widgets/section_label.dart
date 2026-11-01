import 'package:flutter/material.dart';
import '../theme/app_text.dart';

class SectionLabel extends StatelessWidget {
  final String text;
  final String? trailing;

  const SectionLabel(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text.toUpperCase(), style: AppText.overline),
          if (trailing != null) Text(trailing!, style: AppText.overline),
        ],
      ),
    );
  }
}
