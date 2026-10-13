import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../app/session.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/demo/demo_config.dart';
import '../../core/demo/demo_data.dart';
import '../../widgets/common/section_title.dart';
import '../../data/services/api_service.dart';
import '../../data/repositories/customer_repository.dart';
import '../../models/customer/charger.dart';
import 'full_map/full_charger_map_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  late Future<List<Charger>> _chargersFuture;

  @override
  void initState() {
    super.initState();
    _loadChargers();
  }

  void _loadChargers() {
    _chargersFuture = CustomerRepositoryImpl(apiService: ApiService()).getChargers();
  }

  @override
  Widget build(BuildContext context) {
    final userName = VolteraSession().fullName ?? 'Customer';
    final batteryPercent = DemoConfig.demoMode ? 72 : 85;
    final rangeKm = DemoConfig.demoMode ? 286 : 310;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, $userName',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Good Morning!',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.customerProfile);
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppColors.lightGreen, AppColors.primaryDarkGreen],
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.person, color: AppColors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Search Bar Trigger
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.customerSearch);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search, color: AppColors.textMuted),
                      SizedBox(width: 12),
                      Text(
                        'Search Location or Charger',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Battery Status Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2EFC5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Battery Status',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$batteryPercent%',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Range: $rangeKm km',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // AI Suggestion Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBF4D3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Color(0xFFE89B38)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'AI Suggestion: Nearby fast chargers available now. GreenCharge Hub recommended.',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Quick Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _QuickActionButton(
                    icon: Icons.qr_code_scanner,
                    label: 'Scan & Pay',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.customerScanPay);
                    },
                  ),
                  _QuickActionButton(
                    icon: Icons.local_offer_outlined,
                    label: 'Bundles',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.customerBundles);
                    },
                  ),
                  _QuickActionButton(
                    icon: Icons.support_agent,
                    label: 'Emergency',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.customerEmergency);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Nearby Chargers Section
              SectionTitle(
                title: 'Nearby Chargers',
                actionText: 'View All',
                onActionPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const FullChargerMapScreen()));
                },
              ),
              const SizedBox(height: 12),

              FutureBuilder<List<Charger>>(
                future: _chargersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final chargers = (snapshot.hasData && snapshot.data!.isNotEmpty)
                      ? snapshot.data!
                      : DemoData.nearbyChargers.map((c) => Charger(
                            id: c['id'] as String? ?? 'chg',
                            name: c['name'] as String? ?? 'Charger',
                            providerId: 'demo',
                            locationAddress: c['address'] as String? ?? '',
                            latitude: 23.0,
                            longitude: 72.0,
                            connectorType: c['connector'] as String? ?? 'CCS2',
                            powerKw: 30.0,
                            pricePerHour: 100.0,
                            pricePerKwh: 15.0,
                            isAvailable: c['status'] == 'Available',
                            rating: 4.5,
                          )).toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: chargers.length > 3 ? 3 : chargers.length,
                    itemBuilder: (context, index) {
                      final charger = chargers[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border, width: 0.5),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            charger.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            '${charger.connectorType} · ${charger.isAvailable ? "Available" : "Busy"}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                          trailing: Text(
                            '₹${charger.pricePerKwh}/kWh',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppColors.primaryDarkGreen,
                            ),
                          ),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.customerDetails,
                              arguments: {'chargerName': charger.name},
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icon, color: AppColors.primaryDarkGreen, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
