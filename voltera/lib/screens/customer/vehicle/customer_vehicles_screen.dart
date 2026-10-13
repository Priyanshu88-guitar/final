import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../widgets/common/voltera_button.dart';
import '../../../widgets/common/voltera_outline_button.dart';
import '../../../widgets/common/empty_state.dart';

class CustomerVehiclesScreen extends StatefulWidget {
  const CustomerVehiclesScreen({super.key});

  @override
  State<CustomerVehiclesScreen> createState() => _CustomerVehiclesScreenState();
}

class _CustomerVehiclesScreenState extends State<CustomerVehiclesScreen> {
  // In a real app this would come from the API (CustomerVehicle model).
  final List<Map<String, dynamic>> _vehicles = [];

  void _showAddVehicleBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddVehicleBottomSheet(),
    ).then((result) {
      if (result != null && result is Map<String, dynamic>) {
        setState(() {
          _vehicles.add(result);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vehicles'),
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _vehicles.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(AppSpacing.screenHorizontalPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const EmptyState(
                      icon: Icons.electric_scooter,
                      title: 'No Vehicles Added',
                      message: 'Add your electric two-wheeler to find the best compatible chargers.',
                    ),
                    const SizedBox(height: 24),
                    VolteraButton(
                      text: 'Add New Vehicle',
                      onPressed: _showAddVehicleBottomSheet,
                    )
                  ],
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(AppSpacing.screenHorizontalPadding),
                children: [
                  ..._vehicles.map((v) => _VehicleCard(vehicle: v)),
                  const SizedBox(height: 24),
                  VolteraOutlineButton(
                    text: 'Add Another Vehicle',
                    onPressed: _showAddVehicleBottomSheet,
                  )
                ],
              ),
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final Map<String, dynamic> vehicle;

  const _VehicleCard({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryDarkGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.electric_scooter, color: AppColors.primaryDarkGreen, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${vehicle['make']} ${vehicle['model']}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Connector: ${vehicle['connector']} • ${vehicle['battery']} kWh',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Pending Verification',
                    style: TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddVehicleBottomSheet extends StatefulWidget {
  const _AddVehicleBottomSheet();

  @override
  State<_AddVehicleBottomSheet> createState() => _AddVehicleBottomSheetState();
}

class _AddVehicleBottomSheetState extends State<_AddVehicleBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  
  // Example EV Two-Wheeler Database
  final List<Map<String, dynamic>> _vehicleDatabase = [
    {'make': 'Ather', 'model': '450X', 'connector': 'Ather Proprietary', 'battery': 3.7, 'range': 110},
    {'make': 'Ola', 'model': 'S1 Pro', 'connector': 'Hypercharger Port', 'battery': 4.0, 'range': 181},
    {'make': 'TVS', 'model': 'iQube ST', 'connector': 'Type 2 / 15A', 'battery': 4.56, 'range': 145},
    {'make': 'Bajaj', 'model': 'Chetak', 'connector': '5A / 15A Socket', 'battery': 2.88, 'range': 90},
    {'make': 'Hero', 'model': 'Vida V1 Pro', 'connector': 'Portable / Fast', 'battery': 3.94, 'range': 165},
    {'make': 'Simple', 'model': 'One', 'connector': 'Proprietary', 'battery': 5.0, 'range': 212},
    {'make': 'Other', 'model': 'Custom', 'connector': '3 PIN (15A)', 'battery': 2.0, 'range': 60},
  ];
  
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _batteryController = TextEditingController();
  final _connectorController = TextEditingController();
  final _rangeController = TextEditingController();

  void _onPresetSelected(Map<String, dynamic>? preset) {
    setState(() {
      if (preset != null) {
        _makeController.text = preset['make'];
        _modelController.text = preset['model'];
        _batteryController.text = preset['battery'].toString();
        _connectorController.text = preset['connector'];
        _rangeController.text = preset['range'].toString();
      } else {
        _makeController.clear();
        _modelController.clear();
        _batteryController.clear();
        _connectorController.clear();
        _rangeController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Add Two-Wheeler EV', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              
              const Text('Select Pre-filled Model', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<Map<String, dynamic>>(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                hint: const Text('Select a popular model...'),
                items: _vehicleDatabase.map((v) => DropdownMenuItem(
                  value: v,
                  child: Text('${v['make']} ${v['model']}'),
                )).toList(),
                onChanged: _onPresetSelected,
              ),
              const SizedBox(height: 16),
              
              const Text('Make / Brand', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              TextFormField(controller: _makeController, decoration: const InputDecoration(hintText: 'e.g. Ather')),
              const SizedBox(height: 12),

              const Text('Model', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              TextFormField(controller: _modelController, decoration: const InputDecoration(hintText: 'e.g. 450X')),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Battery (kWh)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        TextFormField(controller: _batteryController, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: '3.7')),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Est. Range (km)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        TextFormField(controller: _rangeController, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: '110')),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              const Text('Connector Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              TextFormField(controller: _connectorController, decoration: const InputDecoration(hintText: 'e.g. 15A Socket')),
              const SizedBox(height: 24),

              VolteraButton(
                text: 'Save Vehicle',
                onPressed: () {
                  if (_makeController.text.isNotEmpty && _modelController.text.isNotEmpty) {
                    Navigator.pop(context, {
                      'make': _makeController.text,
                      'model': _modelController.text,
                      'battery': _batteryController.text,
                      'connector': _connectorController.text,
                      'range': _rangeController.text,
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
