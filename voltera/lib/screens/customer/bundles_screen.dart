import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/demo/demo_config.dart';
import '../../core/demo/demo_data.dart';
import '../../widgets/common/voltera_button.dart';

class BundlesScreen extends StatelessWidget {
  const BundlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bundles = DemoConfig.demoMode ? DemoData.demoBundles : [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Charging Bundles'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontalPadding),
          children: [
            const Text(
              'Available Packages',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              'Save more on daily rides with custom EV charging bundles.',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 20),
            ...bundles.map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _BundleCard(
                    title: b['name'] as String? ?? '',
                    price: '${b['price']} / ${b['validity']}',
                    benefits: '${b['energy']} Energy + ${b['savings']}',
                    validity: 'Valid for ${b['validity']}',
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _BundleCard extends StatelessWidget {
  final String title;
  final String price;
  final String benefits;
  final String validity;

  const _BundleCard({
    required this.title,
    required this.price,
    required this.benefits,
    required this.validity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryDarkGreen.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              Text(
                price,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryDarkGreen),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(benefits, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(validity, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 16),
          VolteraButton(
            text: 'Subscribe Package',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bundle subscribed successfully!')),
              );
            },
          ),
        ],
      ),
    );
  }
}
