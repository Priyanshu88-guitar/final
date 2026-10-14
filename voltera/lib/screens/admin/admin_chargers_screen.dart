import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../widgets/common/empty_state.dart';
import '../../data/services/api_service.dart';
import '../../data/repositories/admin_repository.dart';
import '../../models/admin/admin_charger.dart';

class AdminChargersScreen extends StatefulWidget {
  const AdminChargersScreen({super.key});

  @override
  State<AdminChargersScreen> createState() => _AdminChargersScreenState();
}

class _AdminChargersScreenState extends State<AdminChargersScreen> {
  String _selectedStatus = 'All';
  String _searchQuery = '';
  late Future<List<AdminCharger>> _chargersFuture;
  final AdminRepository _adminRepository = AdminRepositoryImpl(apiService: ApiService());

  @override
  void initState() {
    super.initState();
    _loadChargers();
  }

  void _loadChargers() {
    setState(() {
      _chargersFuture = _adminRepository.getAllChargers();
    });
  }

  void _showChargerDetailsModal(AdminCharger charger) {
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
                  'Charging Station Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 24),
            _detailRow('Station Name:', charger.name),
            const SizedBox(height: 10),
            _detailRow('Provider:', charger.providerName),
            const SizedBox(height: 10),
            _detailRow('Location / City:', charger.location),
            const SizedBox(height: 10),
            _detailRow('Connector Type:', charger.connectorType),
            const SizedBox(height: 10),
            _detailRow('Power Output:', charger.powerKw),
            const SizedBox(height: 10),
            _detailRow('Charging Rate:', charger.pricePerKwh),
            const SizedBox(height: 10),
            _detailRow('Operational Status:', charger.status),
            const SizedBox(height: 10),
            _detailRow('Total Sessions Served:', '${charger.totalSessions} Sessions'),
            const SizedBox(height: 10),
            _detailRow('Rating:', '⭐ ${charger.rating} / 5.0'),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: charger.status == 'ACTIVE' ? Colors.orange : Colors.green),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(charger.status == 'ACTIVE' ? 'Station placed in maintenance' : 'Station activated'),
                          backgroundColor: charger.status == 'ACTIVE' ? Colors.orange : Colors.green,
                        ),
                      );
                      _loadChargers();
                    },
                    child: Text(
                      charger.status == 'ACTIVE' ? 'Set Maintenance' : 'Set Active',
                      style: TextStyle(color: charger.status == 'ACTIVE' ? Colors.orange : Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
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
        title: const Text('Manage Charging Stations'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: _loadChargers,
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
                    _ChargerSummaryItem(label: 'Stations', value: '3,850'),
                    _ChargerSummaryItem(label: 'Chargers', value: '11,420'),
                    _ChargerSummaryItem(label: 'Online', value: '9,840'),
                    _ChargerSummaryItem(label: 'Maint', value: '1,120'),
                    _ChargerSummaryItem(label: 'Reported', value: '150'),
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
                    hintText: 'Search station, provider or connector type...',
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
                  children: ['All', 'ACTIVE', 'MAINTENANCE', 'PENDING', 'REPORTED'].map((status) {
                    final isSelected = _selectedStatus.toUpperCase() == status.toUpperCase();
                    final label = status == 'All'
                        ? 'All'
                        : status == 'ACTIVE'
                            ? 'Online'
                            : status == 'MAINTENANCE'
                                ? 'Maintenance'
                                : status == 'PENDING'
                                    ? 'Pending Approval'
                                    : 'Reported Issues';

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
                child: FutureBuilder<List<AdminCharger>>(
                  future: _chargersFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primaryDarkGreen));
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error loading chargers: ${snapshot.error}'));
                    }

                    final allChargers = snapshot.data ?? [];
                    final filteredChargers = allChargers.where((c) {
                      final statusUpper = c.status.toUpperCase();
                      bool matchesStatus = _selectedStatus == 'All' || statusUpper == _selectedStatus.toUpperCase();

                      bool matchesSearch = _searchQuery.isEmpty ||
                          c.name.toLowerCase().contains(_searchQuery) ||
                          c.providerName.toLowerCase().contains(_searchQuery) ||
                          c.location.toLowerCase().contains(_searchQuery) ||
                          c.connectorType.toLowerCase().contains(_searchQuery);

                      return matchesStatus && matchesSearch;
                    }).toList();

                    if (filteredChargers.isEmpty) {
                      return const EmptyState(
                        icon: Icons.ev_station_outlined,
                        title: 'No Matching Chargers Found',
                        message: 'Try adjusting your search query or status filter.',
                      );
                    }

                    return ListView.builder(
                      itemCount: filteredChargers.length,
                      itemBuilder: (context, index) {
                        final charger = filteredChargers[index];
                        final statusUpper = charger.status.toUpperCase();

                        return InkWell(
                          onTap: () => _showChargerDetailsModal(charger),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: statusUpper == 'ACTIVE'
                                      ? Colors.green.withValues(alpha: 0.15)
                                      : statusUpper == 'MAINTENANCE'
                                          ? Colors.orange.withValues(alpha: 0.15)
                                          : statusUpper == 'REPORTED'
                                              ? Colors.red.withValues(alpha: 0.15)
                                              : Colors.blue.withValues(alpha: 0.15),
                                  child: Icon(
                                    Icons.ev_station,
                                    color: statusUpper == 'ACTIVE'
                                        ? Colors.green
                                        : statusUpper == 'MAINTENANCE'
                                            ? Colors.orange
                                            : statusUpper == 'REPORTED'
                                                ? Colors.red
                                                : Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              charger.name,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: statusUpper == 'ACTIVE'
                                                  ? Colors.green.withValues(alpha: 0.1)
                                                  : statusUpper == 'MAINTENANCE'
                                                      ? Colors.orange.withValues(alpha: 0.1)
                                                      : statusUpper == 'REPORTED'
                                                          ? Colors.red.withValues(alpha: 0.1)
                                                          : Colors.blue.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              statusUpper == 'ACTIVE' ? 'ONLINE' : statusUpper,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: statusUpper == 'ACTIVE'
                                                    ? Colors.green
                                                    : statusUpper == 'MAINTENANCE'
                                                        ? Colors.orange
                                                        : statusUpper == 'REPORTED'
                                                            ? Colors.red
                                                            : Colors.blue,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${charger.providerName} • ${charger.location}',
                                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryDarkGreen.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              '${charger.connectorType} (${charger.powerKw})',
                                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryDarkGreen),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${charger.pricePerKwh} • ⭐ ${charger.rating}',
                                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right, color: AppColors.textMuted),
                              ],
                            ),
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

class _ChargerSummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _ChargerSummaryItem({required this.label, required this.value});

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
