import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

class VolteraLogoBadge extends StatelessWidget {
  final double size;

  const VolteraLogoBadge({super.key, this.size = 140.0});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF163821), Color(0xFF0D2114)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.secondaryGreen.withValues(alpha: 0.4), width: 3),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondaryGreen.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Image.asset(
          'assets/images/logo.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback badge if logo.png is not yet added in assets/images/
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryGreen.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.electric_bolt_rounded,
                      color: Color(0xFFE89B38),
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppConstants.appName,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: size * 0.12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'EV CHARGING',
                    style: TextStyle(
                      color: AppColors.lightGreen,
                      fontSize: size * 0.05,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
