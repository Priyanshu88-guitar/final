import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../widgets/common/voltera_button.dart';

class CustomerPaymentScreen extends StatelessWidget {
  const CustomerPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Payment'),
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
                'Total Amount',
                style: TextStyle(fontSize: 14, color: AppColors.textMuted),
              ),
              const SizedBox(height: 6),
              const Text(
                '₹120.00',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDarkGreen,
                ),
              ),
              const SizedBox(height: 24),

              // Itemized Summary Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _PaymentRow(label: 'Energy (10 kWh)', amount: '₹120.00'),
                    const Divider(height: 24),
                    _PaymentRow(label: 'Service Fee', amount: '₹0.00'),
                    const Divider(height: 24),
                    _PaymentRow(label: 'Total', amount: '₹120.00', isBold: true),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Payment Method',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),

              // Payment method tabs representation matching Figma
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  _PaymentTab(label: 'UPI', isSelected: true),
                  _PaymentTab(label: 'Wallet', isSelected: false),
                  _PaymentTab(label: 'Card', isSelected: false),
                ],
              ),
              const SizedBox(height: 48),

              VolteraButton(
                text: 'Pay Now',
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.customerReview);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final String label;
  final String amount;
  final bool isBold;

  const _PaymentRow({required this.label, required this.amount, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isBold ? AppColors.primaryDarkGreen : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _PaymentTab extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _PaymentTab({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isSelected ? AppColors.primaryDarkGreen : AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 3,
          width: 40,
          color: isSelected ? AppColors.primaryDarkGreen : Colors.transparent,
        ),
      ],
    );
  }
}
