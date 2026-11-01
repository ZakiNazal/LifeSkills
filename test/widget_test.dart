import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lifeskills/util/splash_screen.dart';

void main() {
  testWidgets('SplashScreen renders title and tagline', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(),
      ),
    );

    expect(find.text('LifeSkills'), findsOneWidget);
    expect(find.text('PRACTICE, DAILY'), findsOneWidget);
  });
}
