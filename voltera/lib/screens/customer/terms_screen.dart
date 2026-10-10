import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Terms & Conditions'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('VOLTERA Platform Terms of Service', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              SizedBox(height: 12),
              Text(
                'Welcome to VOLTERA. By accessing or using our EV charging application, station finder, booking, or payment services, you agree to be bound by these Terms and Conditions.',
                style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5),
              ),
              SizedBox(height: 16),
              Text('1. EV Charging & Station Usage', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              SizedBox(height: 6),
              Text(
                'Users are responsible for ensuring their vehicle compatibility (CCS2, GB/T, etc.) and following safety guidelines at charging stations.',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.4),
              ),
              SizedBox(height: 16),
              Text('2. Payments & Wallet Terms', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              SizedBox(height: 6),
              Text(
                'Payments are calculated based on electricity consumed (kWh) or charging duration. Wallet top-ups are non-refundable unless required by applicable consumer law.',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
