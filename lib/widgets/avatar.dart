import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../theme/palette.dart';

/// Decoding the same base64 string on every rebuild is wasteful, and the
/// profile rebuilds on every stats change. Keep the last few decodes around.
class _DecodeCache {
  static final _entries = <String, Uint8List>{};

  static Uint8List? get(String? encoded) {
    if (encoded == null || encoded.isEmpty) return null;
    final hit = _entries[encoded];
    if (hit != null) return hit;
    try {
      final bytes = base64Decode(encoded);
      if (_entries.length >= 4) _entries.remove(_entries.keys.first);
      _entries[encoded] = bytes;
      return bytes;
    } catch (_) {
      return null;
    }
  }
}

class Avatar extends StatelessWidget {
  final String? photoData;
  final String? photoUrl;
  final Uint8List? previewBytes;
  final double size;
  final VoidCallback? onTap;

  const Avatar({
    super.key,
    this.photoData,
    this.photoUrl,
    this.previewBytes,
    this.size = 66,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final stored = _DecodeCache.get(photoData);
    final bytes = previewBytes ?? stored;

    Widget content;
    if (bytes != null) {
      content = Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true);
    } else if (photoUrl != null && photoUrl!.isNotEmpty) {
      content = Image.network(
        photoUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    } else {
      content = _placeholder();
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Palette.fill,
          border: Border.all(color: Palette.line),
        ),
        child: content,
      ),
    );
  }

  Widget _placeholder() => Center(
        child: Icon(
          Icons.person_outline,
          size: size * 0.42,
          color: Palette.inkFaint,
        ),
      );
}
