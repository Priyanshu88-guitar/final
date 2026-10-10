import 'package:flutter/material.dart';
import '../../models/user_role.dart';
import '../../core/theme/app_colors.dart';

class RoleSelector extends StatelessWidget {
  final UserRole selectedRole;
  final ValueChanged<UserRole> onRoleChanged;

  const RoleSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: UserRole.values.map((role) {
        if (role == UserRole.admin) return const SizedBox.shrink();
        final isSelected = selectedRole == role;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(role.name),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onRoleChanged(role);
                }
              },
              selectedColor: AppColors.primaryDarkGreen,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.white : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
