import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../pages/home_page.dart';
import '../pages/login_page.dart';
import '../theme/palette.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.active) {
          return const Scaffold(
            backgroundColor: Palette.paper,
            body: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        return snapshot.data == null ? const LoginPage() : const HomePage();
      },
    );
  }
}
