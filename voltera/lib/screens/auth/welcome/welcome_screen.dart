import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../widgets/common/voltera_logo_badge.dart';
import '../../../widgets/common/voltera_button.dart';
import '../../../widgets/common/voltera_outline_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontalPadding),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const VolteraLogoBadge(size: 140),
                const SizedBox(height: 32),
                const Text(
                  'Welcome to',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'VOLTERA',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDarkGreen,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Smart Charging\nFor Smart Riders',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 56),
                VolteraButton(
                  text: 'Login',
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.login);
                  },
                ),
                const SizedBox(height: 16),
                VolteraOutlineButton(
                  text: 'Sign Up',
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.signup);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
