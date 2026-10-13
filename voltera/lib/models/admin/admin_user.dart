import '../user_role.dart';

class AdminUser {
  final String id;
  final String email;
  final UserRole role;
  final List<UserRole> roles;
  final bool isActive;
  final DateTime createdAt;

  const AdminUser({
    required this.id,
    required this.email,
    required this.role,
    required this.roles,
    required this.isActive,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'role': role.name,
        'roles': roles.map((r) => r.name).toList(),
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    final rawRoles = json['roles'] as List? ?? [];
    List<UserRole> parsedRoles = rawRoles.map((r) {
      final roleName = r is Map ? (r['role'] ?? 'customer').toString().toLowerCase() : r.toString().toLowerCase();
      return UserRole.values.firstWhere((e) => e.name == roleName, orElse: () => UserRole.customer);
    }).toList();

    if (parsedRoles.isEmpty) {
      parsedRoles = [UserRole.customer];
    }

    return AdminUser(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? json['phoneNumber'] as String? ?? '',
      role: parsedRoles.first,
      roles: parsedRoles,
      isActive: json['isActive'] ?? (json['accountStatus'] == 'ACTIVE'),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}
