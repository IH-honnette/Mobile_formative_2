import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class StartupAvatar extends StatelessWidget {
  final String name;
  final double size;

  const StartupAvatar({super.key, required this.name, this.size = 44});

  static const List<Color> _palette = [
    AppTheme.navy,
    AppTheme.coral,
    Color(0xFF2E8B57),
    Color(0xFF7C5CBF),
    Color(0xFFB97E10),
    Color(0xFF00838F),
  ];

  @override
  Widget build(BuildContext context) {
    final words = name.trim().split(RegExp(r'\s+'));
    final initials = words.isEmpty || words.first.isEmpty
        ? '?'
        : words.length == 1
            ? words.first[0].toUpperCase()
            : (words[0][0] + words[1][0]).toUpperCase();
    final color = _palette[name.hashCode.abs() % _palette.length];

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.36,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
