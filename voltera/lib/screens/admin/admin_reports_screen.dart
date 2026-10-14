import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../widgets/common/empty_state.dart';
import '../../data/services/api_service.dart';
import '../../data/repositories/admin_repository.dart';
import '../../models/admin/admin_report.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  late Future<List<AdminReportRecord>> _reportsFuture;
  final AdminRepository _adminRepository = AdminRepositoryImpl(apiService: ApiService());

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  void _loadReports() {
    setState(() {
      _reportsFuture = _adminRepository.getAllReports();
    });
  }

  void _showReportDetailsModal(AdminReportRecord report) {
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
                  'Support Report & Dispute',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 24),
            _detailRow('Report ID:', report.id),
            const SizedBox(height: 10),
            _detailRow('Submitted By:', '${report.userName} (${report.userEmail})'),
            const SizedBox(height: 10),
            _detailRow('Category:', report.category),
            const SizedBox(height: 10),
            _detailRow('Priority:', report.priority),
            const SizedBox(height: 10),
            _detailRow('Subject:', report.subject),
            const SizedBox(height: 10),
            _detailRow('Description:', report.description),
            const SizedBox(height: 10),
            _detailRow('Status:', report.status),
            const SizedBox(height: 10),
            _detailRow('Submitted On:', report.timestamp.toLocal().toString().split('.')[0]),
            const SizedBox(height: 24),

            if (report.status != 'RESOLVED')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryDarkGreen),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ticket status updated to IN_PROGRESS'), backgroundColor: Colors.blue),
                        );
                        _loadReports();
                      },
                      child: const Text('In Progress', style: TextStyle(color: AppColors.primaryDarkGreen, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ticket resolved successfully'), backgroundColor: Colors.green),
                        );
                        _loadReports();
                      },
                      child: const Text('Mark Resolved', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                  child: const Text('Close Ticket', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        title: const Text('Reports & Customer Issues'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: _loadReports,
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
                    _ReportSummaryItem(label: 'Total Reports', value: '840'),
                    _ReportSummaryItem(label: 'Open', value: '125'),
                    _ReportSummaryItem(label: 'In Progress', value: '85'),
                    _ReportSummaryItem(label: 'Resolved', value: '630'),
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
                    hintText: 'Search Report ID, user or issue subject...',
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
                  children: ['All', 'OPEN', 'IN_PROGRESS', 'RESOLVED', 'CHARGER_ISSUE', 'PAYMENT_DISPUTE'].map((filter) {
                    final isSelected = _selectedFilter.toUpperCase() == filter.toUpperCase();
                    final label = filter == 'All'
                        ? 'All'
                        : filter == 'OPEN'
                            ? 'Open'
                            : filter == 'IN_PROGRESS'
                                ? 'In Progress'
                                : filter == 'RESOLVED'
                                    ? 'Resolved'
                                    : filter == 'CHARGER_ISSUE'
                                        ? 'Charger Issues'
                                        : 'Payment Disputes';

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(label),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedFilter = filter;
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
                child: FutureBuilder<List<AdminReportRecord>>(
                  future: _reportsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primaryDarkGreen));
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error loading reports: ${snapshot.error}'));
                    }

                    final allReports = snapshot.data ?? [];
                    final filteredReports = allReports.where((r) {
                      final statusUpper = r.status.toUpperCase();
                      final categoryUpper = r.category.toUpperCase();

                      bool matchesFilter = _selectedFilter == 'All' ||
                          statusUpper == _selectedFilter.toUpperCase() ||
                          categoryUpper == _selectedFilter.toUpperCase();

                      bool matchesSearch = _searchQuery.isEmpty ||
                          r.id.toLowerCase().contains(_searchQuery) ||
                          r.userName.toLowerCase().contains(_searchQuery) ||
                          r.subject.toLowerCase().contains(_searchQuery) ||
                          r.description.toLowerCase().contains(_searchQuery);

                      return matchesFilter && matchesSearch;
                    }).toList();

                    if (filteredReports.isEmpty) {
                      return const EmptyState(
                        icon: Icons.report_problem_outlined,
                        title: 'No Matching Issues Found',
                        message: 'Check your search query or selected report category.',
                      );
                    }

                    return ListView.builder(
                      itemCount: filteredReports.length,
                      itemBuilder: (context, index) {
                        final report = filteredReports[index];
                        final statusUpper = report.status.toUpperCase();
                        final priorityUpper = report.priority.toUpperCase();

                        return InkWell(
                          onTap: () => _showReportDetailsModal(report),
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
                                            report.id,
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDarkGreen),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: priorityUpper == 'HIGH'
                                                ? Colors.red.withValues(alpha: 0.15)
                                                : priorityUpper == 'MEDIUM'
                                                    ? Colors.orange.withValues(alpha: 0.15)
                                                    : Colors.blue.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            '$priorityUpper PRIORITY',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: priorityUpper == 'HIGH'
                                                  ? Colors.red
                                                  : priorityUpper == 'MEDIUM'
                                                      ? Colors.orange
                                                      : Colors.blue,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: statusUpper == 'RESOLVED'
                                            ? Colors.green.withValues(alpha: 0.1)
                                            : statusUpper == 'IN_PROGRESS'
                                                ? Colors.blue.withValues(alpha: 0.1)
                                                : Colors.red.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        statusUpper,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: statusUpper == 'RESOLVED'
                                              ? Colors.green
                                              : statusUpper == 'IN_PROGRESS'
                                                  ? Colors.blue
                                                  : Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  report.subject,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  report.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'By: ${report.userName} (${report.category})',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryDarkGreen),
                                    ),
                                    const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
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

class _ReportSummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _ReportSummaryItem({required this.label, required this.value});

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
