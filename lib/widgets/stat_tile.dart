import 'package:flutter/material.dart';
import '../theme/app_text.dart';
import '../theme/palette.dart';

class StatTile extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final ColorFamily color;
  final bool loading;

  const StatTile({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
      decoration: BoxDecoration(
        color: color.tint,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: color.deep.withValues(alpha: 0.75)),
          const SizedBox(height: 14),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            child: loading
                ? Container(
                    key: const ValueKey('placeholder'),
                    height: 24,
                    width: 30,
                    decoration: BoxDecoration(
                      color: color.deep.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  )
                : Text(
                    value,
                    key: ValueKey(value),
                    style: AppText.numeral.copyWith(fontSize: 26, color: color.deep),
                  ),
          ),
          const SizedBox(height: 5),
          Text(
            label.toUpperCase(),
            style: AppText.overline.copyWith(
              color: color.deep.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }
}
