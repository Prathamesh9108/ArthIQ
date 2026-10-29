import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class CategoryIconBadge extends StatelessWidget {
  final String category;
  final double size;
  final double iconSize;

  const CategoryIconBadge({
    super.key,
    required this.category,
    this.size = 46,
    this.iconSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppConstants.categoryColorMap[category] ?? const Color(0xFF65E6B4);
    final icon = AppConstants.categoryIconMap[category] ?? Icons.category_rounded;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withOpacity(0.35),
          width: 1.2,
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          color: color,
          size: iconSize,
        ),
      ),
    );
  }
}
