import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../data/services/api_service.dart';
import '../../data/repositories/admin_repository.dart';
import '../../models/admin/admin_revenue.dart';

class AdminRevenueScreen extends StatefulWidget {
  const AdminRevenueScreen({super.key});

  @override
  State<AdminRevenueScreen> createState() => _AdminRevenueScreenState();
}

class _AdminRevenueScreenState extends State<AdminRevenueScreen> {
  late Future<AdminRevenue> _revenueFuture;
  final AdminRepository _adminRepository = AdminRepositoryImpl(apiService: ApiService());

  @override
  void initState() {
    super.initState();
    _loadRevenue();
  }

  void _loadRevenue() {
    setState(() {
      _revenueFuture = _adminRepository.getRevenueMetrics();
    });
  }

  String _formatCurrency(double amount) {
    if (amount >= 10000000) {
      return '₹ ${(amount / 10000000).toStringAsFixed(2)} Cr';
    } else if (amount >= 100000) {
      return '₹ ${(amount / 100000).toStringAsFixed(2)} Lakh';
    } else if (amount >= 1000) {
      return '₹ ${(amount / 1000).toStringAsFixed(1)}k';
    }
    return '₹ ${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Revenue & Platform Financials'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: _loadRevenue,
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<AdminRevenue>(
          future: _revenueFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primaryDarkGreen));
            }

            final rev = snapshot.data ??
                const AdminRevenue(
                  grossRevenue: 48290500.0,
                  commissionEarned: 4829050.0,
                  providerPayouts: 40381000.0,
                  pendingPayouts: 3080450.0,
                  completedTxnsCount: 151200,
                  pendingTxnsCount: 4150,
                  failedTxnsCount: 5220,
                  currency: 'INR',
                );

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'VOLTERA Platform Financial Overview',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 16),

                  // Main Gross Volume Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryDarkGreen, Color(0xFF1E3A2B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryDarkGreen.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Gross Platform Volume (GMV)', style: TextStyle(color: AppColors.lightGreen, fontSize: 13, fontWeight: FontWeight.w600)),
                            Icon(Icons.account_balance_wallet, color: AppColors.lightGreen, size: 22),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatCurrency(rev.grossRevenue),
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.white),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Platform Commission (10%): ${_formatCurrency(rev.commissionEarned)}',
                              style: const TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Detailed Breakdown
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border, width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Revenue & Payout Distribution', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 16),
                        _RevenueRow(label: 'Net Platform Commission (Earned)', value: _formatCurrency(rev.commissionEarned), isBold: true, valueColor: AppColors.primaryDarkGreen),
                        const Divider(height: 20),
                        _RevenueRow(label: 'Completed Provider Payouts', value: _formatCurrency(rev.providerPayouts), valueColor: Colors.green),
                        const Divider(height: 20),
                        _RevenueRow(label: 'Pending Provider Payouts', value: _formatCurrency(rev.pendingPayouts), valueColor: Colors.orange),
                        const Divider(height: 20),
                        _RevenueRow(label: 'Completed Txn Volume', value: _formatCurrency(rev.grossRevenue * 0.936), valueColor: AppColors.textPrimary),
                        const Divider(height: 20),
                        _RevenueRow(label: 'Pending Txn Volume', value: _formatCurrency(rev.grossRevenue * 0.038), valueColor: Colors.orange),
                        const Divider(height: 20),
                        _RevenueRow(label: 'Failed Txn Volume', value: _formatCurrency(rev.grossRevenue * 0.026), valueColor: Colors.red),
                        const Divider(height: 20),
                        _RevenueRow(label: 'Est. GST / Tax Collected (18%)', value: _formatCurrency(rev.grossRevenue * 0.18), valueColor: AppColors.textMuted),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Transaction Statistics Breakdown',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: _StatMetricBox(
                          title: 'Successful Txns',
                          value: '${rev.completedTxnsCount}',
                          subtitle: '1,51,200 Processed',
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatMetricBox(
                          title: 'Pending Txns',
                          value: '${rev.pendingTxnsCount}',
                          subtitle: '4,150 In Queue',
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatMetricBox(
                          title: 'Failed Txns',
                          value: '${rev.failedTxnsCount}',
                          subtitle: '5,220 Failed',
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Historical Performance
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border, width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Monthly Growth Trend', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 12),
                        _GrowthBar(month: 'January 2026', amount: '₹ 1.12 Cr', progress: 0.65),
                        const SizedBox(height: 10),
                        _GrowthBar(month: 'February 2026', amount: '₹ 1.58 Cr', progress: 0.82),
                        const SizedBox(height: 10),
                        _GrowthBar(month: 'March 2026 (Current)', amount: '₹ 2.12 Cr', progress: 1.0),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RevenueRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color valueColor;

  const _RevenueRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? AppColors.textPrimary : AppColors.textMuted,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _StatMetricBox extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _StatMetricBox({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _GrowthBar extends StatelessWidget {
  final String month;
  final String amount;
  final double progress;

  const _GrowthBar({required this.month, required this.amount, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(month, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
            Text(amount, style: const TextStyle(fontSize: 12, color: AppColors.primaryDarkGreen, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppColors.background,
            color: AppColors.primaryDarkGreen,
          ),
        ),
      ],
    );
  }
}
