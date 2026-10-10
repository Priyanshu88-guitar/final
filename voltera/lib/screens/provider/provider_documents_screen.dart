import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../widgets/common/status_badge.dart';

class ProviderDocumentsScreen extends StatelessWidget {
  const ProviderDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Documents'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontalPadding),
          children: [
            const Text(
              'Required Documents',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              'Upload official documents to verify your EV charging business.',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 20),

            _DocumentTile(
              title: 'Government Issued ID / Aadhaar / PAN',
              status: 'Verified',
              statusColor: AppColors.primaryDarkGreen,
              badgeBg: const Color(0xFFE2EFC5),
            ),
            const SizedBox(height: 12),
            _DocumentTile(
              title: 'Business / Electricity Meter Bill',
              status: 'Verified',
              statusColor: AppColors.primaryDarkGreen,
              badgeBg: const Color(0xFFE2EFC5),
            ),
            const SizedBox(height: 12),
            _DocumentTile(
              title: 'Property / Land Lease Agreement',
              status: 'Pending',
              statusColor: const Color(0xFFE89B38),
              badgeBg: const Color(0xFFFBF4D3),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  final String title;
  final String status;
  final Color statusColor;
  final Color badgeBg;

  const _DocumentTile({
    required this.title,
    required this.status,
    required this.statusColor,
    required this.badgeBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ),
              StatusBadge(
                label: status,
                backgroundColor: badgeBg,
                textColor: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Document upload action ready for backend integration.')),
              );
            },
            icon: const Icon(Icons.upload_file, size: 18),
            label: Text(status == 'Verified' ? 'Replace Document' : 'Upload Document'),
          ),
        ],
      ),
    );
  }
}
