import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../widgets/common/empty_state.dart';
import '../../data/services/api_service.dart';
import '../../widgets/common/voltera_button.dart';
import '../../core/demo/demo_data.dart';

class AdminProvidersScreen extends StatefulWidget {
  const AdminProvidersScreen({super.key});

  @override
  State<AdminProvidersScreen> createState() => _AdminProvidersScreenState();
}

class _AdminProvidersScreenState extends State<AdminProvidersScreen> {
  String _selectedStatus = 'All';
  String _searchQuery = '';
  late Future<List<Map<String, dynamic>>> _providersFuture;
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

  Future<List<Map<String, dynamic>>> _fetchProviders() async {
    try {
      final res = await _apiService.get('/admin/stations');
      final data = res['data'] as List<dynamic>?;
      if (data != null && data.isNotEmpty) {
        return data.cast<Map<String, dynamic>>();
      }
      return DemoData.adminProviders;
    } catch (_) {
      return DemoData.adminProviders;
    }
  }

  Future<void> _verifyProvider(String providerId, bool approve) async {
    try {
      await _apiService.patch('/admin/providers/$providerId/verification', body: {
        'verificationStatus': approve ? 'APPROVED' : 'REJECTED',
        'rejectionReason': approve ? null : 'Rejected by admin review',
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(approve ? 'Provider approved successfully' : 'Provider application rejected'),
          backgroundColor: approve ? Colors.green : Colors.red,
        ),
      );
      _loadProviders();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(approve ? 'Provider approved in demo mode' : 'Provider rejected in demo mode'),
          backgroundColor: approve ? Colors.green : Colors.red,
        ),
      );
      _loadProviders();
    }
  }

  void _showProviderDetailsModal(Map<String, dynamic> provider) {
    final business = provider['business'] ?? provider['name'] ?? 'EV Hub';
    final owner = provider['name'] ?? 'Provider Partner';
    final city = provider['city'] ?? provider['address'] ?? 'Ahmedabad';
    final status = (provider['status'] ?? 'APPROVED').toString().toUpperCase();
    final chargers = provider['chargers'] ?? 6;
    final earnings = provider['earnings'] ?? '₹ 1,24,500';
    final rating = provider['rating'] ?? 4.8;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Provider Business Profile',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 24),
            _detailRow('Business Name:', business),
            const SizedBox(height: 10),
            _detailRow('Owner Name:', owner),
            const SizedBox(height: 10),
            _detailRow('City / Location:', city),
            const SizedBox(height: 10),
            _detailRow('Active Stations/Chargers:', '$chargers Connectors'),
            const SizedBox(height: 10),
            _detailRow('Total Platform Earnings:', earnings.toString()),
            const SizedBox(height: 10),
            _detailRow('Customer Rating:', '⭐ $rating / 5.0'),
            const SizedBox(height: 10),
            _detailRow('Verification Status:', status),
            const SizedBox(height: 24),

            if (status == 'PENDING')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _verifyProvider(provider['id'] ?? 'PRV-202', false);
                      },
                      child: const Text('Reject Partner', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: VolteraButton(
                      text: 'Approve Partner',
                      onPressed: () {
                        Navigator.pop(context);
                        _verifyProvider(provider['id'] ?? 'PRV-202', true);
                      },
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDarkGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textMuted, fontSize: 13)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 14)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Manage Service Providers'),
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
              // Summary Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryDarkGreen,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ProviderSummaryItem(label: 'Total Partners', value: '2,420'),
                    _ProviderSummaryItem(label: 'Verified', value: '2,150'),
                    _ProviderSummaryItem(label: 'Pending', value: '210'),
                    _ProviderSummaryItem(label: 'Rejected', value: '60'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.toLowerCase();
                    });
                  },
                  decoration: const InputDecoration(
                    icon: Icon(Icons.search, color: AppColors.textMuted),
                    hintText: 'Search provider or business name...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(fontSize: 14, color: AppColors.textMuted),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'APPROVED', 'PENDING', 'REJECTED'].map((status) {
                    final isSelected = _selectedStatus.toUpperCase() == status.toUpperCase();
                    final label = status == 'All'
                        ? 'All'
                        : status == 'APPROVED'
                            ? 'Verified'
                            : status == 'PENDING'
                                ? 'Pending Approval'
                                : 'Rejected';

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(label),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedStatus = status;
                            });
                          }
                        },
                        selectedColor: AppColors.primaryDarkGreen,
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _providersFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primaryDarkGreen));
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error loading providers: ${snapshot.error}'));
                    }

                    final allProviders = snapshot.data ?? [];
                    final filteredProviders = allProviders.where((p) {
                      final statusUpper = (p['status'] ?? 'APPROVED').toString().toUpperCase();
                      bool matchesStatus = _selectedStatus == 'All' || statusUpper == _selectedStatus.toUpperCase();

                      final business = (p['business'] ?? p['name'] ?? '').toString().toLowerCase();
                      final owner = (p['name'] ?? '').toString().toLowerCase();
                      final city = (p['city'] ?? p['address'] ?? '').toString().toLowerCase();

                      bool matchesSearch = _searchQuery.isEmpty ||
                          business.contains(_searchQuery) ||
                          owner.contains(_searchQuery) ||
                          city.contains(_searchQuery);

                      return matchesStatus && matchesSearch;
                    }).toList();

                    if (filteredProviders.isEmpty) {
                      return const EmptyState(
                        icon: Icons.business_outlined,
                        title: 'No Matching Providers Found',
                        message: 'Check your search query or selected verification status.',
                      );
                    }

                    return ListView.builder(
                      itemCount: filteredProviders.length,
                      itemBuilder: (context, index) {
                        final provider = filteredProviders[index];
                        final business = provider['business'] ?? provider['name'] ?? 'EV Station';
                        final owner = provider['name'] ?? 'Partner';
                        final city = provider['city'] ?? provider['address'] ?? 'Ahmedabad';
                        final status = (provider['status'] ?? 'APPROVED').toString().toUpperCase();
                        final chargers = provider['chargers'] ?? 6;
                        final earnings = provider['earnings'] ?? '₹ 1,24,500';
                        final providerId = provider['id'] ?? 'PRV-201';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
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
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          business,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                                        ),
                                        Text(
                                          'Owner: $owner • $city',
                                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: status == 'APPROVED'
                                          ? Colors.green.withValues(alpha: 0.1)
                                          : status == 'PENDING'
                                              ? Colors.orange.withValues(alpha: 0.1)
                                              : Colors.red.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      status == 'APPROVED' ? 'VERIFIED' : status,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: status == 'APPROVED'
                                            ? Colors.green
                                            : status == 'PENDING'
                                                ? Colors.orange
                                                : Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(Icons.ev_station, size: 16, color: AppColors.primaryDarkGreen),
                                  const SizedBox(width: 4),
                                  Text('$chargers Chargers Available', style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                                  const SizedBox(width: 16),
                                  const Icon(Icons.monetization_on_outlined, size: 16, color: Colors.green),
                                  const SizedBox(width: 4),
                                  Text(earnings, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => _showProviderDetailsModal(provider),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: AppColors.primaryDarkGreen),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      child: const Text('View Profile', style: TextStyle(color: AppColors.primaryDarkGreen, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  if (status == 'PENDING') ...[
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => _verifyProvider(providerId, true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        child: const Text('Approve', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ],
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

class _ProviderSummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _ProviderSummaryItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.white)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.lightGreen)),
      ],
    );
  }
}
