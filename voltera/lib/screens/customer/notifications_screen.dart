import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/demo/demo_config.dart';
import '../../core/demo/demo_data.dart';
import '../../data/services/api_service.dart';
import '../../widgets/common/empty_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<Map<String, dynamic>>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _fetchNotifications();
  }

  Future<List<Map<String, dynamic>>> _fetchNotifications() async {
    try {
      final apiService = ApiService();
      final res = await apiService.get('/notifications');
      final data = res['data'];
      List items = [];
      if (data is Map && data['items'] is List) {
        items = data['items'] as List;
      } else if (data is List) {
        items = data;
      }
      if (items.isNotEmpty) {
        return items.map((e) {
          final item = e as Map<String, dynamic>;
          return {
            'title': item['title'] as String? ?? 'Notification',
            'subtitle': item['body'] as String? ?? '',
            'time': item['createdAt'] != null ? item['createdAt'].toString().substring(11, 16) : 'Just now',
            'unread': item['isRead'] == false,
          };
        }).toList();
      }
      return [];
    } catch (_) {
      if (DemoConfig.demoMode) {
        return DemoData.notificationsList;
      }
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
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _notificationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final notifications = snapshot.data ?? [];
            if (notifications.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(AppSpacing.screenHorizontalPadding),
                child: EmptyState(
                  icon: Icons.notifications_none,
                  title: 'No Notifications Yet',
                  message: 'You are all caught up!',
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontalPadding),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                final isUnread = notif['unread'] == true;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isUnread ? const Color(0xFFE2EFC5).withValues(alpha: 0.4) : AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isUnread ? Icons.notifications_active : Icons.notifications_outlined,
                        color: AppColors.primaryDarkGreen,
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
                                    notif['title'] as String? ?? '',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                                  ),
                                ),
                                Text(
                                  notif['time'] as String? ?? '',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notif['subtitle'] as String? ?? '',
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
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
