import '../user_role.dart';

class AdminUser {
  final String id;
  final String name;
  final String phone;
  final String email;
  final UserRole role;
  final List<UserRole> roles;
  final bool isActive;
  final DateTime createdAt;
  final String location;
  final int totalSessions;
  final double walletBalance;

  const AdminUser({
    required this.id,
    this.name = '',
    this.phone = '',
    required this.email,
    required this.role,
    required this.roles,
    required this.isActive,
    required this.createdAt,
    this.location = 'Ahmedabad, Gujarat',
    this.totalSessions = 0,
    this.walletBalance = 0.0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'role': role.name,
        'roles': roles.map((r) => r.name).toList(),
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
        'location': location,
        'totalSessions': totalSessions,
        'walletBalance': walletBalance,
      };

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    final rawRoles = json['roles'] as List? ?? [];
    List<UserRole> parsedRoles = rawRoles.map((r) {
      final roleName = r is Map ? (r['role'] ?? 'customer').toString().toLowerCase() : r.toString().toLowerCase();
      return UserRole.values.firstWhere((e) => e.name == roleName, orElse: () => UserRole.customer);
    }).toList();

    if (parsedRoles.isEmpty) {
      final singleRoleStr = (json['role'] ?? 'customer').toString().toLowerCase();
      final singleRole = UserRole.values.firstWhere((e) => e.name == singleRoleStr, orElse: () => UserRole.customer);
      parsedRoles = [singleRole];
    }

    return AdminUser(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? json['email']?.split('@')[0] ?? 'User',
      phone: json['phone'] as String? ?? json['phoneNumber'] as String? ?? '+91 98765 43210',
      email: json['email'] as String? ?? '',
      role: parsedRoles.first,
      roles: parsedRoles,
      isActive: json['isActive'] ?? (json['accountStatus'] == 'ACTIVE'),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      location: json['location'] as String? ?? 'Ahmedabad, Gujarat',
      totalSessions: json['totalSessions'] as int? ?? 12,
      walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 500.0,
    );
  }
}
