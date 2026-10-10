import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../widgets/common/voltera_button.dart';
import '../../widgets/common/voltera_text_field.dart';

class ProviderWithdrawScreen extends StatefulWidget {
  const ProviderWithdrawScreen({super.key});

  @override
  State<ProviderWithdrawScreen> createState() => _ProviderWithdrawScreenState();
}

class _ProviderWithdrawScreenState extends State<ProviderWithdrawScreen> {
  final _amountController = TextEditingController(text: '₹2,000');
  final _upiController = TextEditingController(text: 'provider@upi');

  @override
  void dispose() {
    _amountController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Withdraw Funds'),
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
                'Available Balance',
                style: TextStyle(fontSize: 14, color: AppColors.textMuted),
              ),
              const SizedBox(height: 6),
              const Text(
                '₹2,450.00',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDarkGreen,
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'Withdraw Amount',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              VolteraTextField(
                controller: _amountController,
                label: 'Withdraw Amount',
                hint: 'Enter amount to withdraw',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              const Text(
                'UPI ID',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              VolteraTextField(
                controller: _upiController,
                label: 'UPI ID',
                hint: 'Enter your UPI ID',
              ),
              const SizedBox(height: 48),

              VolteraButton(
                text: 'Withdraw Now',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Withdrawal request submitted successfully.')),
                  );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
