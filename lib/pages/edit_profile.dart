import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/app_text.dart';
import '../theme/palette.dart';
import '../widgets/app_button.dart';
import '../widgets/app_snack.dart';
import '../widgets/app_text_field.dart';
import '../widgets/avatar.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Firestore caps a document at 1 MiB. Stay well clear of it, the whole user
  // document has to fit, not just the photo.
  static const _maxEncodedBytes = 700 * 1024;

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _bio = TextEditingController();
  final _user = FirebaseAuth.instance.currentUser;

  Uint8List? _pickedBytes;
  String? _photoData;
  String? _photoUrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final user = _user;
    if (user == null) return;
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (!mounted || !snap.exists) return;
      final data = snap.data()!;
      setState(() {
        _name.text = data['name'] as String? ?? '';
        _email.text = user.email ?? '';
        _bio.text = data['bio'] as String? ?? '';
        _photoData = data['photoData'] as String?;
        _photoUrl = data['photoUrl'] as String?;
      });
    } catch (_) {
      if (!mounted) return;
      showSnack(context, 'Could not load your profile', isError: true);
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 70,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    if (!mounted) return;

    if (base64Encode(bytes).length > _maxEncodedBytes) {
      showSnack(context, 'That image is too large. Try a different one.',
          isError: true);
      return;
    }
    setState(() => _pickedBytes = bytes);
  }

  Future<void> _save() async {
    final user = _user;
    if (user == null || _saving) return;

    if (_name.text.trim().isEmpty || _email.text.trim().isEmpty) {
      showSnack(context, 'Name and email cannot be empty', isError: true);
      return;
    }

    setState(() => _saving = true);
    try {
      final update = <String, dynamic>{
        'name': _name.text.trim(),
        'bio': _bio.text.trim(),
      };
      if (_pickedBytes != null) {
        update['photoData'] = base64Encode(_pickedBytes!);
        // Any old Storage URL is dead now, do not leave it to fall back to.
        update['photoUrl'] = null;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(update, SetOptions(merge: true));

      final newEmail = _email.text.trim();
      final emailChanged = newEmail != user.email;
      if (emailChanged) {
        await user.verifyBeforeUpdateEmail(newEmail);
      }

      if (!mounted) return;
      showSnack(
        context,
        emailChanged
            ? 'Saved. Check your inbox to confirm the new email.'
            : 'Profile saved',
      );
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      showSnack(context, _messageFor(e.code), isError: true);
    } catch (_) {
      if (!mounted) return;
      showSnack(context, 'Could not save your changes', isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _messageFor(String code) => switch (code) {
        'email-already-in-use' => 'That email is already used by another account.',
        'invalid-email' => 'That email address is not valid.',
        'requires-recent-login' => 'Sign out and back in, then try again.',
        _ => 'Could not update the profile.',
      };

  @override
  Widget build(BuildContext context) {
    final hasPhoto = _pickedBytes != null ||
        (_photoData?.isNotEmpty ?? false) ||
        (_photoUrl?.isNotEmpty ?? false);

    return Scaffold(
      backgroundColor: Palette.paper,
      appBar: AppBar(
        title: const Text('Edit profile'),
        leading: IconButton(
          icon: const Icon(Icons.close, size: 21),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
        children: [
          Row(
            children: [
              Avatar(
                size: 74,
                photoData: _photoData,
                photoUrl: _photoUrl,
                previewBytes: _pickedBytes,
                onTap: _pickImage,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: AppButton(
                  hasPhoto ? 'Change photo' : 'Add photo',
                  style: AppButtonStyle.outlined,
                  onPressed: _pickImage,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Photos are resized to 512px and stored on your profile.',
            style: AppText.meta,
          ),
          const SizedBox(height: 28),
          AppTextField(
            controller: _name,
            label: 'Full name',
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 18),
          AppTextField(
            controller: _email,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 18),
          AppTextField(
            controller: _bio,
            label: 'Bio',
            hint: 'A line or two about you',
            maxLines: 4,
          ),
          const SizedBox(height: 12),
          Text(
            'Changing your email sends a confirmation link before it takes effect.',
            style: AppText.meta,
          ),
          const SizedBox(height: 30),
          AppButton('Save changes', loading: _saving, onPressed: _save),
        ],
      ),
    );
  }
}
