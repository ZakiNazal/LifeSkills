// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();
  File? _image;
  String? _currentPhotoUrl;
  bool _isLoading = false;
  final _user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    if (_user == null) return;
    try {
      final snap = await FirebaseFirestore.instance.collection('users').doc(_user.uid).get();
      if (!mounted || !snap.exists) return;
      final data = snap.data()!;
      setState(() {
        _nameController.text = data['name'] as String? ?? '';
        _emailController.text = _user.email ?? '';
        _bioController.text = data['bio'] as String? ?? '';
        _currentPhotoUrl = data['photoUrl'] as String?;
      });
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) setState(() => _image = File(picked.path));
  }

  Future<void> _saveProfile() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Save Changes', style: TextStyle(fontFamily: 'Rubik', fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to save these changes?', style: TextStyle(fontFamily: 'Rubik')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: Colors.black))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save', style: TextStyle(color: Colors.black))),
        ],
      ),
    );
    if (confirm != true) return;
    if (_user == null) return;

    if (_nameController.text.trim().isEmpty || _emailController.text.trim().isEmpty) {
      _showSnack('Name and email cannot be empty', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? photoUrl = _currentPhotoUrl;
      if (_image != null) {
        final ref = FirebaseStorage.instance.ref().child('user_images').child('${_user.uid}.jpg');
        await ref.putFile(_image!);
        photoUrl = await ref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('users').doc(_user.uid).update({
        'name': _nameController.text.trim(),
        'bio': _bioController.text.trim(),
        if (photoUrl != null) 'photoUrl': photoUrl,
      });

      if (_emailController.text.trim() != _user.email) {
        await _user.verifyBeforeUpdateEmail(_emailController.text.trim());
        _showSnack('Verification email sent. Check your inbox to confirm the new address.');
      } else {
        _showSnack('Profile updated successfully');
      }

      if (!mounted) return;
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      final msg = switch (e.code) {
        'email-already-in-use' => 'This email is already used by another account.',
        'invalid-email' => 'The email address is not valid.',
        'requires-recent-login' => 'Please sign out and sign back in, then try again.',
        _ => 'An error occurred while updating the profile.',
      };
      _showSnack(msg, isError: true);
    } catch (e) {
      _showSnack('Error updating profile: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Rubik')),
        backgroundColor: isError ? Colors.red[700] : const Color(0xff10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF0F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xff1565c0),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Edit Profile', style: TextStyle(fontFamily: 'Rubik', fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 58,
                    backgroundColor: const Color(0xff1565c0).withValues(alpha: 0.1),
                    backgroundImage: _image != null
                        ? FileImage(_image!) as ImageProvider
                        : (_currentPhotoUrl != null ? NetworkImage(_currentPhotoUrl!) : null),
                    child: (_image == null && _currentPhotoUrl == null)
                        ? const Icon(Icons.person_rounded, size: 52, color: Color(0xff1565c0))
                        : null,
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: const BoxDecoration(color: Color(0xff1565c0), shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text('Tap to change photo', style: TextStyle(fontFamily: 'Rubik', fontSize: 13, color: Color(0xff64748B))),
            const SizedBox(height: 28),
            _buildCard([
              _Field(controller: _nameController, label: 'Full Name', icon: Icons.person_outline_rounded),
              const SizedBox(height: 14),
              _Field(controller: _emailController, label: 'Email', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 14),
              _Field(controller: _bioController, label: 'Bio', icon: Icons.info_outline_rounded, maxLines: 3),
            ]),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff1565c0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : const Text('Save Changes', style: TextStyle(fontSize: 16, fontFamily: 'Rubik', fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(children: children),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      cursorColor: Colors.blue[700],
      mouseCursor: Colors.blue[700] != null ? SystemMouseCursors.text : MouseCursor.defer,
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(fontFamily: 'Rubik', color: Color(0xff1A1A2E)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontFamily: 'Rubik', color: Color(0xff64748B)),
        prefixIcon: Icon(icon, color: const Color(0xff1565c0), size: 20),
        filled: true,
        fillColor: const Color(0xffF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xffE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xffE2E8F0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xff1565c0), width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      ),
    );
  }
}
