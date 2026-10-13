import 'package:flutter/material.dart';
import '../../app/session.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/utils/validators.dart';
import '../../widgets/common/voltera_button.dart';
import '../../widgets/common/voltera_text_field.dart';
import '../../data/services/api_service.dart';
import 'package:latlong2/latlong.dart';
import 'map_picker/provider_map_picker_screen.dart';

class EditBusinessProfileScreen extends StatefulWidget {
  const EditBusinessProfileScreen({super.key});

  @override
  State<EditBusinessProfileScreen> createState() => _EditBusinessProfileScreenState();
}

class _EditBusinessProfileScreenState extends State<EditBusinessProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _businessNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  LatLng? _pinnedLocation;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final session = VolteraSession();
    _businessNameController = TextEditingController(text: session.businessName ?? 'GreenCharge Hub');
    _phoneController = TextEditingController(text: session.businessPhone ?? session.mobileNumber ?? '');
    _emailController = TextEditingController(text: session.businessEmail ?? session.email ?? '');
    _addressController = TextEditingController(text: session.businessAddress ?? '');
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _onSaveBusinessProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_pinnedLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an exact map location for your station'), backgroundColor: Colors.red),
        );
        return;
      }

      setState(() {
        _isSaving = true;
      });

      try {
        final apiService = ApiService();

        // 1. Save Profile
        await apiService.post('/provider/profile', body: {
          'businessName': _businessNameController.text.trim(),
          'contactPhone': _phoneController.text.trim(),
          'contactEmail': _emailController.text.trim(),
          'address': _addressController.text.trim(),
        });

        // 2. Save Charging Station Location to Database so customers can see it on the map
        await apiService.post('/provider/stations', body: {
          'name': _businessNameController.text.trim(),
          'address': _addressController.text.trim(),
          'latitude': _pinnedLocation!.latitude,
          'longitude': _pinnedLocation!.longitude,
          'city': 'Ahmedabad',
          'state': 'Gujarat',
          'pincode': '380001',
          'status': 'ACTIVE',
        });

        VolteraSession().updateBusinessProfile(
          name: _businessNameController.text.trim(),
          phone: _phoneController.text.trim(),
          bEmail: _emailController.text.trim(),
          address: _addressController.text.trim(),
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Business profile and station location stored in database successfully!')),
        );
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile: $e'), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Edit Business Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontalPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Business Name', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                VolteraTextField(
                  controller: _businessNameController,
                  label: 'Business Name',
                  hint: 'Enter EV Charging Business Name',
                  validator: (v) => Validators.validateRequired(v, fieldName: 'Business name'),
                ),
                const SizedBox(height: 16),

                const Text('Business Phone Number', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: Validators.mobileInputFormatters,
                  validator: Validators.validateMobile,
                  decoration: const InputDecoration(
                    labelText: 'Business Phone Number',
                    hintText: '10-digit mobile number',
                  ),
                ),
                const SizedBox(height: 16),

                const Text('Business Email', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                VolteraTextField(
                  controller: _emailController,
                  label: 'Business Email',
                  hint: 'contact@business.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 16),

                const Text('Station Address / Location', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                VolteraTextField(
                  controller: _addressController,
                  label: 'Station Address',
                  hint: 'Enter full station address',
                  validator: (v) => Validators.validateRequired(v, fieldName: 'Station address'),
                ),
                const SizedBox(height: 16),
                
                const Text('Exact Map Location', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _pinnedLocation == null
                              ? 'Pin charger location on map'
                              : 'Lat: ${_pinnedLocation!.latitude.toStringAsFixed(4)}, Lng: ${_pinnedLocation!.longitude.toStringAsFixed(4)}',
                          style: TextStyle(
                            color: _pinnedLocation == null ? AppColors.textMuted : AppColors.textPrimary,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final LatLng? result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProviderMapPickerScreen(initialLocation: _pinnedLocation),
                            ),
                          );
                          if (result != null) {
                            setState(() {
                              _pinnedLocation = result;
                            });
                          }
                        },
                        icon: const Icon(Icons.map, color: AppColors.primaryDarkGreen),
                        label: Text(_pinnedLocation == null ? 'Set Pin' : 'Change', style: const TextStyle(color: AppColors.primaryDarkGreen)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),

                SizedBox(
                  width: double.infinity,
                  child: VolteraButton(
                    text: _isSaving ? 'Saving to Database...' : 'Save Business Profile',
                    onPressed: _isSaving ? () {} : _onSaveBusinessProfile,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
