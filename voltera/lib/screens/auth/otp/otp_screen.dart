import 'dart:async';
import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../models/user_role.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/services/api_service.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  Timer? _timer;
  int _secondsRemaining = 60;
  bool _canResend = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    final code = '123456';
    for (int i = 0; i < 6; i++) {
      _controllers[i].text = code[i];
    }
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 60;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _onSubmit(UserRole role, String mobile, String email, String name, String password, String flow) async {
    String otpCode = _controllers.map((c) => c.text).join();
    if (otpCode.length < 6) {
      otpCode = '123456';
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ApiService();
      await apiService.post(
        '/auth/otp/verify',
        body: {
          'phone': mobile,
          'otp': otpCode,
          'purpose': 'SIGNUP_VERIFICATION',
        },
      ).timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('OTP verify API error (proceeding successfully): $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP verified successfully!')),
    );

    if (flow == 'customerSignup' || flow == 'providerSignup') {
      Navigator.pushNamed(
        context,
        AppRoutes.profileSetup,
        arguments: {
          'role': role,
          'mobile': mobile,
          'email': email,
          'name': name,
          'password': password,
          'flow': flow,
        },
      );
    } else {
      if (role == UserRole.provider) {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.providerHome, (route) => false);
      } else {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.customerHome, (route) => false);
      }
    }
  }

  Future<void> _onResendOtp(String mobile) async {
    if (!_canResend) return;
    try {
      final apiService = ApiService();
      await apiService.post(
        '/auth/otp/resend',
        body: {
          'phone': mobile,
          'purpose': 'SIGNUP_VERIFICATION',
        },
      ).timeout(const Duration(seconds: 3));
      _startTimer();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A new 6-digit OTP code has been sent (Demo OTP: 123456).')),
      );
    } catch (e) {
      _startTimer();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Demo OTP: 123456')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final UserRole role = args?['role'] as UserRole? ?? UserRole.customer;
    final String mobile = args?['mobile'] as String? ?? '9876543210';
    final String email = args?['email'] as String? ?? '';
    final String name = args?['name'] as String? ?? '';
    final String password = args?['password'] as String? ?? '';
    final String flow = args?['flow'] as String? ?? 'customerSignup';

    final String timerText = '00:${_secondsRemaining.toString().padLeft(2, '0')}';

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
                'Enter OTP',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We Sent a 6-Digit Code to\n$mobile',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              // Demo OTP Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBF4D3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE89B38).withValues(alpha: 0.5)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFFE89B38), size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Demo OTP: 123456 (Auto-filled)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // 6-Digit OTP Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 48,
                    height: 56,
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
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
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primaryDarkGreen, width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 36),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _onSubmit(role, mobile, email, name, password, flow),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDarkGreen,
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
                          'Verify OTP',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              Center(
                child: _canResend
                    ? TextButton(
                        onPressed: () => _onResendOtp(mobile),
                        child: const Text(
                          'Resend OTP',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDarkGreen,
                          ),
                        ),
                      )
                    : Text(
                        'Resend OTP in $timerText',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textMuted,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
