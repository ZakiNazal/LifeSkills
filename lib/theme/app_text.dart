import 'package:flutter/material.dart';
import 'palette.dart';

class AppText {
  static const _family = 'Rubik';

  // Large numerals and the greeting. Light weight on purpose, it only works big.
  static const display = TextStyle(
    fontFamily: _family,
    fontSize: 38,
    height: 1.0,
    fontWeight: FontWeight.w300,
    letterSpacing: -1.8,
    color: Palette.ink,
  );

  static const numeral = TextStyle(
    fontFamily: _family,
    fontSize: 28,
    height: 1.0,
    fontWeight: FontWeight.w300,
    letterSpacing: -1.0,
    color: Palette.ink,
  );

  static const h1 = TextStyle(
    fontFamily: _family,
    fontSize: 26,
    height: 1.15,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.7,
    color: Palette.ink,
  );

  static const h2 = TextStyle(
    fontFamily: _family,
    fontSize: 19,
    height: 1.25,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.35,
    color: Palette.ink,
  );

  static const h3 = TextStyle(
    fontFamily: _family,
    fontSize: 15.5,
    height: 1.3,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.1,
    color: Palette.ink,
  );

  static const body = TextStyle(
    fontFamily: _family,
    fontSize: 15,
    height: 1.55,
    fontWeight: FontWeight.w400,
    color: Palette.inkSoft,
  );

  static const label = TextStyle(
    fontFamily: _family,
    fontSize: 14,
    height: 1.3,
    fontWeight: FontWeight.w500,
    color: Palette.ink,
  );

  static const meta = TextStyle(
    fontFamily: _family,
    fontSize: 13,
    height: 1.35,
    fontWeight: FontWeight.w400,
    color: Palette.inkFaint,
  );

  static const overline = TextStyle(
    fontFamily: _family,
    fontSize: 11,
    height: 1.2,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.3,
    color: Palette.inkFaint,
  );

  static const button = TextStyle(
    fontFamily: _family,
    fontSize: 15,
    height: 1.2,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.1,
  );
}
