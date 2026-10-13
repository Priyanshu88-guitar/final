import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/demo/demo_config.dart';
import '../../core/demo/demo_data.dart';
import '../../data/services/api_service.dart';
import '../../widgets/common/voltera_button.dart';

class BundlesScreen extends StatefulWidget {
  const BundlesScreen({super.key});

  @override
  State<BundlesScreen> createState() => _BundlesScreenState();
}

class _BundlesScreenState extends State<BundlesScreen> {
  late Future<List<Map<String, dynamic>>> _bundlesFuture;

  @override
  void initState() {
    super.initState();
    _bundlesFuture = _fetchBundles();
  }

  Future<List<Map<String, dynamic>>> _fetchBundles() async {
    try {
      final apiService = ApiService();
      final res = await apiService.get('/bundles');
      final data = res['data'];
      if (data is List) {
        return data.map((e) {
          final item = e as Map<String, dynamic>;
          return {
            'name': item['name'] ?? 'Charging Bundle',
            'price': '₹${item['price'] ?? 499}',
            'energy': '${item['validityDays'] ?? 30} Days Validity',
            'savings': 'Best Value',
            'validity': '${item['validityDays'] ?? 30} Days',
          };
        }).toList();
      }
      return [];
    } catch (_) {
      if (DemoConfig.demoMode) {
        return DemoData.demoBundles;
      }
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Charging Bundles'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _bundlesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final bundles = snapshot.data ?? [];
            if (bundles.isEmpty) {
              return const Center(
                child: Text('No charging bundles currently available.', style: TextStyle(color: AppColors.textMuted)),
              );
            }
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontalPadding),
              children: [
                const Text(
                  'Available Packages',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Save more on daily rides with custom EV charging bundles.',
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
                const SizedBox(height: 20),
                ...bundles.map((b) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _BundleCard(
                        title: b['name'] as String? ?? '',
                        price: '${b['price']}',
                        benefits: '${b['energy']}',
                        validity: 'Valid for ${b['validity']}',
                      ),
                    )),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BundleCard extends StatelessWidget {
  final String title;
  final String price;
  final String benefits;
  final String validity;

  const _BundleCard({
    required this.title,
    required this.price,
    required this.benefits,
    required this.validity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryDarkGreen.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ),
              Text(
                price,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryDarkGreen),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(benefits, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(validity, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 16),
          VolteraButton(
            text: 'Subscribe Package',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bundle subscribed successfully!')),
              );
            },
          ),
        ],
      ),
    );
  }
}
