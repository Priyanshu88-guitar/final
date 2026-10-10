import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../app/session.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';

class ProviderSettingsScreen extends StatefulWidget {
  const ProviderSettingsScreen({super.key});

  @override
  State<ProviderSettingsScreen> createState() => _ProviderSettingsScreenState();
}

class _ProviderSettingsScreenState extends State<ProviderSettingsScreen> {
  bool _notifications = true;
  bool _autoAcceptRequests = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Provider Settings'),
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
              'ACCOUNT & BUSINESS',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Edit Profile'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.customerEditProfile);
                    },
                  ),
                  const Divider(height: 1, indent: 16),
                  ListTile(
                    title: const Text('Edit Business Profile'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.providerBusiness);
                    },
                  ),
                  const Divider(height: 1, indent: 16),
                  ListTile(
                    title: const Text('Change Password'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.customerChangePassword);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'CHARGING PREFERENCES',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Push Notifications'),
                    value: _notifications,
                    activeThumbColor: AppColors.primaryDarkGreen,
                    onChanged: (val) {
                      setState(() {
                        _notifications = val;
                      });
                    },
                  ),
                  const Divider(height: 1, indent: 16),
                  SwitchListTile(
                    title: const Text('Auto-Accept Booking Requests'),
                    value: _autoAcceptRequests,
                    activeThumbColor: AppColors.primaryDarkGreen,
                    onChanged: (val) {
                      setState(() {
                        _autoAcceptRequests = val;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'SUPPORT & LEGAL',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Help & Support'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.providerHelpSupport);
                    },
                  ),
                  const Divider(height: 1, indent: 16),
                  ListTile(
                    title: const Text('Terms & Provider Agreement'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.customerTerms);
                    },
                  ),
                  const Divider(height: 1, indent: 16),
                  ListTile(
                    title: const Text('Privacy Policy'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.customerPrivacy);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: ListTile(
                title: const Text(
                  'Logout',
                  style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                ),
                leading: const Icon(Icons.logout, color: AppColors.error),
                onTap: () {
                  VolteraSession().logout();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.welcome,
                    (route) => false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
