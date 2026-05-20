// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

class EmoticonFace extends StatefulWidget {
  final String emoticonFace;
  final String mood;
  final bool isSelected;
  final void Function(String mood)? onSelected;

  const EmoticonFace({
    super.key,
    required this.emoticonFace,
    required this.mood,
    this.isSelected = false,
    this.onSelected,
  });

  @override
  _EmoticonFaceState createState() => _EmoticonFaceState();
}

class _EmoticonFaceState extends State<EmoticonFace> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(milliseconds: 800));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _onTap() {
    widget.onSelected?.call(widget.mood);
    if (widget.mood == 'Happy') _confettiController.play();
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.isSelected;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        GestureDetector(
          onTap: _onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? const Color(0xff1565c0) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? const Color(0xff1565c0) : const Color(0xffE2E8F0),
                width: 1.5,
              ),
              boxShadow: selected
                  ? [const BoxShadow(color: Color(0x331565c0), blurRadius: 8, offset: Offset(0, 3))]
                  : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.emoticonFace, style: const TextStyle(fontSize: 26)),
                const SizedBox(height: 4),
                Text(
                  widget.mood,
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: selected ? Colors.white : const Color(0xff64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: -10,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: pi / 2,
            maxBlastForce: 5,
            minBlastForce: 2,
            emissionFrequency: 0.05,
            numberOfParticles: 15,
            gravity: 0.2,
            shouldLoop: false,
            colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
          ),
        ),
      ],
    );
  }
}
