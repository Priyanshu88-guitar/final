import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../widgets/common/empty_state.dart';
import '../../data/services/api_service.dart';
import '../../data/repositories/admin_repository.dart';
import '../../models/admin/admin_transaction.dart';

class AdminTransactionsScreen extends StatefulWidget {
  const AdminTransactionsScreen({super.key});

  @override
  State<AdminTransactionsScreen> createState() => _AdminTransactionsScreenState();
}

class _AdminTransactionsScreenState extends State<AdminTransactionsScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  late Future<List<AdminTransactionRecord>> _transactionsFuture;
  final AdminRepository _adminRepository = AdminRepositoryImpl(apiService: ApiService());

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    setState(() {
      _transactionsFuture = _adminRepository.getAllTransactions();
    });
  }

  void _showTransactionDetailsModal(AdminTransactionRecord txn) {
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
                  'Transaction Audit Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 24),
            _detailRow('Transaction ID:', txn.id),
            const SizedBox(height: 10),
            _detailRow('Reference No:', txn.referenceNumber),
            const SizedBox(height: 10),
            _detailRow('User Name:', txn.userName),
            const SizedBox(height: 10),
            _detailRow('Station / Description:', txn.stationName),
            const SizedBox(height: 10),
            _detailRow('Type:', txn.type),
            const SizedBox(height: 10),
            _detailRow('Payment Method:', txn.method),
            const SizedBox(height: 10),
            _detailRow('Amount:', '₹ ${txn.amount.toStringAsFixed(2)}'),
            const SizedBox(height: 10),
            _detailRow('Status:', txn.status),
            const SizedBox(height: 10),
            _detailRow('Date & Time:', txn.timestamp.toLocal().toString().split('.')[0]),
            const SizedBox(height: 24),
            Row(
              children: [
                if (txn.status == 'FAILED' || txn.status == 'COMPLETED')
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.deepOrange),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Refund of ₹ ${txn.amount.toStringAsFixed(0)} initiated successfully'),
                            backgroundColor: Colors.deepOrange,
                          ),
                        );
                        _loadTransactions();
                      },
                      child: const Text('Issue Refund', style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                    ),
                  ),
                if (txn.status == 'FAILED' || txn.status == 'COMPLETED') const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDarkGreen,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close Audit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        title: const Text('Payments & Financial Audit'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: _loadTransactions,
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
                    _TxnSummaryItem(label: 'Gross Volume', value: '₹ 4.82 Cr'),
                    _TxnSummaryItem(label: 'Completed', value: '₹ 4.52 Cr'),
                    _TxnSummaryItem(label: 'Pending', value: '₹ 18.3 L'),
                    _TxnSummaryItem(label: 'Failed', value: '₹ 12.5 L'),
                    _TxnSummaryItem(label: 'Refunded', value: '₹ 8.12 L'),
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
                    hintText: 'Search Txn ID, user, reference or station...',
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
                  children: ['All', 'COMPLETED', 'PENDING', 'FAILED', 'REFUNDED'].map((filter) {
                    final isSelected = _selectedFilter.toUpperCase() == filter.toUpperCase();
                    final label = filter == 'All'
                        ? 'All'
                        : filter == 'COMPLETED'
                            ? 'Completed'
                            : filter == 'PENDING'
                                ? 'Pending'
                                : filter == 'FAILED'
                                    ? 'Failed'
                                    : 'Refunded';

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
                child: FutureBuilder<List<AdminTransactionRecord>>(
                  future: _transactionsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primaryDarkGreen));
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error loading transactions: ${snapshot.error}'));
                    }

                    final allTxns = snapshot.data ?? [];
                    final filteredTxns = allTxns.where((t) {
                      final statusUpper = t.status.toUpperCase();
                      bool matchesStatus = _selectedFilter == 'All' || statusUpper == _selectedFilter.toUpperCase();

                      bool matchesSearch = _searchQuery.isEmpty ||
                          t.id.toLowerCase().contains(_searchQuery) ||
                          t.userName.toLowerCase().contains(_searchQuery) ||
                          t.stationName.toLowerCase().contains(_searchQuery) ||
                          t.method.toLowerCase().contains(_searchQuery) ||
                          t.referenceNumber.toLowerCase().contains(_searchQuery);

                      return matchesStatus && matchesSearch;
                    }).toList();

                    if (filteredTxns.isEmpty) {
                      return const EmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: 'No Matching Transactions',
                        message: 'Try adjusting your search query or payment status filter.',
                      );
                    }

                    return ListView.builder(
                      itemCount: filteredTxns.length,
                      itemBuilder: (context, index) {
                        final txn = filteredTxns[index];
                        final statusUpper = txn.status.toUpperCase();

                        return InkWell(
                          onTap: () => _showTransactionDetailsModal(txn),
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
                                            txn.id,
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDarkGreen),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          txn.method,
                                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: statusUpper == 'COMPLETED'
                                            ? Colors.green.withValues(alpha: 0.1)
                                            : statusUpper == 'PENDING'
                                                ? Colors.orange.withValues(alpha: 0.1)
                                                : statusUpper == 'REFUNDED'
                                                    ? Colors.deepOrange.withValues(alpha: 0.1)
                                                    : Colors.red.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        statusUpper,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: statusUpper == 'COMPLETED'
                                              ? Colors.green
                                              : statusUpper == 'PENDING'
                                                  ? Colors.orange
                                                  : statusUpper == 'REFUNDED'
                                                      ? Colors.deepOrange
                                                      : Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'User: ${txn.userName}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Target: ${txn.stationName} (${txn.type})',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Ref: ${txn.referenceNumber}',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                    ),
                                    Text(
                                      '₹ ${txn.amount.toStringAsFixed(0)}',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDarkGreen),
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

class _TxnSummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _TxnSummaryItem({required this.label, required this.value});

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
