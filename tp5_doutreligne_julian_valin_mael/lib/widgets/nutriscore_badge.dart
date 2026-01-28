import 'package:flutter/material.dart';

class NutriscoreBadge extends StatelessWidget {
  final String grade;
  final double fontSize;

  const NutriscoreBadge({super.key, required this.grade, this.fontSize = 11});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getNutriscoreColor(grade),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        fontSize > 12
            ? grade.toUpperCase()
            : 'Nutri-Score ${grade.toUpperCase() == "UNKNOWN" ? "?" : grade.toUpperCase()}',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      ),
    );
  }

  Color _getNutriscoreColor(String grade) {
    switch (grade.toLowerCase()) {
      case 'a':
        return const Color(0xFF038141);
      case 'b':
        return const Color(0xFF85BB2F);
      case 'c':
        return const Color(0xFFFECB02);
      case 'd':
        return const Color(0xFFEE8100);
      case 'e':
        return const Color(0xFFE63E11);
      default:
        return Colors.grey;
    }
  }
}
