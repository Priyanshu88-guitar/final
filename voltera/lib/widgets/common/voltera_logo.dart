import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

class VolteraLogo extends StatelessWidget {
  final bool isDark;
  final double size;
  final bool showText;

  const VolteraLogo({
    super.key,
    this.isDark = true,
    this.size = 32.0,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    // Ready for official logo asset integration.
    // Preserves aspect ratio and structure.
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.bolt,
          color: isDark ? AppColors.primaryDarkGreen : AppColors.cream,
          size: size * 1.2,
        ),
        if (showText) ...[
          const SizedBox(width: 8),
          Text(
            AppConstants.appName,
            style: TextStyle(
              fontSize: size,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: isDark ? AppColors.textPrimary : AppColors.white,
            ),
          ),
        ],
      ],
    );
  }
}
