import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../widgets/common/voltera_button.dart';

class CustomerFiltersScreen extends StatefulWidget {
  const CustomerFiltersScreen({super.key});

  @override
  State<CustomerFiltersScreen> createState() => _CustomerFiltersScreenState();
}

class _CustomerFiltersScreenState extends State<CustomerFiltersScreen> {
  String _selectedConnector = 'All Types';
  String _selectedSpeed = 'All';
  bool _availabilityOnly = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Filters'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Location Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: AppColors.textMuted),
                    SizedBox(width: 12),
                    Text('Search Location', style: TextStyle(color: AppColors.textMuted)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Connector Types',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: ['All Types', 'CCS2', 'GB/T'].map((type) {
                  final isSelected = _selectedConnector == type;
                  return ChoiceChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedConnector = type;
                      });
                    },
                    selectedColor: AppColors.primaryDarkGreen,
                    backgroundColor: const Color(0xFFEFECC7).withValues(alpha: 0.6),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              const Text(
                'Charging Speed',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: ['All', 'Fast', 'Super Fast'].map((speed) {
                  final isSelected = _selectedSpeed == speed;
                  return ChoiceChip(
                    label: Text(speed),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedSpeed = speed;
                      });
                    },
                    selectedColor: AppColors.primaryDarkGreen,
                    backgroundColor: const Color(0xFFEFECC7).withValues(alpha: 0.6),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Availability',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  Switch(
                    value: _availabilityOnly,
                    activeThumbColor: AppColors.primaryDarkGreen,
                    onChanged: (val) {
                      setState(() {
                        _availabilityOnly = val;
                      });
                    },
                  ),
                ],
              ),
              const Divider(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Price Range (₹/kWh)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  Text(
                    '₹5-₹20',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              VolteraButton(
                text: 'Apply Filters',
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
