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
  String _selectedRole = 'All';
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
                  'User Details & Roles',
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
            const SizedBox(height: 12),
            _detailRow('Email / Phone:', user.email),
            const SizedBox(height: 12),
            _detailRow('Primary Role:', user.role.name.toUpperCase()),
            const SizedBox(height: 12),
            _detailRow('All Assigned Roles:', user.roles.map((r) => r.name.toUpperCase()).join(', ')),
            const SizedBox(height: 12),
            _detailRow('Account Status:', user.isActive ? 'ACTIVE' : 'SUSPENDED'),
            const SizedBox(height: 12),
            _detailRow('Registered On:', user.createdAt.toLocal().toString().split('.')[0]),
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
          width: 130,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textMuted)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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
        title: const Text('Manage Users'),
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
              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'customer', 'provider', 'admin'].map((role) {
                    final label = role == 'All' ? 'All' : (role[0].toUpperCase() + role.substring(1));
                    final isSelected = _selectedRole.toLowerCase() == role.toLowerCase();
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(label),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedRole = role;
                            });
                          }
                        },
                        selectedColor: AppColors.primaryDarkGreen,
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
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
                    final filteredUsers = _selectedRole.toLowerCase() == 'all'
                        ? allUsers
                        : allUsers.where((u) => u.roles.any((r) => r.name.toLowerCase() == _selectedRole.toLowerCase())).toList();

                    if (filteredUsers.isEmpty) {
                      return const EmptyState(
                        icon: Icons.people_outline,
                        title: 'No Registered Users Available',
                        message: 'Registered customers, providers, and admins will be listed here.',
                      );
                    }

                    return ListView.builder(
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        final rolesString = user.roles.map((r) => r.name.toUpperCase()).join(' & ');

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
                                  backgroundColor: AppColors.lightGreen.withValues(alpha: 0.2),
                                  child: Text(
                                    user.email.isNotEmpty ? user.email[0].toUpperCase() : 'U',
                                    style: const TextStyle(color: AppColors.primaryDarkGreen, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.email,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.information.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              rolesString,
                                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.information),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            user.isActive ? 'ACTIVE' : 'SUSPENDED',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: user.isActive ? Colors.green : Colors.red,
                                            ),
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
