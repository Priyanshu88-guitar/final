import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../widgets/common/empty_state.dart';

class ChargingHistoryScreen extends StatelessWidget {
  const ChargingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Charging History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.screenHorizontalPadding),
          child: EmptyState(
            icon: Icons.history,
            title: 'No Charging History Yet',
            message: 'Your completed charging sessions, energy consumed, and payment summaries will appear here.',
          ),
        ),
      ),
    );
  }
}
