import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';
import '../models/attendance_model.dart';

class AttendanceTile extends StatelessWidget {
  final String name;
  final String subtitle;
  final AttendanceStatus? status;
  final String? trailing;
  final VoidCallback? onTap;
  final Widget? leadingWidget;

  const AttendanceTile({
    super.key,
    required this.name,
    this.subtitle = '',
    this.status,
    this.trailing,
    this.onTap,
    this.leadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm + 4,
        ),
        child: Row(
          children: [
            if (leadingWidget != null) ...[
              leadingWidget!,
              const SizedBox(width: AppSizes.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: AppSizes.fontMd,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: AppSizes.fontSm,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (status != null) ...[
              const SizedBox(width: AppSizes.sm),
              _StatusBadge(status: status!),
            ],
            if (trailing != null && status == null) ...[
              const SizedBox(width: AppSizes.sm),
              Text(
                trailing!,
                style: const TextStyle(
                  fontSize: AppSizes.fontSm,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final AttendanceStatus status;

  const _StatusBadge({required this.status});

  Color get _bgColor {
    switch (status) {
      case AttendanceStatus.hadir:
        return AppColors.statusHadirBg;
      case AttendanceStatus.izin:
        return AppColors.statusIzinBg;
      case AttendanceStatus.sakit:
        return AppColors.statusSakitBg;
      case AttendanceStatus.alfa:
        return AppColors.statusAlfaBg;
      case AttendanceStatus.terlambat:
        return AppColors.statusTerlambatBg;
    }
  }

  Color get _textColor {
    switch (status) {
      case AttendanceStatus.hadir:
        return AppColors.statusHadir;
      case AttendanceStatus.izin:
        return AppColors.statusIzin;
      case AttendanceStatus.sakit:
        return AppColors.statusSakit;
      case AttendanceStatus.alfa:
        return AppColors.statusAlfa;
      case AttendanceStatus.terlambat:
        return AppColors.statusTerlambat;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: AppSizes.fontXs,
          fontWeight: FontWeight.w600,
          color: _textColor,
        ),
      ),
    );
  }
}

/// Status badge standalone
class StatusBadge extends StatelessWidget {
  final AttendanceStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) => _StatusBadge(status: status);
}
