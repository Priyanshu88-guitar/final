import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../data/services/api_service.dart';
import '../../widgets/common/empty_state.dart';

class ChargingHistoryScreen extends StatefulWidget {
  const ChargingHistoryScreen({super.key});

  @override
  State<ChargingHistoryScreen> createState() => _ChargingHistoryScreenState();
}

class _ChargingHistoryScreenState extends State<ChargingHistoryScreen> {
  late Future<List<dynamic>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _bookingsFuture = _fetchBookings();
  }

  Future<List<dynamic>> _fetchBookings() async {
    try {
      final apiService = ApiService();
      final res = await apiService.get('/customer/bookings');
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
        title: const Text('Charging History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<dynamic>>(
          future: _bookingsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final bookings = snapshot.data ?? [];
            if (bookings.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(AppSpacing.screenHorizontalPadding),
                child: EmptyState(
                  icon: Icons.history,
                  title: 'No Charging History Yet',
                  message: 'Your completed charging sessions, energy consumed, and payment summaries will appear here.',
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontalPadding),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final b = bookings[index] as Map<String, dynamic>;
                final charger = b['charger'] as Map<String, dynamic>? ?? {};
                final station = charger['station'] as Map<String, dynamic>? ?? {};
                final status = b['status'] as String? ?? 'COMPLETED';
                final startTime = b['startTime'] as String? ?? '';
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              station['name'] as String? ?? 'Voltera Station',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: status == 'COMPLETED' ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: status == 'COMPLETED' ? Colors.green[700] : Colors.orange[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('Connector: ${charger['connectorType'] ?? 'CCS2'} (${charger['powerKw'] ?? 30} kW)', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Text('Slot: ${startTime.length > 10 ? startTime.substring(0, 16).replaceFirst('T', ' ') : startTime}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
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
