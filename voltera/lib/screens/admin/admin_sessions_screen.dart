import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../widgets/common/empty_state.dart';
import '../../data/services/api_service.dart';
import '../../data/repositories/admin_repository.dart';
import '../../models/admin/admin_session.dart';

class AdminSessionsScreen extends StatefulWidget {
  const AdminSessionsScreen({super.key});

  @override
  State<AdminSessionsScreen> createState() => _AdminSessionsScreenState();
}

class _AdminSessionsScreenState extends State<AdminSessionsScreen> {
  String _selectedStatus = 'All';
  String _searchQuery = '';
  late Future<List<AdminSessionRecord>> _sessionsFuture;
  final AdminRepository _adminRepository = AdminRepositoryImpl(apiService: ApiService());

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  void _loadSessions() {
    setState(() {
      _sessionsFuture = _adminRepository.getAllSessions();
    });
  }

  void _showSessionDetailsModal(AdminSessionRecord session) {
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
                  'Charging Session Record',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 24),
            _detailRow('Session ID:', session.id),
            const SizedBox(height: 10),
            _detailRow('Customer Name:', session.customerName),
            const SizedBox(height: 10),
            _detailRow('Provider:', session.providerName),
            const SizedBox(height: 10),
            _detailRow('Station Name:', session.stationName),
            const SizedBox(height: 10),
            _detailRow('Charger Gun ID:', session.chargerId),
            const SizedBox(height: 10),
            _detailRow('Duration:', session.duration),
            const SizedBox(height: 10),
            _detailRow('Energy Consumed:', session.energyKwh),
            const SizedBox(height: 10),
            _detailRow('Session Cost:', '₹ ${session.cost.toStringAsFixed(2)}'),
            const SizedBox(height: 10),
            _detailRow('Session Status:', session.status),
            const SizedBox(height: 10),
            _detailRow('Start Time:', session.startTime.toLocal().toString().split('.')[0]),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDarkGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Close Record', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        title: const Text('Charging Sessions Monitor'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: _loadSessions,
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
                    _SessionSummaryItem(label: 'Total Sessions', value: '1,48,920'),
                    _SessionSummaryItem(label: 'Completed', value: '1,32,450'),
                    _SessionSummaryItem(label: 'Live Active', value: '1,240'),
                    _SessionSummaryItem(label: 'Failed', value: '4,120'),
                    _SessionSummaryItem(label: 'Cancelled', value: '7,260'),
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
                    hintText: 'Search by Session ID, customer or station...',
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
                  children: ['All', 'ACTIVE', 'COMPLETED', 'PENDING', 'FAILED', 'CANCELLED'].map((status) {
                    final isSelected = _selectedStatus.toUpperCase() == status.toUpperCase();
                    final label = status == 'All'
                        ? 'All'
                        : status == 'ACTIVE'
                            ? 'Live Active'
                            : status == 'COMPLETED'
                                ? 'Completed'
                                : status == 'PENDING'
                                    ? 'Scheduled'
                                    : status == 'FAILED'
                                        ? 'Failed'
                                        : 'Cancelled';

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
                child: FutureBuilder<List<AdminSessionRecord>>(
                  future: _sessionsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primaryDarkGreen));
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error loading sessions: ${snapshot.error}'));
                    }

                    final allSessions = snapshot.data ?? [];
                    final filteredSessions = allSessions.where((s) {
                      final statusUpper = s.status.toUpperCase();
                      bool matchesStatus = _selectedStatus == 'All' || statusUpper == _selectedStatus.toUpperCase();

                      bool matchesSearch = _searchQuery.isEmpty ||
                          s.id.toLowerCase().contains(_searchQuery) ||
                          s.customerName.toLowerCase().contains(_searchQuery) ||
                          s.providerName.toLowerCase().contains(_searchQuery) ||
                          s.stationName.toLowerCase().contains(_searchQuery);

                      return matchesStatus && matchesSearch;
                    }).toList();

                    if (filteredSessions.isEmpty) {
                      return const EmptyState(
                        icon: Icons.history_outlined,
                        title: 'No Matching Sessions Found',
                        message: 'Try adjusting your search query or status filter.',
                      );
                    }

                    return ListView.builder(
                      itemCount: filteredSessions.length,
                      itemBuilder: (context, index) {
                        final session = filteredSessions[index];
                        final statusUpper = session.status.toUpperCase();

                        return InkWell(
                          onTap: () => _showSessionDetailsModal(session),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
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
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryDarkGreen.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            session.id,
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDarkGreen),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          session.chargerId,
                                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: statusUpper == 'COMPLETED'
                                            ? Colors.green.withValues(alpha: 0.1)
                                            : statusUpper == 'ACTIVE'
                                                ? Colors.blue.withValues(alpha: 0.1)
                                                : statusUpper == 'FAILED'
                                                    ? Colors.red.withValues(alpha: 0.1)
                                                    : Colors.orange.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        statusUpper == 'ACTIVE' ? 'LIVE NOW' : statusUpper,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: statusUpper == 'COMPLETED'
                                              ? Colors.green
                                              : statusUpper == 'ACTIVE'
                                                  ? Colors.blue
                                                  : statusUpper == 'FAILED'
                                                      ? Colors.red
                                                      : Colors.orange,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Customer: ${session.customerName}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Station: ${session.stationName} (${session.providerName})',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '⚡ ${session.energyKwh} • ⏱️ ${session.duration}',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                    ),
                                    Text(
                                      '₹ ${session.cost.toStringAsFixed(0)}',
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryDarkGreen),
                                    ),
                                  ],
                                ),
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

class _SessionSummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _SessionSummaryItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.white)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.lightGreen)),
      ],
    );
  }
}
