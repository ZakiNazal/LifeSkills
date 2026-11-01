import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_text.dart';
import '../theme/palette.dart';

enum AppButtonStyle { filled, outlined, quiet }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonStyle style;
  final bool loading;
  final bool expand;
  final IconData? icon;
  final Color? tint;

  const AppButton(
    this.label, {
    super.key,
    this.onPressed,
    this.style = AppButtonStyle.filled,
    this.loading = false,
    this.expand = true,
    this.icon,
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    final base = tint ?? Palette.ink;
    final filled = style == AppButtonStyle.filled;
    final disabled = onPressed == null || loading;

    final background = switch (style) {
      AppButtonStyle.filled => disabled ? base.withValues(alpha: 0.35) : base,
      AppButtonStyle.outlined => Colors.transparent,
      AppButtonStyle.quiet => Palette.fill,
    };
    final foreground = filled ? Colors.white : (disabled ? Palette.inkFaint : base);

    return Opacity(
      opacity: disabled && !loading ? 0.9 : 1,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: disabled
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  onPressed!();
                },
          child: Container(
            height: 52,
            width: expand ? double.infinity : null,
            padding: EdgeInsets.symmetric(horizontal: expand ? 20 : 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: style == AppButtonStyle.outlined
                  ? Border.all(color: Palette.line, width: 1)
                  : null,
            ),
            child: Center(
              child: loading
                  ? SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, size: 18, color: foreground),
                          const SizedBox(width: 9),
                        ],
                        Text(label, style: AppText.button.copyWith(color: foreground)),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
