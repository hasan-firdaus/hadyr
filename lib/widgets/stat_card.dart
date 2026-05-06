import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';

class StatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final Color bgColor;

  const StatCard({
    super.key,
    required this.label,
    required this.count,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.sm,
          vertical: AppSizes.md,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: AppSizes.fontXxl,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: AppSizes.fontXs,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class StatCardRow extends StatelessWidget {
  final int hadir;
  final int izin;
  final int sakit;
  final int alfa;

  const StatCardRow({
    super.key,
    required this.hadir,
    required this.izin,
    required this.sakit,
    required this.alfa,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        StatCard(
          label: 'Hadir',
          count: hadir,
          color: AppColors.statusHadir,
          bgColor: AppColors.statusHadirBg,
        ),
        const SizedBox(width: AppSizes.sm),
        StatCard(
          label: 'Izin',
          count: izin,
          color: AppColors.statusIzin,
          bgColor: AppColors.statusIzinBg,
        ),
        const SizedBox(width: AppSizes.sm),
        StatCard(
          label: 'Sakit',
          count: sakit,
          color: AppColors.statusSakit,
          bgColor: AppColors.statusSakitBg,
        ),
        const SizedBox(width: AppSizes.sm),
        StatCard(
          label: 'Alfa',
          count: alfa,
          color: AppColors.statusAlfa,
          bgColor: AppColors.statusAlfaBg,
        ),
      ],
    );
  }
}
