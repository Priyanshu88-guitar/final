import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../data/services/api_service.dart';
import '../../widgets/common/empty_state.dart';

class SavedChargersScreen extends StatefulWidget {
  const SavedChargersScreen({super.key});

  @override
  State<SavedChargersScreen> createState() => _SavedChargersScreenState();
}

class _SavedChargersScreenState extends State<SavedChargersScreen> {
  late Future<List<dynamic>> _savedFuture;

  @override
  void initState() {
    super.initState();
    _savedFuture = _fetchSavedChargers();
  }

  Future<List<dynamic>> _fetchSavedChargers() async {
    try {
      final apiService = ApiService();
      final res = await apiService.get('/customer/saved-chargers');
      final data = res['data'];
      if (data is List) {
        return data;
      }
      return [];
    } catch (_) {
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
        title: const Text('Saved Chargers'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<dynamic>>(
          future: _savedFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final saved = snapshot.data ?? [];
            if (saved.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(AppSpacing.screenHorizontalPadding),
                child: EmptyState(
                  icon: Icons.bookmark_border,
                  title: 'No Saved Chargers Yet',
                  message: 'Bookmark your favorite charging stations for quick access and live availability updates.',
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontalPadding),
              itemCount: saved.length,
              itemBuilder: (context, index) {
                final item = saved[index] as Map<String, dynamic>;
                final charger = item['charger'] as Map<String, dynamic>? ?? {};
                final station = charger['station'] as Map<String, dynamic>? ?? {};
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.ev_station, color: AppColors.primaryDarkGreen, size: 36),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              station['name'] as String? ?? 'Voltera Station',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${charger['name'] ?? 'Charger'} • ${charger['connectorType'] ?? 'CCS2'} (${charger['powerKw'] ?? 30} kW)',
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              station['address'] as String? ?? '',
                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
