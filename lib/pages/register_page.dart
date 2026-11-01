import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme/app_text.dart';
import '../theme/palette.dart';
import '../widgets/app_button.dart';
import '../widgets/app_snack.dart';
import '../widgets/app_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_loading) return;

    final name = _name.text.trim();
    final email = _email.text.trim();
    final password = _password.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      showSnack(context, 'Fill in all three fields', isError: true);
      return;
    }

    setState(() => _loading = true);
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set({
        'name': name,
        'email': email,
        'photoUrl': null,
        'photoData': null,
        'bio': '',
        'exercisesCompleted': 0,
        'points': 0,
        'streak': 0,
        'dailyGoal': 3,
        'sessionsToday': 0,
        'activeDays': <String>[],
      });

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
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

  String _messageFor(String code) => switch (code) {
        'weak-password' => 'Use at least 6 characters.',
        'email-already-in-use' => 'That email already has an account.',
        'invalid-email' => 'That email address is not valid.',
        'network-request-failed' => 'No connection. Check your network.',
        _ => 'Could not create your account. Try again.',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.paper,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 21),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          children: [
            Text('Create\naccount', style: AppText.display),
            const SizedBox(height: 14),
            Text('Takes about thirty seconds.', style: AppText.body),
            const SizedBox(height: 40),
            AppTextField(
              controller: _name,
              label: 'Full name',
              hint: 'Your name',
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 18),
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
              hint: 'At least 6 characters',
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
            AppButton('Create account', loading: _loading, onPressed: _register),
            const SizedBox(height: 28),
            Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text.rich(
                    TextSpan(
                      text: 'Already have one?  ',
                      style: AppText.meta,
                      children: [
                        TextSpan(
                          text: 'Sign in',
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
