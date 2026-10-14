import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../models/user_role.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../data/services/api_service.dart';
import '../../../data/repositories/auth_repository.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Provider extra controllers
  final _businessNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _taxIdController = TextEditingController();
  
  UserRole _selectedRole = UserRole.customer;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _businessNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _taxIdController.dispose();
    super.dispose();
  }

  Future<void> _onGenerateOtpPressed() async {
    final String phone = _mobileController.text.trim();
    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter mobile number'), backgroundColor: Colors.red),
      );
      return;
    }

    if (password.length < 8 || !password.contains(RegExp(r'[A-Za-z]')) || !password.contains(RegExp(r'[0-9]'))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 8 chars long with a letter and a number'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_selectedRole == UserRole.provider) {
      if (_businessNameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter Business Name'), backgroundColor: Colors.red),
        );
        return;
      }
      if (_addressController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter Business Address'), backgroundColor: Colors.red),
        );
        return;
      }
      if (_cityController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter City'), backgroundColor: Colors.red),
        );
        return;
      }
      if (_pincodeController.text.trim().length != 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid 6-digit Pincode'), backgroundColor: Colors.red),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authRepo = AuthRepositoryImpl(apiService: ApiService());
      await authRepo.signup(
        email.isEmpty ? 'customer@voltera.com' : email,
        password.isEmpty ? 'Voltera@123' : password,
        _selectedRole,
        phone: phone,
        name: name.isEmpty ? 'User' : name,
        businessName: _selectedRole == UserRole.provider ? _businessNameController.text.trim() : null,
        address: _selectedRole == UserRole.provider ? _addressController.text.trim() : null,
        city: _selectedRole == UserRole.provider ? _cityController.text.trim() : null,
        state: _selectedRole == UserRole.provider ? _stateController.text.trim() : null,
        pincode: _selectedRole == UserRole.provider ? _pincodeController.text.trim() : null,
        taxId: _selectedRole == UserRole.provider ? _taxIdController.text.trim() : null,
      );
    } catch (e) {
      debugPrint('Signup request note ($e): Proceeding to OTP verification.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        final String flow = _selectedRole == UserRole.provider ? 'providerSignup' : 'customerSignup';
        Navigator.pushNamed(
          context,
          AppRoutes.otp,
          arguments: {
            'role': _selectedRole,
            'mobile': phone,
            'email': email,
            'name': name,
            'password': password,
            'flow': flow,
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
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
              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Join VOLTERA EV Charging Platform',
                style: TextStyle(fontSize: 14, color: AppColors.textMuted),
              ),
              const SizedBox(height: 24),

              // Role Selector
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFECC7).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedRole = UserRole.customer;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedRole == UserRole.customer
                                ? AppColors.primaryDarkGreen
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'Customer',
                              style: TextStyle(
                                color: _selectedRole == UserRole.customer
                                    ? AppColors.white
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedRole = UserRole.provider;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedRole == UserRole.provider
                                ? AppColors.primaryDarkGreen
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'Service Provider',
                              style: TextStyle(
                                color: _selectedRole == UserRole.provider
                                    ? AppColors.white
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text('Full Name', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: _selectedRole == UserRole.provider ? 'Enter your or representative name' : 'Enter full name', 
                  hintText: 'Rahul Sharma'
                ),
              ),
              const SizedBox(height: 16),

              if (_selectedRole == UserRole.provider) ...[
                const Text('Business Name', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _businessNameController,
                  decoration: const InputDecoration(labelText: 'Enter business name', hintText: 'VoltaCharge Station'),
                ),
                const SizedBox(height: 16),
                const Text('Business Address', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Enter complete address', hintText: 'SG Highway'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('City', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _cityController,
                            decoration: const InputDecoration(labelText: 'City', hintText: 'Ahmedabad'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('State', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _stateController,
                            decoration: const InputDecoration(labelText: 'State', hintText: 'Gujarat'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Pincode', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _pincodeController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Pincode', hintText: '380015'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tax ID / GSTIN', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _taxIdController,
                            decoration: const InputDecoration(labelText: 'Optional', hintText: '24DEMOTAX...'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              const Text('Email (Optional)', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Enter email', hintText: 'customer@voltera.com'),
              ),
              const SizedBox(height: 16),

              const Text('Mobile Number', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                inputFormatters: Validators.mobileInputFormatters,
                decoration: const InputDecoration(labelText: 'Enter 10-digit mobile number', hintText: '9876543212'),
              ),
              const SizedBox(height: 16),

              const Text('Password', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Create password', hintText: 'At least 8 chars with letters & numbers'),
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onGenerateOtpPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE89B38),
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Generate OTP',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
