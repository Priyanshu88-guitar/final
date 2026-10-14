import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../widgets/common/empty_state.dart';
import '../../data/services/api_service.dart';
import '../../data/repositories/admin_repository.dart';
import '../../models/admin/admin_user.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  late Future<List<AdminUser>> _usersFuture;
  final AdminRepository _adminRepository = AdminRepositoryImpl(apiService: ApiService());

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    setState(() {
      _usersFuture = _adminRepository.getAllUsers();
    });
  }

  void _showUserDetailsModal(AdminUser user) {
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
                  'User Profile & Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 24),
            _detailRow('User ID:', user.id),
            const SizedBox(height: 10),
            _detailRow('Full Name:', user.name.isNotEmpty ? user.name : 'User'),
            const SizedBox(height: 10),
            _detailRow('Email:', user.email),
            const SizedBox(height: 10),
            _detailRow('Phone Number:', user.phone),
            const SizedBox(height: 10),
            _detailRow('Primary Role:', user.role.name.toUpperCase()),
            const SizedBox(height: 10),
            _detailRow('Location:', user.location),
            const SizedBox(height: 10),
            _detailRow('Total Sessions:', '${user.totalSessions} Sessions'),
            const SizedBox(height: 10),
            _detailRow('Wallet Balance:', '₹ ${user.walletBalance.toStringAsFixed(2)}'),
            const SizedBox(height: 10),
            _detailRow('Account Status:', user.isActive ? 'ACTIVE' : 'SUSPENDED'),
            const SizedBox(height: 10),
            _detailRow('Registered On:', user.createdAt.toLocal().toString().split(' ')[0]),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: user.isActive ? Colors.red : Colors.green),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(user.isActive ? 'User account suspended' : 'User account activated'),
                          backgroundColor: user.isActive ? Colors.red : Colors.green,
                        ),
                      );
                      _loadUsers();
                    },
                    child: Text(
                      user.isActive ? 'Suspend User' : 'Activate User',
                      style: TextStyle(color: user.isActive ? Colors.red : Colors.green, fontWeight: FontWeight.bold),
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
          width: 130,
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
        title: const Text('Manage Registered Users'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: _loadUsers,
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
                    _UserStatSummaryItem(label: 'Total Users', value: '15,480'),
                    _UserStatSummaryItem(label: 'Customers', value: '12,850'),
                    _UserStatSummaryItem(label: 'Providers', value: '2,420'),
                    _UserStatSummaryItem(label: 'Active', value: '14,920'),
                    _UserStatSummaryItem(label: 'Suspended', value: '560'),
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
                    hintText: 'Search by name, email, phone or city...',
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
                  children: ['All', 'customer', 'provider', 'admin', 'Active', 'Suspended'].map((filter) {
                    final isSelected = _selectedFilter.toLowerCase() == filter.toLowerCase();
                    final label = filter == 'All'
                        ? 'All'
                        : filter == 'customer'
                            ? 'Customers'
                            : filter == 'provider'
                                ? 'Providers'
                                : filter == 'admin'
                                    ? 'Admins'
                                    : filter;

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
                child: FutureBuilder<List<AdminUser>>(
                  future: _usersFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primaryDarkGreen));
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error loading users: ${snapshot.error}'));
                    }

                    final allUsers = snapshot.data ?? [];
                    final filteredUsers = allUsers.where((u) {
                      // Filter by chip
                      final filterLower = _selectedFilter.toLowerCase();
                      bool matchesChip = true;
                      if (filterLower == 'all') {
                        matchesChip = true;
                      } else if (filterLower == 'active') {
                        matchesChip = u.isActive;
                      } else if (filterLower == 'suspended') {
                        matchesChip = !u.isActive;
                      } else {
                        matchesChip = u.roles.any((r) => r.name.toLowerCase() == filterLower);
                      }

                      // Filter by search query
                      bool matchesSearch = _searchQuery.isEmpty ||
                          u.name.toLowerCase().contains(_searchQuery) ||
                          u.email.toLowerCase().contains(_searchQuery) ||
                          u.phone.toLowerCase().contains(_searchQuery) ||
                          u.location.toLowerCase().contains(_searchQuery);

                      return matchesChip && matchesSearch;
                    }).toList();

                    if (filteredUsers.isEmpty) {
                      return const EmptyState(
                        icon: Icons.people_outline,
                        title: 'No Matching Users Found',
                        message: 'Try adjusting your search terms or role filters.',
                      );
                    }

                    return ListView.builder(
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        final roleName = user.role.name.toUpperCase();

                        return InkWell(
                          onTap: () => _showUserDetailsModal(user),
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
                                  backgroundColor: roleName == 'PROVIDER'
                                      ? Colors.orange.withValues(alpha: 0.2)
                                      : roleName == 'ADMIN'
                                          ? Colors.purple.withValues(alpha: 0.2)
                                          : AppColors.lightGreen.withValues(alpha: 0.2),
                                  child: Text(
                                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                    style: TextStyle(
                                      color: roleName == 'PROVIDER'
                                          ? Colors.orange.shade800
                                          : roleName == 'ADMIN'
                                              ? Colors.purple.shade800
                                              : AppColors.primaryDarkGreen,
                                      fontWeight: FontWeight.bold,
                                    ),
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
                                              user.name.isNotEmpty ? user.name : user.email,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: user.isActive ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              user.isActive ? 'ACTIVE' : 'SUSPENDED',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: user.isActive ? Colors.green : Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${user.email} • ${user.phone}',
                                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.information.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              roleName,
                                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.information),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${user.location} • ${user.totalSessions} Sessions',
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

class _UserStatSummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _UserStatSummaryItem({required this.label, required this.value});

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
