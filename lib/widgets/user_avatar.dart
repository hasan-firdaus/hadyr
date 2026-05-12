import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/user_model.dart';

class UserAvatar extends StatelessWidget {
  final UserModel user;
  final double size;
  final double iconSize;
  final Color? color;
  final Color? iconColor;

  const UserAvatar({
    super.key,
    required this.user,
    this.size = 40,
    this.iconSize = 24,
    this.color,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    // Default icons based on role
    final IconData avatarIcon = user.isLecturer 
        ? Icons.supervisor_account_rounded 
        : Icons.school_rounded;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? AppColors.primaryLight,
        shape: BoxShape.circle,
        border: Border.all(
          color: iconColor ?? AppColors.primary, 
          width: size > 60 ? 3 : 2,
        ),
      ),
      child: Icon(
        avatarIcon,
        size: iconSize,
        color: iconColor ?? AppColors.primary,
      ),
    );
  }
}
