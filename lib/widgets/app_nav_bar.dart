import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_text.dart';
import '../theme/palette.dart';

class NavDestination {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const NavDestination({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class AppNavBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  final List<NavDestination> destinations;

  const AppNavBar({
    super.key,
    required this.index,
    required this.onChanged,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Palette.paper,
        border: Border(top: BorderSide(color: Palette.line)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Row(
            children: [
              for (var i = 0; i < destinations.length; i++)
                Expanded(child: _item(i, destinations[i])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(int i, NavDestination dest) {
    final active = i == index;
    return InkWell(
      onTap: () {
        if (active) return;
        HapticFeedback.selectionClick();
        onChanged(i);
      },
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            active ? dest.activeIcon : dest.icon,
            size: 22,
            color: active ? Palette.ink : Palette.inkFaint,
          ),
          const SizedBox(height: 5),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 160),
            style: AppText.overline.copyWith(
              fontSize: 10,
              letterSpacing: 0.6,
              color: active ? Palette.ink : Palette.inkFaint,
              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
            ),
            child: Text(dest.label.toUpperCase()),
          ),
        ],
      ),
    );
  }
}
