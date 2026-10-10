import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../app/session.dart';
import '../../models/user_role.dart';
import '../../data/services/provider_state_manager.dart';
import '../../widgets/common/account_switch_helper.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';

class ProviderHomeScreen extends StatelessWidget {
  const ProviderHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = VolteraSession();
    final providerName = session.fullName ?? 'Provider';
    final hasCustomerRole = session.hasRole(UserRole.customer);

    return ListenableBuilder(
      listenable: ProviderStateManager(),
      builder: (context, _) {
        final providerState = ProviderStateManager();
        final pendingCount = providerState.pendingRequests.length;

        return Scaffold(
          backgroundColor: AppColors.primaryDarkGreen,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.business, color: AppColors.white),
                onPressed: () => Navigator.pushNamed(context, AppRoutes.providerBusiness),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, $providerName',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.lightGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'You are online',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.lightGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Switch / Register Customer Card (Shared AccountSwitchHelper)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.lightGreen.withValues(alpha: 0.3), width: 1.5),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.swap_horiz, color: AppColors.lightGreen, size: 28),
                      title: Text(
                        hasCustomerRole ? 'Switch to Customer Mode' : 'Register as Customer',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.white),
                      ),
                      subtitle: Text(
                        hasCustomerRole ? 'Switch to customer dashboard' : 'Register as Customer on this account',
                        style: const TextStyle(color: AppColors.lightGreen),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: AppColors.lightGreen),
                      onTap: () => AccountSwitchHelper.showSwitchAccountModal(context),
                    ),
                  ),

                  // Today's Earnings Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Today\'s Earnings',
                          style: TextStyle(fontSize: 14, color: AppColors.lightGreen),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '₹--',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Backend data pending',
                          style: TextStyle(fontSize: 12, color: AppColors.lightGreen),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Metrics Row
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('--', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.white)),
                              SizedBox(height: 4),
                              Text('Total Sessions', style: TextStyle(fontSize: 12, color: AppColors.lightGreen)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('--', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.white)),
                              SizedBox(height: 4),
                              Text('Total kWh', style: TextStyle(fontSize: 12, color: AppColors.lightGreen)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  Text(
                    pendingCount > 0
                        ? 'Incoming Requests · $pendingCount New'
                        : 'Incoming Requests · No New Requests',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white),
                  ),
                  const SizedBox(height: 16),

                  // View Requests Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.providerRequests);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE89B38),
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'View Requests',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Navigation Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.5,
                    children: [
                      _ProviderNavCard(
                        title: 'Active Session',
                        icon: Icons.bolt,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.providerSession),
                      ),
                      _ProviderNavCard(
                        title: 'Earnings',
                        icon: Icons.account_balance_wallet,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.providerEarnings),
                      ),
                      _ProviderNavCard(
                        title: 'Performance',
                        icon: Icons.insights,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.providerPerformance),
                      ),
                      _ProviderNavCard(
                        title: 'My Chargers',
                        icon: Icons.ev_station,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.providerChargers),
                      ),
                      _ProviderNavCard(
                        title: 'Availability',
                        icon: Icons.schedule,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.providerAvailability),
                      ),
                      _ProviderNavCard(
                        title: 'Withdraw',
                        icon: Icons.payments,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.providerWithdraw),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Center(
                    child: TextButton(
                      onPressed: () {
                        VolteraSession().logout();
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.welcome,
                          (route) => false,
                        );
                      },
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProviderNavCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ProviderNavCard({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.lightGreen, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
