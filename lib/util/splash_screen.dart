import 'package:flutter/material.dart';
import '../theme/app_text.dart';
import '../theme/palette.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  late final CurvedAnimation _curve =
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

  late final Animation<Offset> _rise = Tween<Offset>(
    begin: const Offset(0, 0.12),
    end: Offset.zero,
  ).animate(_curve);

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.paper,
      body: Center(
        child: FadeTransition(
          opacity: _curve,
          child: SlideTransition(
            position: _rise,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('LifeSkills', style: AppText.display.copyWith(fontSize: 36)),
                const SizedBox(height: 12),
                Text('PRACTICE, DAILY', style: AppText.overline),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
