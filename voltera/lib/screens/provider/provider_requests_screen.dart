import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../data/services/provider_state_manager.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/empty_state.dart';

class ProviderRequestsScreen extends StatefulWidget {
  const ProviderRequestsScreen({super.key});

  @override
  State<ProviderRequestsScreen> createState() => _ProviderRequestsScreenState();
}

class _ProviderRequestsScreenState extends State<ProviderRequestsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ProviderStateManager(),
      builder: (context, _) {
        final state = ProviderStateManager();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            title: const Text('Charging Requests'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            bottom: TabBar(
              controller: _tabController,
              labelColor: AppColors.primaryDarkGreen,
              unselectedLabelColor: AppColors.textMuted,
              indicatorColor: AppColors.primaryDarkGreen,
              tabs: [
                Tab(text: 'Incoming (${state.pendingRequests.length})'),
                Tab(text: 'Accepted (${state.acceptedRequests.length})'),
                Tab(text: 'Rejected (${state.rejectedRequests.length})'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // Incoming Requests Tab
              _buildRequestList(
                context,
                requests: state.pendingRequests,
                emptyTitle: 'No Incoming Requests',
                emptyMessage: 'New charging requests from nearby EV riders will appear here.',
                showActions: true,
              ),
              // Accepted Requests Tab
              _buildRequestList(
                context,
                requests: state.acceptedRequests,
                emptyTitle: 'No Accepted Requests',
                emptyMessage: 'Accepted charging requests will be listed here.',
                showActions: false,
                isAcceptedTab: true,
              ),
              // Rejected Requests Tab
              _buildRequestList(
                context,
                requests: state.rejectedRequests,
                emptyTitle: 'No Rejected Requests',
                emptyMessage: 'Rejected charging requests will be logged here.',
                showActions: false,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRequestList(
    BuildContext context, {
    required List requests,
    required String emptyTitle,
    required String emptyMessage,
    required bool showActions,
    bool isAcceptedTab = false,
  }) {
    if (requests.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: EmptyState(
          icon: Icons.inbox_outlined,
          title: emptyTitle,
          message: emptyMessage,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final req = requests[index];
        final stateManager = ProviderStateManager();

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
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
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.lightGreen, AppColors.primaryDarkGreen],
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.person, color: AppColors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Request ID: ${req.id}',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Charger: ${req.chargerId}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: req.status == 'accepted'
                          ? AppColors.lightGreen.withValues(alpha: 0.3)
                          : req.status == 'rejected'
                              ? AppColors.error.withValues(alpha: 0.1)
                              : const Color(0xFFFBF4D3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      req.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: req.status == 'accepted'
                            ? AppColors.primaryDarkGreen
                            : req.status == 'rejected'
                                ? AppColors.error
                                : const Color(0xFFE89B38),
                      ),
                    ),
                  ),
                ],
              ),
              if (showActions) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          stateManager.acceptRequest(req.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Request ${req.id} accepted.')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDarkGreen,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text('Accept', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          stateManager.rejectRequest(req.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Request ${req.id} rejected.')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text('Reject', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
              if (isAcceptedTab) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.providerSession);
                    },
                    child: const Text('View Active Session'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
