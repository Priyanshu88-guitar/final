import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../app/session.dart';
import '../../models/user_role.dart';
import '../../core/theme/app_colors.dart';
import '../../data/services/api_service.dart';
import '../../data/repositories/auth_repository.dart';

class AccountSwitchHelper {
  static void showSwitchAccountModal(BuildContext context) {
    final session = VolteraSession();
    final hasCustomer = session.hasRole(UserRole.customer);
    final hasProvider = session.hasRole(UserRole.provider);
    final isCustomerActive = session.activeRole == UserRole.customer;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Account & Role Switcher',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              const Text(
                'Manage your multi-role VOLTERA account seamlessly.',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),

              if (hasCustomer && hasProvider) ...[
                ListTile(
                  leading: Icon(Icons.person, color: isCustomerActive ? AppColors.primaryDarkGreen : AppColors.textMuted),
                  title: const Text('Customer Dashboard'),
                  subtitle: const Text('Find chargers, book & pay'),
                  trailing: isCustomerActive ? const Icon(Icons.check_circle, color: AppColors.primaryDarkGreen) : null,
                  onTap: () {
                    Navigator.pop(context);
                    session.switchToRole(UserRole.customer);
                    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.customerHome, (route) => false);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.business, color: !isCustomerActive ? AppColors.primaryDarkGreen : AppColors.textMuted),
                  title: const Text('Provider Dashboard'),
                  subtitle: const Text('Manage stations, chargers & earnings'),
                  trailing: !isCustomerActive ? const Icon(Icons.check_circle, color: AppColors.primaryDarkGreen) : null,
                  onTap: () {
                    Navigator.pop(context);
                    session.switchToRole(UserRole.provider);
                    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.providerHome, (route) => false);
                  },
                ),
              ] else if (hasCustomer && !hasProvider) ...[
                ListTile(
                  leading: const Icon(Icons.person, color: AppColors.primaryDarkGreen),
                  title: const Text('Customer Dashboard (Active)'),
                  trailing: const Icon(Icons.check_circle, color: AppColors.primaryDarkGreen),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.business, color: AppColors.primaryDarkGreen),
                  title: const Text('Register as Provider'),
                  subtitle: const Text('Unlock station management & earnings (Auto-approved)'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    Navigator.pop(context);
                    await _performRoleRegistration(context, UserRole.provider);
                  },
                ),
              ] else if (!hasCustomer && hasProvider) ...[
                ListTile(
                  leading: const Icon(Icons.business, color: AppColors.primaryDarkGreen),
                  title: const Text('Provider Dashboard (Active)'),
                  trailing: const Icon(Icons.check_circle, color: AppColors.primaryDarkGreen),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.person, color: AppColors.primaryDarkGreen),
                  title: const Text('Register as Customer'),
                  subtitle: const Text('Unlock EV discovery, booking & payments'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    Navigator.pop(context);
                    await _performRoleRegistration(context, UserRole.customer);
                  },
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  static Future<void> _performRoleRegistration(BuildContext context, UserRole targetRole) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final authRepo = AuthRepositoryImpl(apiService: ApiService());
      final updatedRoles = await authRepo.registerRole(targetRole);
      final session = VolteraSession();
      session.availableRoles = updatedRoles;
      session.switchToRole(targetRole);
      await authRepo.getCurrentSession();

      if (context.mounted) {
        Navigator.pop(context); // dismiss loading
        if (targetRole == UserRole.provider) {
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.providerHome, (route) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.customerHome, (route) => false);
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // dismiss loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Role registration failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
