import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Privacy Policy'),
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
              Text('VOLTERA Privacy Policy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              SizedBox(height: 12),
              Text(
                'VOLTERA values your privacy. This policy describes how we collect, use, and protect your personal information when you use our mobile application and charging services.',
                style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5),
              ),
              SizedBox(height: 16),
              Text('Data Collection & Location', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              SizedBox(height: 6),
              Text(
                'We collect your mobile number, name, and location data solely to locate nearby chargers, process bookings, and dispatch roadside emergency support.',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.4),
              ),
              SizedBox(height: 16),
              Text('Data Security & Payment Safety', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              SizedBox(height: 6),
              Text(
                'Payment credentials (cards, UPI) are handled securely through PCI-DSS compliant payment gateways. VOLTERA does not store full payment card details on device.',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
