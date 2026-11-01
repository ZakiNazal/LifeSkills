import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme/app_text.dart';
import '../theme/palette.dart';
import '../widgets/app_button.dart';
import '../widgets/app_snack.dart';
import '../widgets/app_text_field.dart';
import '../widgets/social_button.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_loading) return;

    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) {
      showSnack(context, 'Enter your email and password', isError: true);
      return;
    }

    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      showSnack(context, _messageFor(e.code), isError: true);
    } catch (_) {
      if (!mounted) return;
      showSnack(context, 'Something went wrong. Try again.', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _notWired(String provider) {
    showSnack(context, '$provider sign in is not set up yet');
  }

  String _messageFor(String code) => switch (code) {
        'invalid-email' => 'That email address is not valid.',
        'user-disabled' => 'This account has been disabled.',
        'user-not-found' ||
        'wrong-password' ||
        'invalid-credential' =>
          'Email or password is incorrect.',
        'too-many-requests' => 'Too many attempts. Wait a minute and try again.',
        'network-request-failed' => 'No connection. Check your network.',
        _ => 'Could not sign you in. Try again.',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.paper,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          children: [
            Text('LIFESKILLS', style: AppText.overline),
            const SizedBox(height: 56),
            Text('Welcome\nback', style: AppText.display),
            const SizedBox(height: 14),
            Text('Sign in to pick up where you left off.', style: AppText.body),
            const SizedBox(height: 40),
            AppTextField(
              controller: _email,
              label: 'Email',
              hint: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 18),
            AppTextField(
              controller: _password,
              label: 'Password',
              obscureText: _obscure,
              trailing: IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  size: 19,
                  color: Palette.inkFaint,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            const SizedBox(height: 28),
            AppButton('Sign in', loading: _loading, onPressed: _signIn),
            const SizedBox(height: 28),
            Row(
              children: [
                const Expanded(child: Divider(color: Palette.line)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text('OR', style: AppText.overline),
                ),
                const Expanded(child: Divider(color: Palette.line)),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SocialButton(
                    imagePath: 'asset/images/google.png',
                    label: 'Google',
                    onPressed: () => _notWired('Google'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SocialButton(
                    imagePath: 'asset/images/apple.png',
                    label: 'Apple',
                    onPressed: () => _notWired('Apple'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Center(
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                ),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text.rich(
                    TextSpan(
                      text: 'New here?  ',
                      style: AppText.meta,
                      children: [
                        TextSpan(
                          text: 'Create an account',
                          style: AppText.label.copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
