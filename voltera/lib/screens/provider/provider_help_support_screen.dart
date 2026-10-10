import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../widgets/common/voltera_button.dart';

class ProviderHelpSupportScreen extends StatelessWidget {
  const ProviderHelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Provider Help & Support'),
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
              'Provider Frequently Asked Questions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Column(
                children: const [
                  ExpansionTile(
                    title: Text('How do weekly payouts work?'),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Payouts are automatically processed every Monday into your verified bank account or UPI ID.',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 1),
                  ExpansionTile(
                    title: Text('How do I list a new charger?'),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Go to My Chargers -> + Add New Charger, enter the connector type, location, and tariff rates. Admin verification takes 24 hours.',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 1),
                  ExpansionTile(
                    title: Text('What if a customer damages equipment?'),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Immediately tap Report a Problem or contact VOLTERA Emergency Provider Support. Photo evidence can be submitted via Documents.',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            const Text(
              'Need Support?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            VolteraButton(
              text: 'Contact Provider Support',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Support ticket opened. A VOLTERA manager will contact you.')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
