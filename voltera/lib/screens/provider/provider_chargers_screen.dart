import 'package:flutter/material.dart';
import '../../data/services/provider_state_manager.dart';
import '../../models/provider/provider_charger.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../widgets/common/voltera_button.dart';
import '../../widgets/common/voltera_text_field.dart';
import '../../widgets/common/empty_state.dart';

class ProviderChargersScreen extends StatefulWidget {
  const ProviderChargersScreen({super.key});

  @override
  State<ProviderChargersScreen> createState() => _ProviderChargersScreenState();
}

class _ProviderChargersScreenState extends State<ProviderChargersScreen> {
  void _showAddChargerModal(BuildContext context) {
    final nameController = TextEditingController();
    final powerController = TextEditingController(text: '7.4');
    final priceController = TextEditingController(text: '12.0');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add New Charger',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 16),
                VolteraTextField(
                  controller: nameController,
                  label: 'Charger Name',
                  hint: 'e.g. Station Bay 3',
                  validator: (v) => v == null || v.isEmpty ? 'Please enter charger name' : null,
                ),
                const SizedBox(height: 12),
                VolteraTextField(
                  controller: powerController,
                  label: 'Power (kW)',
                  hint: '7.4',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                VolteraTextField(
                  controller: priceController,
                  label: 'Price per kWh (₹)',
                  hint: '12.0',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                VolteraButton(
                  text: 'Save Charger',
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      final newCharger = ProviderCharger(
                        id: 'CHG-${DateTime.now().millisecondsSinceEpoch}',
                        providerId: 'PROV-1',
                        name: nameController.text.trim(),
                        status: 'Available',
                        powerKw: double.tryParse(powerController.text) ?? 7.4,
                        pricePerKwh: double.tryParse(priceController.text) ?? 12.0,
                      );
                      ProviderStateManager().addCharger(newCharger);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('New charger registered successfully.')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ProviderStateManager(),
      builder: (context, _) {
        final state = ProviderStateManager();
        final chargers = state.chargers;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            title: const Text('My Chargers'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Registered Chargers',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      Text(
                        '${chargers.length} Total',
                        style: const TextStyle(fontSize: 13, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (chargers.isEmpty)
                    const Expanded(
                      child: EmptyState(
                        icon: Icons.ev_station_outlined,
                        title: 'No Chargers Added Yet',
                        message: 'Register your EV charging station bays to start receiving customer requests.',
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: chargers.length,
                        itemBuilder: (context, index) {
                          final charger = chargers[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border, width: 0.5),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryDarkGreen.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.ev_station, color: AppColors.primaryDarkGreen, size: 28),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        charger.name,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${charger.powerKw} kW · ₹${charger.pricePerKwh}/kWh · ${charger.status}',
                                        style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                  onPressed: () {
                                    state.removeCharger(charger.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Charger ${charger.name} removed.')),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                  VolteraButton(
                    text: '+ Add New Charger',
                    onPressed: () => _showAddChargerModal(context),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
