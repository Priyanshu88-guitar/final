import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../app/session.dart';
import '../../models/user_role.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../widgets/common/status_badge.dart';

class ProviderBusinessScreen extends StatelessWidget {
  const ProviderBusinessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = VolteraSession();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Business Profile'),
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
              // Business Profile Header (Tapping edits business profile)
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.providerEditBusinessProfile);
                },
                child: Row(
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
                        child: Icon(Icons.business, color: AppColors.white, size: 36),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.businessName ?? 'GreenCharge Hub',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Edit Business Profile →',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryDarkGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Multi-Role Switcher Card
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryDarkGreen.withValues(alpha: 0.3), width: 1.5),
                ),
                child: ListTile(
                  leading: const Icon(Icons.swap_horiz, color: AppColors.primaryDarkGreen, size: 28),
                  title: const Text(
                    'Switch to Customer Mode',
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDarkGreen),
                  ),
                  subtitle: const Text('Access EV charging and booking services'),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.primaryDarkGreen),
                  onTap: () {
                    session.enableDualRole();
                    session.switchToRole(UserRole.customer);
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.customerHome,
                      (route) => false,
                    );
                  },
                ),
              ),

              // Menu List Container matching Figma
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
                child: Column(
                  children: [
                    _BusinessMenuItem(
                      title: 'Edit Business Profile',
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.providerEditBusinessProfile);
                      },
                    ),
                    const Divider(height: 1, indent: 16),
                    _BusinessMenuItem(
                      title: 'Bank & Payouts',
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.providerBankPayout);
                      },
                    ),
                    const Divider(height: 1, indent: 16),
                    ListTile(
                      title: const Text(
                        'Verification',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                      trailing: const StatusBadge(
                        label: 'Verified',
                        backgroundColor: Color(0xFFE2EFC5),
                        textColor: AppColors.primaryDarkGreen,
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.providerDocuments);
                      },
                    ),
                    const Divider(height: 1, indent: 16),
                    _BusinessMenuItem(
                      title: 'Documents',
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.providerDocuments);
                      },
                    ),
                    const Divider(height: 1, indent: 16),
                    _BusinessMenuItem(
                      title: 'Settings',
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.providerSettings);
                      },
                    ),
                    const Divider(height: 1, indent: 16),
                    _BusinessMenuItem(
                      title: 'Help and Support',
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.providerHelpSupport);
                      },
                    ),
                    const Divider(height: 1, indent: 16),
                    _BusinessMenuItem(
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

class _BusinessMenuItem extends StatelessWidget {
  final String title;
  final Color? titleColor;
  final VoidCallback onTap;

  const _BusinessMenuItem({required this.title, this.titleColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
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
