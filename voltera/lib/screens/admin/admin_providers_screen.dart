import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../widgets/common/empty_state.dart';
import '../../data/services/api_service.dart';
import '../../widgets/common/voltera_button.dart';

class AdminProvidersScreen extends StatefulWidget {
  const AdminProvidersScreen({super.key});

  @override
  State<AdminProvidersScreen> createState() => _AdminProvidersScreenState();
}

class _AdminProvidersScreenState extends State<AdminProvidersScreen> {
  late Future<List<dynamic>> _providersFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  void _loadProviders() {
    setState(() {
      _providersFuture = _fetchProviders();
    });
  }

  Future<List<dynamic>> _fetchProviders() async {
    try {
      final res = await _apiService.get('/admin/stations');
      return res['data'] as List<dynamic>? ?? [];
    } catch (_) {
      return [];
    }
  }

  Future<void> _verifyProvider(String providerId, bool approve) async {
    try {
      await _apiService.patch('/admin/providers/$providerId/verification', body: {
        'verificationStatus': approve ? 'VERIFIED' : 'REJECTED',
        'rejectionReason': approve ? null : 'Rejected by admin review',
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(approve ? 'Provider approved successfully' : 'Provider rejected')),
      );
      _loadProviders();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update verification: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Manage Providers'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: _loadProviders,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: _providersFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primaryDarkGreen));
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error loading providers: ${snapshot.error}'));
                    }

                    final stations = snapshot.data ?? [];
                    if (stations.isEmpty) {
                      return const EmptyState(
                        icon: Icons.business_outlined,
                        title: 'No Service Providers Available',
                        message: 'Registered service provider stations and setup photos will appear here for review.',
                      );
                    }

                    return ListView.builder(
                      itemCount: stations.length,
                      itemBuilder: (context, index) {
                        final station = stations[index] as Map<String, dynamic>;
                        final stationName = station['name'] as String? ?? 'Station';
                        final address = station['address'] as String? ?? '';
                        final status = station['status'] as String? ?? 'PENDING';
                        final providerId = station['providerId'] as String? ?? '';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      stationName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: status == 'ACTIVE' ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      status,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: status == 'ACTIVE' ? Colors.green : Colors.orange,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(address, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: providerId.isNotEmpty ? () => _verifyProvider(providerId, false) : null,
                                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                                      child: const Text('Reject', style: TextStyle(color: Colors.red)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: VolteraButton(
                                      text: 'Approve',
                                      onPressed: providerId.isNotEmpty ? () => _verifyProvider(providerId, true) : null,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
