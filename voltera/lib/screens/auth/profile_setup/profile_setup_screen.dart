import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../app/session.dart';
import '../../../models/user_role.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../widgets/common/voltera_button.dart';
import '../../../widgets/common/voltera_text_field.dart';
import '../../../data/services/api_service.dart';
import '../../../data/repositories/auth_repository.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  String? _selectedGender;
  final List<String> _genders = ['Male', 'Female', 'Other'];
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      if (_nameController.text.isEmpty && args['name'] != null) {
        _nameController.text = args['name'].toString();
      }
      if (_emailController.text.isEmpty && args['email'] != null) {
        _emailController.text = args['email'].toString();
      }
    }
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1920, 1, 1),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primaryDarkGreen,
                  onPrimary: AppColors.white,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final String day = picked.day.toString().padLeft(2, '0');
      final String month = picked.month.toString().padLeft(2, '0');
      final String year = picked.year.toString();
      setState(() {
        _dobController.text = '$day/$month/$year';
      });
    }
  }

  Future<void> _onCompleteProfile(UserRole role, String mobile, String email, String name, String password, String flow) async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final finalName = _nameController.text.trim().isEmpty ? (name.isEmpty ? 'User' : name) : _nameController.text.trim();
      final finalEmail = _emailController.text.trim().isEmpty ? (email.isEmpty ? 'customer@voltera.com' : email) : _emailController.text.trim();
      final finalPassword = password.isEmpty ? 'Voltera@123' : password;

      try {
        final authRepo = AuthRepositoryImpl(apiService: ApiService());
        await authRepo.signup(
          finalEmail,
          finalPassword,
          role,
          phone: mobile,
          name: finalName,
        );
      } catch (e) {
        debugPrint('Backend signup creation error: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }

      VolteraSession().login(userRole: role, mobile: mobile);
      VolteraSession().updateProfile(
        name: finalName,
        userEmail: finalEmail,
      );

      if (!mounted) return;
      if (role == UserRole.provider || flow == 'providerSignup') {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.providerHome, (route) => false);
      } else {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.customerHome, (route) => false);
      }
    }
  }

  Future<void> _onSkip(UserRole role, String mobile, String email, String name, String password, String flow) async {
    setState(() {
      _isLoading = true;
    });

    final finalName = name.isEmpty ? 'User' : name;
    final finalEmail = email.isEmpty ? 'customer@voltera.com' : email;
    final finalPassword = password.isEmpty ? 'Voltera@123' : password;

    try {
      final authRepo = AuthRepositoryImpl(apiService: ApiService());
      await authRepo.signup(
        finalEmail,
        finalPassword,
        role,
        phone: mobile,
        name: finalName,
      );
    } catch (e) {
      debugPrint('Skip signup API error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }

    VolteraSession().login(userRole: role, mobile: mobile);
    VolteraSession().updateProfile(name: finalName, userEmail: finalEmail);

    if (!mounted) return;
    if (role == UserRole.provider || flow == 'providerSignup') {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.providerHome, (route) => false);
    } else {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.customerHome, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final UserRole role = args?['role'] as UserRole? ?? UserRole.customer;
    final String mobile = args?['mobile'] as String? ?? '';
    final String email = args?['email'] as String? ?? '';
    final String name = args?['name'] as String? ?? '';
    final String password = args?['password'] as String? ?? '';
    final String flow = args?['flow'] as String? ?? 'customerSignup';

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Complete Profile'),
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Avatar Circle
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.lightGreen, AppColors.primaryDarkGreen],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.camera_alt,
                      color: AppColors.white,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Full Name',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      VolteraTextField(
                        controller: _nameController,
                        label: 'Enter Your Full name',
                        hint: 'Enter Your Full name',
                        validator: Validators.validateName,
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'Email',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      VolteraTextField(
                        controller: _emailController,
                        label: 'Enter Your Email Address',
                        hint: 'Enter Your Email Address',
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.validateEmail,
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'Date Of Birth',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _selectDateOfBirth,
                        child: AbsorbPointer(
                          child: VolteraTextField(
                            controller: _dobController,
                            label: 'DD / MM / YYYY',
                            hint: 'DD / MM / YYYY',
                            suffixIcon: const Icon(Icons.calendar_today, size: 20),
                            validator: (v) => Validators.validateRequired(v, fieldName: 'Date of birth'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'Gender',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedGender,
                        decoration: InputDecoration(
                          hintText: 'Select Your Gender',
                          filled: true,
                          fillColor: AppColors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                        ),
                        items: _genders.map((gender) {
                          return DropdownMenuItem(
                            value: gender,
                            child: Text(gender),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedGender = val;
                          });
                        },
                        validator: (v) => v == null ? 'Please select your gender' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                VolteraButton(
                  text: 'Complete Signup',
                  isLoading: _isLoading,
                  onPressed: () => _onCompleteProfile(role, mobile, email, name, password, flow),
                ),
                const SizedBox(height: 16),

                TextButton(
                  onPressed: _isLoading ? null : () => _onSkip(role, mobile, email, name, password, flow),
                  child: const Text(
                    'Skip For Now',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
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
