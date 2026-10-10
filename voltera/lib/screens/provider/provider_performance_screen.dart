import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';

class ProviderPerformanceScreen extends StatelessWidget {
  const ProviderPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Performance'),
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
            children: [
              const Text(
                'Performance Overview',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),

              // Bar Chart Representation matching Figma screenshot
              Container(
                height: 180,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _BarItem(heightFactor: 0.5, label: 'M'),
                    _BarItem(heightFactor: 0.7, label: 'T'),
                    _BarItem(heightFactor: 0.35, label: 'W'),
                    _BarItem(heightFactor: 0.85, label: 'T'),
                    _BarItem(heightFactor: 0.6, label: 'F'),
                    _BarItem(heightFactor: 0.95, label: 'S'),
                    _BarItem(heightFactor: 0.75, label: 'S'),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'Top Performers',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('GreenCharge Hub', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text('₹5,240', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryDarkGreen)),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Volt Point', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text('₹3,320', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryDarkGreen)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarItem extends StatelessWidget {
  final double heightFactor;
  final String label;

  const _BarItem({required this.heightFactor, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 22,
          height: 120 * heightFactor,
          decoration: BoxDecoration(
            color: AppColors.primaryDarkGreen,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
