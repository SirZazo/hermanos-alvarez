import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppDecorations {
  static BoxDecoration card({
    double radius = 20,
    bool shadow = true,
  }) {
    return BoxDecoration(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: AppColors.border,
      ),
      boxShadow: shadow
          ? const [
              BoxShadow(
                color: AppColors.shadowSoft,
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ]
          : null,
    );
  }

  static BoxDecoration softPanel({
    double radius = 20,
  }) {
    return BoxDecoration(
      color: AppColors.sectionBackground,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: AppColors.border,
      ),
    );
  }
}
