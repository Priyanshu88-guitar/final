import 'user_role.dart';

class AuthSession {
  final String userId;
  final String email;
  final UserRole role;
  final String token;
  final bool isProfileComplete;

  const AuthSession({
    required this.userId,
    required this.email,
    required this.role,
    required this.token,
    required this.isProfileComplete,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'email': email,
        'role': role.name,
        'token': token,
        'isProfileComplete': isProfileComplete,
      };

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      userId: json['userId'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.customer,
      ),
      token: json['token'] as String? ?? '',
      isProfileComplete: json['isProfileComplete'] as bool? ?? false,
    );
  }
}
