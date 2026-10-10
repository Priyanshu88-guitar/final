import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../widgets/common/voltera_button.dart';
import '../../widgets/common/voltera_text_field.dart';

class BankPayoutScreen extends StatefulWidget {
  const BankPayoutScreen({super.key});

  @override
  State<BankPayoutScreen> createState() => _BankPayoutScreenState();
}

class _BankPayoutScreenState extends State<BankPayoutScreen> {
  final _holderController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscController = TextEditingController();
  String _payoutMethod = 'UPI / Bank Transfer';

  @override
  void dispose() {
    _holderController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Bank & Payouts'),
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
                'Payout Account Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              const Text(
                'Manage your bank details to receive automatic weekly payouts.',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
              const SizedBox(height: 24),

              const Text('Account Holder Name', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              VolteraTextField(
                controller: _holderController,
                label: 'Account Holder Name',
                hint: 'Enter account holder name',
              ),
              const SizedBox(height: 16),

              const Text('Bank Account Number', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              VolteraTextField(
                controller: _accountNumberController,
                label: 'Bank Account Number',
                hint: 'Enter bank account number',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              const Text('IFSC Code', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              VolteraTextField(
                controller: _ifscController,
                label: 'IFSC Code',
                hint: 'Enter 11-character IFSC code',
              ),
              const SizedBox(height: 16),

              const Text('Preferred Payout Method', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _payoutMethod,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                ),
                items: ['UPI / Bank Transfer', 'Direct NEFT/IMPS', 'Weekly Auto-Payout'].map((m) {
                  return DropdownMenuItem(value: m, child: Text(m));
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _payoutMethod = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 36),

              VolteraButton(
                text: 'Save Bank Details',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bank & payout details saved.')),
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
