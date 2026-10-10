import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../widgets/common/voltera_button.dart';

class CustomerDetailsScreen extends StatelessWidget {
  const CustomerDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final chargerName = args?['chargerName'] as String? ?? 'GreenCharge Hub';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(chargerName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner / Map placeholder image matching Figma
              Container(
                width: double.infinity,
                height: 220,
                color: AppColors.primaryDarkGreen,
                child: Center(
                  child: Icon(Icons.ev_station, size: 80, color: AppColors.white.withValues(alpha: 0.8)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.screenHorizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chargerName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '★ 4.8 (128) · 1.2 km',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '₹12/kWh',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDarkGreen,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Details Rows
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border, width: 0.5),
                      ),
                      child: Column(
                        children: [
                          _DetailRow(label: 'Connector', value: 'CCS2 · Fast Charger'),
                          const Divider(height: 24),
                          _DetailRow(label: 'Availability', value: '5 Available', valueColor: AppColors.success),
                          const Divider(height: 24),
                          _DetailRow(label: 'Hours', value: 'Open · Closes 10:00 PM'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),

                    VolteraButton(
                      text: 'Start Navigation',
                      onPressed: () {
                        // Launch real Google Maps live navigation map with exact test coordinates
                        Navigator.pushNamed(
                          context,
                          AppRoutes.chargerMap,
                          arguments: {
                            'destinationName': chargerName,
                            'destinationLat': 22.464432, // Exact Provider / Charger test coordinate
                            'destinationLng': 70.043333,
                          },
                        );
                      },
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
