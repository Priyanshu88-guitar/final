import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../widgets/common/empty_state.dart';

class SavedChargersScreen extends StatelessWidget {
  const SavedChargersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Saved Chargers'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.screenHorizontalPadding),
          child: EmptyState(
            icon: Icons.bookmark_border,
            title: 'No Saved Chargers Yet',
            message: 'Bookmark your favorite charging stations for quick access and live availability updates.',
          ),
        ),
      ),
    );
  }
}
