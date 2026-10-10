import '../models/user_role.dart';

class VolteraSession {
  static final VolteraSession _instance = VolteraSession._internal();
  factory VolteraSession() => _instance;
  VolteraSession._internal();

  bool isAuthenticated = false;
  List<UserRole> availableRoles = [UserRole.customer];
  UserRole activeRole = UserRole.customer;
  String? userId;
  String? mobileNumber;
  String? fullName;
  String? email;

  // Business Profile
  String? businessName;
  String? businessPhone;
  String? businessEmail;
  String? businessAddress;

  UserRole get role => activeRole;

  bool hasRole(UserRole r) => availableRoles.contains(r);

  void login({
    required UserRole userRole,
    List<UserRole>? roles,
    String? mobile,
  }) {
    isAuthenticated = true;
    activeRole = userRole;
    availableRoles = roles ?? [userRole];
    mobileNumber = mobile;
  }

  void updateProfile({required String name, required String userEmail}) {
    fullName = name;
    email = userEmail;
  }

  void updateBusinessProfile({
    required String name,
    required String phone,
    required String bEmail,
    required String address,
  }) {
    businessName = name;
    businessPhone = phone;
    businessEmail = bEmail;
    businessAddress = address;
  }

  void enableDualRole() {
    if (!availableRoles.contains(UserRole.customer)) {
      availableRoles.add(UserRole.customer);
    }
    if (!availableRoles.contains(UserRole.provider)) {
      availableRoles.add(UserRole.provider);
    }
  }

  bool switchToRole(UserRole targetRole) {
    if (!isAuthenticated) return false;
    if (targetRole == UserRole.admin) return false;
    if (hasRole(targetRole)) {
      activeRole = targetRole;
      return true;
    }
    return false;
  }

  void logout() {
    isAuthenticated = false;
    availableRoles = [UserRole.customer];
    activeRole = UserRole.customer;
    userId = null;
    mobileNumber = null;
    fullName = null;
    email = null;
    businessName = null;
    businessPhone = null;
    businessEmail = null;
    businessAddress = null;
  }
}
