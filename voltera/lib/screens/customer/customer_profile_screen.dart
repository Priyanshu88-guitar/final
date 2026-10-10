import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../app/session.dart';
import '../../models/user_role.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../widgets/common/account_switch_helper.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = VolteraSession();
    final userName = session.fullName ?? 'Customer Name';
    final hasProviderRole = session.hasRole(UserRole.provider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Profile'),
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
              // Profile Header
              Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.lightGreen, AppColors.primaryDarkGreen],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.person, color: AppColors.white, size: 36),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'View Profile',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Multi-Role Switcher / Registration Card (Shared AccountSwitchHelper)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryDarkGreen.withValues(alpha: 0.3), width: 1.5),
                ),
                child: ListTile(
                  leading: const Icon(Icons.swap_horiz, color: AppColors.primaryDarkGreen, size: 28),
                  title: Text(
                    hasProviderRole ? 'Switch to Provider Mode' : 'Register as Provider',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDarkGreen),
                  ),
                  subtitle: Text(
                    hasProviderRole
                        ? 'Manage your chargers, requests & earnings'
                        : 'Register as Provider (Automatically Approved for Demo)',
                  ),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.primaryDarkGreen),
                  onTap: () => AccountSwitchHelper.showSwitchAccountModal(context),
                ),
              ),

              // Wallet Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2EFC5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Wallet',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '₹--',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDarkGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Menu Items List
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
                child: Column(
                  children: [
                    _ProfileMenuItem(
                      icon: Icons.flash_on,
                      iconColor: Colors.amber,
                      title: 'Charging History',
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.customerChargingHistory);
                      },
                    ),
                    const Divider(height: 1, indent: 56),
                    _ProfileMenuItem(
                      icon: Icons.payment,
                      iconColor: AppColors.information,
                      title: 'Payments',
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.customerPayment);
                      },
                    ),
                    const Divider(height: 1, indent: 56),
                    _ProfileMenuItem(
                      icon: Icons.bookmark_border,
                      iconColor: AppColors.primaryDarkGreen,
                      title: 'Saved Chargers',
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.customerSavedChargers);
                      },
                    ),
                    const Divider(height: 1, indent: 56),
                    _ProfileMenuItem(
                      icon: Icons.notifications_none,
                      iconColor: Colors.purple,
                      title: 'Notification',
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.customerNotifications);
                      },
                    ),
                    const Divider(height: 1, indent: 56),
                    _ProfileMenuItem(
                      icon: Icons.settings_outlined,
                      iconColor: Colors.grey,
                      title: 'Settings',
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.customerSettings);
                      },
                    ),
                    const Divider(height: 1, indent: 56),
                    _ProfileMenuItem(
                      icon: Icons.help_outline,
                      iconColor: AppColors.warning,
                      title: 'Help and Support',
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.customerHelpSupport);
                      },
                    ),
                    const Divider(height: 1, indent: 56),
                    _ProfileMenuItem(
                      icon: Icons.logout,
                      iconColor: AppColors.error,
                      title: 'Logout',
                      titleColor: AppColors.error,
                      onTap: () {
                        VolteraSession().logout();
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.welcome,
                          (route) => false,
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

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Color? titleColor;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.titleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: titleColor ?? AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
      onTap: onTap,
    );
  }
}
