import 'package:flutter/material.dart';

class Palette {
  static const paper = Color(0xFFFAF9F7);
  static const surface = Color(0xFFFFFFFF);

  static const ink = Color(0xFF1A1917);
  static const inkSoft = Color(0xFF57564F);
  static const inkFaint = Color(0xFF94918A);

  static const line = Color(0xFFE5E2DA);
  static const lineSoft = Color(0xFFF0EEE8);
  static const fill = Color(0xFFF3F1EB);

  static const accent = Color(0xFFC2410C);
  static const danger = Color(0xFFB3261E);
}

/// A colour used three ways: a soft [tint] for card fills, a [deep] shade for
/// text and icons sitting on that tint, and a [solid] for full bleed surfaces
/// that carry white text.
class ColorFamily {
  final String name;
  final Color tint;
  final Color deep;
  final Color solid;

  const ColorFamily({
    required this.name,
    required this.tint,
    required this.deep,
    required this.solid,
  });

  Color get muted => Color.alphaBlend(deep.withValues(alpha: 0.72), tint);
}

class Families {
  static const ember = ColorFamily(
    name: 'ember',
    tint: Color(0xFFFBE0D3),
    deep: Color(0xFF9E3813),
    solid: Color(0xFFC2410C),
  );

  static const ochre = ColorFamily(
    name: 'ochre',
    tint: Color(0xFFF9EACA),
    deep: Color(0xFF7A5510),
    solid: Color(0xFF9A6B0C),
  );

  static const moss = ColorFamily(
    name: 'moss',
    tint: Color(0xFFDDE8D6),
    deep: Color(0xFF35512B),
    solid: Color(0xFF41663A),
  );

  static const teal = ColorFamily(
    name: 'teal',
    tint: Color(0xFFD2E6E4),
    deep: Color(0xFF14504C),
    solid: Color(0xFF21615C),
  );

  static const indigo = ColorFamily(
    name: 'indigo',
    tint: Color(0xFFDEE1F3),
    deep: Color(0xFF343A75),
    solid: Color(0xFF434CA0),
  );

  static const plum = ColorFamily(
    name: 'plum',
    tint: Color(0xFFEBDCEC),
    deep: Color(0xFF62306B),
    solid: Color(0xFF7B4285),
  );

  static const berry = ColorFamily(
    name: 'berry',
    tint: Color(0xFFF7D9DF),
    deep: Color(0xFF8C2F44),
    solid: Color(0xFFA93A50),
  );

  static const all = [ember, ochre, moss, teal, indigo, plum, berry];
}
