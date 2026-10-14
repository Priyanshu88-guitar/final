import 'package:flutter/foundation.dart';
import '../../app/session.dart';
import '../../models/auth_session.dart';
import '../../models/user_role.dart';
import '../services/api_service.dart';
import '../../core/demo/demo_config.dart';
import '../../core/demo/demo_data.dart';

abstract class AuthRepository {
  Future<AuthSession?> login(String identifier, String password, UserRole role);
  Future<AuthSession?> signup(String email, String password, UserRole role, {String? phone, String? name, String? businessName, String? address, String? city, String? state, String? pincode, String? taxId});
  Future<void> logout();
  Future<AuthSession?> getCurrentSession();
  Future<List<UserRole>> registerRole(UserRole role);
}

class AuthRepositoryImpl implements AuthRepository {
  final ApiService apiService;

  const AuthRepositoryImpl({required this.apiService});

  @override
  Future<AuthSession?> login(String identifier, String password, UserRole role) async {
    if (DemoConfig.demoMode) {
      final demoAcc = DemoData.demoAccounts.firstWhere(
        (acc) => acc.role == role,
        orElse: () => DemoData.demoAccounts.first,
      );
      return AuthSession(
        userId: 'demo-user-${demoAcc.role.name}',
        email: demoAcc.email,
        role: demoAcc.role,
        token: 'demo-token-${demoAcc.role.name}',
        isProfileComplete: true,
      );
    }

    try {
      final response = await apiService.post(
        '/auth/login',
        body: {
          'phone': identifier,
          'password': password,
        },
      ).timeout(const Duration(seconds: 4));

      final data = response['data'];
      if (data != null && data is Map<String, dynamic>) {
        final token = data['accessToken'] as String? ?? '';
        final user = data['user'] as Map<String, dynamic>? ?? {};
        apiService.setAuthToken(token);

        final rolesList = (user['roles'] as List<dynamic>? ?? ['CUSTOMER'])
            .map((r) => UserRole.values.firstWhere(
                  (e) => e.name.toUpperCase() == r.toString().toUpperCase(),
                  orElse: () => UserRole.customer,
                ))
            .toList();

        final session = VolteraSession();
        session.isAuthenticated = true;
        session.userId = user['id'] as String?;
        session.fullName = user['fullName'] as String?;
        session.email = user['email'] as String?;
        session.mobileNumber = user['phoneNumber'] as String?;
        session.availableRoles = rolesList;
        session.activeRole = role;

        return AuthSession(
          userId: user['id'] as String? ?? '',
          email: user['email'] as String? ?? identifier,
          role: role,
          token: token,
          isProfileComplete: user['profileStatus'] == 'COMPLETE',
        );
      }
      return null;
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<AuthSession?> signup(
    String email,
    String password,
    UserRole role, {
    String? phone,
    String? name,
    String? businessName,
    String? address,
    String? city,
    String? state,
    String? pincode,
    String? taxId,
  }) async {
    DemoData.registerUser(
      name: name ?? '',
      email: email,
      phone: phone ?? '',
      role: role,
      businessName: businessName,
      city: city,
      address: address,
    );

    if (DemoConfig.demoMode) {
      return AuthSession(
        userId: 'demo-signup-user',
        email: email.isEmpty ? 'rahul@voltera.demo' : email,
        role: role,
        token: 'demo-signup-token',
        isProfileComplete: false,
      );
    }

    try {
      final Map<String, dynamic> bodyData = {
        'email': email,
        'password': password,
        'phone': phone ?? '+919876543210',
        'fullName': name ?? 'New User',
        'role': role.name.toUpperCase(),
      };
      
      if (businessName != null) bodyData['businessName'] = businessName;
      if (address != null) bodyData['address'] = address;
      if (city != null) bodyData['city'] = city;
      if (state != null) bodyData['state'] = state;
      if (pincode != null) bodyData['pincode'] = pincode;
      if (taxId != null) bodyData['taxId'] = taxId;

      debugPrint('SENDING SIGNUP PAYLOAD: $bodyData');

      final response = await apiService.post(
        '/auth/signup',
        body: bodyData,
      ).timeout(const Duration(seconds: 4));

      final data = response['data'];
      if (data != null && data is Map<String, dynamic>) {
        final userId = data['userId'] as String? ?? '';
        return AuthSession(
          userId: userId,
          email: email,
          role: role,
          token: '',
          isProfileComplete: false,
        );
      }
      return AuthSession(
        userId: 'user-${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        role: role,
        token: 'local-token',
        isProfileComplete: false,
      );
    } catch (e) {
      debugPrint('Signup request note ($e): Proceeding with registration setup.');
      return AuthSession(
        userId: 'user-${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        role: role,
        token: 'local-token',
        isProfileComplete: false,
      );
    }
  }

  @override
  Future<void> logout() async {
    if (DemoConfig.demoMode) {
      return;
    }

    try {
      await apiService.post('/auth/logout').timeout(const Duration(seconds: 3));
    } catch (_) {
      // Ignore logout errors
    } finally {
      apiService.setAuthToken(null);
    }
  }

  @override
  Future<AuthSession?> getCurrentSession() async {
    if (DemoConfig.demoMode) {
      return null;
    }

    try {
      if (apiService.authToken == null) return null;
      final response = await apiService.get('/auth/me').timeout(const Duration(seconds: 3));
      final data = response['data'];
      if (data != null && data is Map<String, dynamic>) {
        final user = data['user'] as Map<String, dynamic>? ?? {};
        final activeRoleStr = (data['activeRole'] as String? ?? 'CUSTOMER').toLowerCase();
        final role = UserRole.values.firstWhere(
          (e) => e.name == activeRoleStr,
          orElse: () => UserRole.customer,
        );

        final rolesList = (user['roles'] as List<dynamic>? ?? ['CUSTOMER'])
            .map((r) => UserRole.values.firstWhere(
                  (e) => e.name.toUpperCase() == r.toString().toUpperCase(),
                  orElse: () => UserRole.customer,
                ))
            .toList();

        final session = VolteraSession();
        session.isAuthenticated = true;
        session.userId = user['id'] as String?;
        session.fullName = user['fullName'] as String?;
        session.email = user['email'] as String?;
        session.mobileNumber = user['phoneNumber'] as String?;
        session.availableRoles = rolesList;
        session.activeRole = role;

        return AuthSession(
          userId: user['id'] as String? ?? '',
          email: user['email'] as String? ?? '',
          role: role,
          token: apiService.authToken ?? '',
          isProfileComplete: user['profileStatus'] == 'COMPLETE',
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<UserRole>> registerRole(UserRole role) async {
    if (DemoConfig.demoMode) {
      return [UserRole.customer, UserRole.provider];
    }
    try {
      final response = await apiService.post(
        '/auth/register-role',
        body: {'role': role.name.toUpperCase()},
      ).timeout(const Duration(seconds: 5));

      final data = response['data'];
      if (data != null && data is Map<String, dynamic>) {
        final token = data['tokens']?['accessToken'] as String?;
        if (token != null) {
          apiService.setAuthToken(token);
        }
        final user = data['user'] as Map<String, dynamic>? ?? {};
        final rolesList = (user['roles'] as List<dynamic>? ?? ['CUSTOMER'])
            .map((r) => UserRole.values.firstWhere(
                  (e) => e.name.toUpperCase() == r.toString().toUpperCase(),
                  orElse: () => UserRole.customer,
                ))
            .toList();

        final session = VolteraSession();
        session.availableRoles = rolesList;

        return rolesList;
      }
      return [UserRole.customer];
    } catch (_) {
      rethrow;
    }
  }
}
