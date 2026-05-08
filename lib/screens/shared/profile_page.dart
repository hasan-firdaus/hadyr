import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';

class ProfilePage extends StatelessWidget {
  final UserModel user;

  const ProfilePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.profile),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {},
            tooltip: 'Edit Profil',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.pagePadding),
        child: Column(
          children: [
            // ── Header Card ──────────────────────────────────
            _ProfileHeaderCard(user: user),
            const SizedBox(height: AppSizes.md),

            // ── Info Card ────────────────────────────────────
            _InfoCard(user: user),
            const SizedBox(height: AppSizes.md),

            // ── Stats Row (for student) ───────────────────────
            if (user.isStudent) ...[
              _StudentStatsCard(),
              const SizedBox(height: AppSizes.md),
            ],

            // ── Menu List ────────────────────────────────────
            _MenuCard(user: user),
            const SizedBox(height: AppSizes.md),

            // ── Logout Button ────────────────────────────────
            _LogoutButton(context: context),
            const SizedBox(height: AppSizes.lg),
          ],
        ),
      ),
    );
  }
}

// ── Profile Header Card ─────────────────────────────────────────
class _ProfileHeaderCard extends StatelessWidget {
  final UserModel user;
  const _ProfileHeaderCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF3D8EFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: AppSizes.avatarXl,
            height: AppSizes.avatarXl,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(51),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: user.photoUrl != null
                ? ClipOval(
                    child: Image.network(user.photoUrl!, fit: BoxFit.cover))
                : const Icon(Icons.person_rounded,
                    size: 44, color: Colors.white),
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            user.name,
            style: const TextStyle(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            user.isLecturer
                ? (user.nidn != null ? 'NIDN: ${user.nidn}' : '')
                : (user.nim != null ? 'NIM: ${user.nim}' : ''),
            style: TextStyle(
              fontSize: AppSizes.fontSm,
              color: Colors.white.withAlpha(204),
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          // Role Badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(51),
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            ),
            child: Text(
              user.isLecturer ? 'Dosen' : 'Mahasiswa',
              style: const TextStyle(
                fontSize: AppSizes.fontSm,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info Card ───────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final UserModel user;
  const _InfoCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final items = <Map<String, dynamic>>[
      {
        'icon': Icons.email_outlined,
        'label': 'Email',
        'value': user.email,
      },
      if (user.prodi != null)
        {
          'icon': Icons.school_outlined,
          'label': 'Program Studi',
          'value': user.prodi!,
        },
      if (user.fakultas != null)
        {
          'icon': Icons.account_balance_outlined,
          'label': 'Fakultas',
          'value': user.fakultas!,
        },
      if (user.jabatan != null)
        {
          'icon': Icons.badge_outlined,
          'label': 'Jabatan',
          'value': user.jabatan!,
        },
    ];

    return _SectionCard(
      title: 'Informasi Akun',
      child: Column(
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.sm + 2),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusSm),
                      ),
                      child: Icon(item['icon'] as IconData,
                          size: 18, color: AppColors.primary),
                    ),
                    const SizedBox(width: AppSizes.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['label'] as String,
                            style: const TextStyle(
                                fontSize: AppSizes.fontXs,
                                color: AppColors.textSecondary),
                          ),
                          Text(
                            item['value'] as String,
                            style: const TextStyle(
                              fontSize: AppSizes.fontMd,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ── Student Stats Card ─────────────────────────────────────────
class _StudentStatsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stats = [
      {'label': 'Total Kelas', 'value': '8', 'icon': Icons.class_outlined},
      {
        'label': 'Kehadiran',
        'value': '87%',
        'icon': Icons.check_circle_outlined
      },
      {'label': 'Semester', 'value': '5', 'icon': Icons.calendar_today_outlined},
    ];

    return _SectionCard(
      title: 'Ringkasan Studi',
      child: Row(
        children: stats.map((s) {
          return Expanded(
            child: Column(
              children: [
                Icon(s['icon'] as IconData,
                    color: AppColors.primary, size: 22),
                const SizedBox(height: 6),
                Text(
                  s['value'] as String,
                  style: const TextStyle(
                    fontSize: AppSizes.fontXl,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  s['label'] as String,
                  style: const TextStyle(
                    fontSize: AppSizes.fontXs,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Menu Card ───────────────────────────────────────────────────
class _MenuCard extends StatelessWidget {
  final UserModel user;
  const _MenuCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final menus = <Map<String, dynamic>>[
      {
        'icon': Icons.edit_outlined,
        'label': AppStrings.editProfile,
        'onTap': () {},
      },
      {
        'icon': Icons.notifications_outlined,
        'label': 'Notifikasi',
        'onTap': () {},
      },
      {
        'icon': Icons.lock_outline,
        'label': 'Ubah Password',
        'onTap': () {},
      },
      {
        'icon': Icons.help_outline,
        'label': 'Bantuan',
        'onTap': () {},
      },
    ];

    return _SectionCard(
      title: 'Menu',
      child: Column(
        children: menus.map((m) {
          return Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Icon(m['icon'] as IconData,
                      size: 18, color: AppColors.textSecondary),
                ),
                title: Text(
                  m['label'] as String,
                  style: const TextStyle(
                    fontSize: AppSizes.fontMd,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right,
                    color: AppColors.textHint, size: 20),
                onTap: m['onTap'] as VoidCallback,
              ),
              if (m != menus.last)
                const Divider(height: 1, color: AppColors.divider),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ── Logout Button ───────────────────────────────────────────────
class _LogoutButton extends StatelessWidget {
  final BuildContext context;
  const _LogoutButton({required this.context});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.logout, color: AppColors.statusAlfa),
        label: const Text(
          AppStrings.logout,
          style: TextStyle(color: AppColors.statusAlfa),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.statusAlfa),
        ),
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              ),
              title: const Text('Keluar?'),
              content: const Text(
                  'Apakah kamu yakin ingin keluar dari akun ini?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Keluar',
                      style: TextStyle(color: AppColors.statusAlfa)),
                ),
              ],
            ),
          );
          if (confirm == true) {
            await AuthService().logout();
            if (context.mounted) {
              Navigator.of(context).pushReplacementNamed('/login');
            }
          }
        },
      ),
    );
  }
}

// ── Helper Section Card ─────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          child,
        ],
      ),
    );
  }
}
