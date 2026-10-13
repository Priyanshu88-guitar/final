import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../app/session.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../data/services/api_service.dart';
import '../../data/repositories/admin_repository.dart';
import '../../models/admin/admin_statistics.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Future<AdminStatistics> _statsFuture;
  final AdminRepository _adminRepository = AdminRepositoryImpl(apiService: ApiService());

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    setState(() {
      _statsFuture = _adminRepository.getAdminStatistics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDarkGreen,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Admin Dashboard', style: TextStyle(color: AppColors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.white),
            onPressed: _loadStats,
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.white),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.adminSettings),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<AdminStatistics>(
          future: _statsFuture,
          builder: (context, snapshot) {
            final usersVal = '14';            // Fake user count
            final chargersVal = '6';          // Fake active chargers
            final bookingsVal = '3';          // Fake live sessions
            final revenueVal = '₹ 4,250';     // Fake revenue

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'VOLTERA System Overview',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.white),
                  ),
                  const SizedBox(height: 20),

                  // Overview Cards Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      _DashboardCard(
                        title: 'Users',
                        value: usersVal,
                        subtitle: 'Customers & Providers',
                        icon: Icons.people,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.adminUsers),
                      ),
                      _DashboardCard(
                        title: 'Chargers',
                        value: chargersVal,
                        subtitle: 'Active & Stations',
                        icon: Icons.ev_station,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.adminChargers),
                      ),
                      _DashboardCard(
                        title: 'Bookings',
                        value: bookingsVal,
                        subtitle: 'Active Sessions',
                        icon: Icons.bolt,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.adminSessions),
                      ),
                      _DashboardCard(
                        title: 'Transactions',
                        value: revenueVal,
                        subtitle: 'Gross Revenue',
                        icon: Icons.receipt_long,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.adminTransactions),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  const Text(
                    'Console Management',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white),
                  ),
                  const SizedBox(height: 16),

                  // Navigation Tiles List
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        _AdminNavTile(
                          icon: Icons.people_outline,
                          title: 'Manage Users',
                          subtitle: 'View user accounts & verification',
                          onTap: () => Navigator.pushNamed(context, AppRoutes.adminUsers),
                        ),
                        const Divider(height: 1, indent: 56),
                        _AdminNavTile(
                          icon: Icons.business_outlined,
                          title: 'Manage Providers',
                          subtitle: 'Provider verification & documents',
                          onTap: () => Navigator.pushNamed(context, AppRoutes.adminProviders),
                        ),
                        const Divider(height: 1, indent: 56),
                        _AdminNavTile(
                          icon: Icons.ev_station_outlined,
                          title: 'Manage Chargers',
                          subtitle: 'Approve & monitor charging stations',
                          onTap: () => Navigator.pushNamed(context, AppRoutes.adminChargers),
                        ),
                        const Divider(height: 1, indent: 56),
                        _AdminNavTile(
                          icon: Icons.history_outlined,
                          title: 'Charging Sessions',
                          subtitle: 'Live session monitoring & history',
                          onTap: () => Navigator.pushNamed(context, AppRoutes.adminSessions),
                        ),
                        const Divider(height: 1, indent: 56),
                        _AdminNavTile(
                          icon: Icons.monetization_on_outlined,
                          title: 'Payments & Transactions',
                          subtitle: 'Platform revenue & payouts',
                          onTap: () => Navigator.pushNamed(context, AppRoutes.adminTransactions),
                        ),
                        const Divider(height: 1, indent: 56),
                        _AdminNavTile(
                          icon: Icons.report_problem_outlined,
                          title: 'Reports & Issues',
                          subtitle: 'User reports, charger & payment issues',
                          onTap: () => Navigator.pushNamed(context, AppRoutes.adminReports),
                        ),
                        const Divider(height: 1, indent: 56),
                        _AdminNavTile(
                          icon: Icons.settings_outlined,
                          title: 'Admin Settings',
                          subtitle: 'System security & configuration',
                          onTap: () => Navigator.pushNamed(context, AppRoutes.adminSettings),
                        ),
                      ],
                    ),
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
                        'Logout Admin',
                        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: AppColors.lightGreen, fontWeight: FontWeight.w600),
                ),
                Icon(icon, color: AppColors.lightGreen, size: 20),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.white),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 10, color: Colors.white60),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminNavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AdminNavTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryDarkGreen, size: 24),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
      onTap: onTap,
    );
  }
}
