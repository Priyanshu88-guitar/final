enum UserRole {
  customer,
  provider,
  admin,
}

extension UserRoleExtension on UserRole {
  String get name {
    switch (this) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.provider:
        return 'Service Provider';
      case UserRole.admin:
        return 'Admin';
    }
  }

  String get routePrefix {
    switch (this) {
      case UserRole.customer:
        return '/customer';
      case UserRole.provider:
        return '/provider';
      case UserRole.admin:
        return '/admin';
    }
  }
}
