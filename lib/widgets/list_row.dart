import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_text.dart';
import '../theme/palette.dart';

class ListRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? trailingText;
  final IconData? icon;
  final Color? titleColor;
  final bool showChevron;
  final VoidCallback? onTap;

  const ListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.trailingText,
    this.icon,
    this.titleColor,
    this.showChevron = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = titleColor ?? Palette.ink;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap == null
            ? null
            : () {
                HapticFeedback.selectionClick();
                onTap!();
              },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 19, color: titleColor ?? Palette.inkSoft),
                const SizedBox(width: 14),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppText.h3.copyWith(color: color)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(subtitle!, style: AppText.meta),
                    ],
                  ],
                ),
              ),
              if (trailingText != null)
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(trailingText!, style: AppText.meta),
                ),
              if (showChevron) ...[
                const SizedBox(width: 10),
                const Icon(Icons.chevron_right, size: 19, color: Palette.inkFaint),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class RowGroup extends StatelessWidget {
  final List<Widget> children;
  final double indent;

  const RowGroup({super.key, required this.children, this.indent = 0});

  @override
  Widget build(BuildContext context) {
    final out = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      out.add(children[i]);
      if (i != children.length - 1) {
        out.add(Padding(
          padding: EdgeInsets.only(left: indent),
          child: const Divider(height: 1, thickness: 1, color: Palette.lineSoft),
        ));
      }
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: out);
  }
}
