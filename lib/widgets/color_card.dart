import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_text.dart';
import '../theme/palette.dart';

class ColorCard extends StatefulWidget {
  final String title;
  final String meta;
  final IconData icon;
  final ColorFamily color;
  final VoidCallback onTap;

  const ColorCard({
    super.key,
    required this.title,
    required this.meta,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<ColorCard> createState() => _ColorCardState();
}

class _ColorCardState extends State<ColorCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.color;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 15),
          decoration: BoxDecoration(
            color: color.tint,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(widget.icon, size: 24, color: color.deep),
                  Icon(Icons.arrow_outward,
                      size: 15, color: color.deep.withValues(alpha: 0.45)),
                ],
              ),
              const Spacer(),
              Text(
                widget.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppText.h3.copyWith(fontSize: 16, color: color.deep),
              ),
              const SizedBox(height: 3),
              Text(
                widget.meta,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.meta.copyWith(
                  fontSize: 12.5,
                  color: color.deep.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
