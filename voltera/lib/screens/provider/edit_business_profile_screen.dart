import 'package:flutter/material.dart';
import '../../app/session.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/utils/validators.dart';
import '../../widgets/common/voltera_button.dart';
import '../../widgets/common/voltera_text_field.dart';

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

  void _onSaveBusinessProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      VolteraSession().updateBusinessProfile(
        name: _businessNameController.text.trim(),
        phone: _phoneController.text.trim(),
        bEmail: _emailController.text.trim(),
        address: _addressController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Business profile updated successfully.')),
      );
      Navigator.pop(context);
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
                const SizedBox(height: 36),

                VolteraButton(
                  text: 'Save Changes',
                  onPressed: _onSaveBusinessProfile,
                ),
                const SizedBox(height: 12),

                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
