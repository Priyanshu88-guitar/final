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

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
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
      backgroundColor: AppColors.primaryDarkGreen,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('VOLTERA Admin Console', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.white),
            onPressed: _loadStats,
            tooltip: 'Refresh Stats',
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.white),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.adminSettings),
            tooltip: 'Admin Settings',
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<AdminStatistics>(
          future: _statsFuture,
          builder: (context, snapshot) {
            final stats = snapshot.data ?? AdminStatistics.largeMockData;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Live System Statistics',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.white),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.lightGreen.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.lightGreen.withValues(alpha: 0.4)),
                        ),
                        child: const Row(
                          children: [
                            CircleAvatar(radius: 4, backgroundColor: AppColors.lightGreen),
                            SizedBox(width: 6),
                            Text('System Normal', style: TextStyle(color: AppColors.lightGreen, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Overview Cards Grid
                  Column(
                    children: [
                      // Row 1: Users & Providers
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              title: 'Registered Users',
                              value: _formatNumber(stats.totalUsers),
                              subtitle: '${_formatNumber(stats.registeredCustomers)} Cust • ${_formatNumber(stats.registeredProviders)} Prov',
                              badgeText: '${_formatNumber(stats.activeUsers)} Active',
                              badgeColor: Colors.greenAccent,
                              icon: Icons.people,
                              onTap: () => Navigator.pushNamed(context, AppRoutes.adminUsers),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              title: 'Service Providers',
                              value: _formatNumber(stats.totalProviders),
                              subtitle: '${_formatNumber(stats.verifiedProviders)} Verified • ${_formatNumber(stats.pendingProviders)} Pend',
                              badgeText: '${stats.rejectedProviders} Rejected',
                              badgeColor: Colors.orangeAccent,
                              icon: Icons.business,
                              onTap: () => Navigator.pushNamed(context, AppRoutes.adminProviders),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Row 2: Chargers & Sessions
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              title: 'Stations / Chargers',
                              value: '${_formatNumber(stats.totalStations)} / ${_formatNumber(stats.totalChargers)}',
                              subtitle: '${_formatNumber(stats.activeChargers)} Active • ${stats.maintenanceChargers} Maint',
                              badgeText: '${stats.reportedChargers} Issues',
                              badgeColor: Colors.amberAccent,
                              icon: Icons.ev_station,
                              onTap: () => Navigator.pushNamed(context, AppRoutes.adminChargers),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              title: 'Charging Sessions',
                              value: _formatNumber(stats.totalSessions),
                              subtitle: 'Completed: ${_formatNumber(stats.completedSessions)}',
                              badgeText: '${_formatNumber(stats.activeSessions)} Live • ${_formatNumber(stats.failedSessions)} Fail',
                              badgeColor: Colors.lightBlueAccent,
                              icon: Icons.bolt,
                              onTap: () => Navigator.pushNamed(context, AppRoutes.adminSessions),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Row 3: Transactions & Revenue
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              title: 'Transactions Logged',
                              value: _formatNumber(stats.totalTransactions),
                              subtitle: '${_formatNumber(stats.completedPayments)} Done • ${_formatNumber(stats.pendingPayments)} Pend',
                              badgeText: '${_formatNumber(stats.failedPayments)} Failed',
                              badgeColor: Colors.redAccent,
                              icon: Icons.receipt_long,
                              onTap: () => Navigator.pushNamed(context, AppRoutes.adminTransactions),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              title: 'Gross Revenue',
                              value: _formatCurrency(stats.totalRevenue),
                              subtitle: 'Commission: ${_formatCurrency(stats.commissionEarned)}',
                              badgeText: 'Payouts: ${_formatCurrency(stats.providerPayouts)}',
                              badgeColor: Colors.greenAccent,
                              icon: Icons.account_balance_wallet,
                              onTap: () => Navigator.pushNamed(context, AppRoutes.adminRevenue),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Row 4: Reports & Issues
                      _FullWidthStatCard(
                        title: 'Support Reports & Disputes',
                        value: '${stats.totalReports} Total Issues',
                        subtitle: 'Resolved: ${stats.resolvedReports} • Pending Review: ${stats.openReports}',
                        icon: Icons.report_problem,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.adminReports),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  const Text(
                    'Console Management Modules',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white),
                  ),
                  const SizedBox(height: 14),

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
                          subtitle: '${stats.totalUsers} Registered (${stats.registeredCustomers} Customers, ${stats.registeredProviders} Providers)',
                          onTap: () => Navigator.pushNamed(context, AppRoutes.adminUsers),
                        ),
                        const Divider(height: 1, indent: 56),
                        _AdminNavTile(
                          icon: Icons.business_outlined,
                          title: 'Manage Providers',
                          subtitle: '${stats.totalProviders} Business Partners (${stats.pendingProviders} Pending Approval)',
                          onTap: () => Navigator.pushNamed(context, AppRoutes.adminProviders),
                        ),
                        const Divider(height: 1, indent: 56),
                        _AdminNavTile(
                          icon: Icons.ev_station_outlined,
                          title: 'Manage Chargers & Stations',
                          subtitle: '${stats.totalStations} Stations, ${stats.totalChargers} Chargers (${stats.activeChargers} Online)',
                          onTap: () => Navigator.pushNamed(context, AppRoutes.adminChargers),
                        ),
                        const Divider(height: 1, indent: 56),
                        _AdminNavTile(
                          icon: Icons.history_outlined,
                          title: 'Charging Sessions Monitor',
                          subtitle: '${stats.totalSessions} Sessions (${stats.activeSessions} Active, ${stats.failedSessions} Failed)',
                          onTap: () => Navigator.pushNamed(context, AppRoutes.adminSessions),
                        ),
                        const Divider(height: 1, indent: 56),
                        _AdminNavTile(
                          icon: Icons.receipt_long_outlined,
                          title: 'Payments & Transactions',
                          subtitle: '${stats.totalTransactions} Transactions (${stats.completedPayments} Successful, ${stats.failedPayments} Failed)',
                          onTap: () => Navigator.pushNamed(context, AppRoutes.adminTransactions),
                        ),
                        const Divider(height: 1, indent: 56),
                        _AdminNavTile(
                          icon: Icons.monetization_on_outlined,
                          title: 'Revenue & Commission',
                          subtitle: 'Gross Volume: ${_formatCurrency(stats.totalRevenue)} | Platform Fee: ${_formatCurrency(stats.commissionEarned)}',
                          onTap: () => Navigator.pushNamed(context, AppRoutes.adminRevenue),
                        ),
                        const Divider(height: 1, indent: 56),
                        _AdminNavTile(
                          icon: Icons.report_problem_outlined,
                          title: 'Reports & Issues',
                          subtitle: '${stats.totalReports} Tickets (${stats.openReports} Open, ${stats.resolvedReports} Resolved)',
                          onTap: () => Navigator.pushNamed(context, AppRoutes.adminReports),
                        ),
                        const Divider(height: 1, indent: 56),
                        _AdminNavTile(
                          icon: Icons.settings_outlined,
                          title: 'Admin Settings & Controls',
                          subtitle: 'System security, role permissions & configuration',
                          onTap: () => Navigator.pushNamed(context, AppRoutes.adminSettings),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        VolteraSession().logout();
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.welcome,
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.logout, color: Colors.redAccent),
                      label: const Text(
                        'Logout Admin',
                        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final String badgeText;
  final Color badgeColor;
  final IconData icon;
  final VoidCallback onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.badgeText,
    required this.badgeColor,
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
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColors.lightGreen, fontWeight: FontWeight.w600),
                  ),
                ),
                Icon(icon, color: AppColors.lightGreen, size: 20),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.white),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, color: Colors.white70),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badgeText,
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: badgeColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FullWidthStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _FullWidthStatCard({
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.lightGreen.withValues(alpha: 0.2),
              child: Icon(icon, color: AppColors.lightGreen),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12, color: AppColors.lightGreen, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.white70)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.lightGreen),
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
