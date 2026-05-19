import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../widgets/user_avatar.dart';
import 'edit_profile_page.dart';
import 'notification_settings_page.dart';
import 'change_password_page.dart';
import 'help_page.dart';

class ProfilePage extends StatelessWidget {
  final UserModel user;

  const ProfilePage({super.key, required this.user});

  void _goToEditProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditProfilePage(user: user)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel>(
      stream: DatabaseService().getUserStream(user.uid),
      initialData: user,
      builder: (context, snapshot) {
        final currentUser = snapshot.data ?? user;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text(AppStrings.profile),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _goToEditProfile(context),
                tooltip: 'Edit Profil',
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.pagePadding),
            child: Column(
              children: [
                // ── Header Card ──────────────────────────────────
                _ProfileHeaderCard(user: currentUser),
                const SizedBox(height: AppSizes.md),

                // ── Info Card ────────────────────────────────────
                _InfoCard(user: currentUser),
                const SizedBox(height: AppSizes.md),

                // ── Stats Row (for student) ───────────────────────
                if (currentUser.isStudent) ...[
                  _StudentStatsCard(),
                  const SizedBox(height: AppSizes.md),
                ],

                // ── Menu List ────────────────────────────────────
                _MenuCard(
                  user: currentUser,
                  onEditTap: () => _goToEditProfile(context),
                ),
                const SizedBox(height: AppSizes.md),

                // ── Logout Button ────────────────────────────────
                _LogoutButton(context: context),
                const SizedBox(height: AppSizes.xs),

                // ── Delete Account Button ────────────────────────
                _DeleteAccountButton(context: context),
                const SizedBox(height: AppSizes.lg),
              ],
            ),
          ),
        );
      },
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
          UserAvatar(
            user: user,
            size: AppSizes.avatarXl,
            iconSize: 44,
            color: Colors.white.withAlpha(51),
            iconColor: Colors.white,
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
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
      {'icon': Icons.email_outlined, 'label': 'Email', 'value': user.email},
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
                padding: const EdgeInsets.symmetric(vertical: AppSizes.sm + 2),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        size: 18,
                        color: AppColors.primary,
                      ),
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
                              color: AppColors.textSecondary,
                            ),
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
        'icon': Icons.check_circle_outlined,
      },
      {
        'label': 'Semester',
        'value': '5',
        'icon': Icons.calendar_today_outlined,
      },
    ];

    return _SectionCard(
      title: 'Ringkasan Studi',
      child: Row(
        children: stats.map((s) {
          return Expanded(
            child: Column(
              children: [
                Icon(s['icon'] as IconData, color: AppColors.primary, size: 22),
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
  final VoidCallback onEditTap;

  const _MenuCard({required this.user, required this.onEditTap});

  @override
  Widget build(BuildContext context) {
    final menus = <Map<String, dynamic>>[
      {
        'icon': Icons.edit_outlined,
        'label': AppStrings.editProfile,
        'onTap': onEditTap,
      },
      {
        'icon': Icons.notifications_outlined,
        'label': 'Notifikasi',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NotificationSettingsPage(user: user),
            ),
          );
        },
      },
      {
        'icon': Icons.lock_outline,
        'label': 'Ubah Password',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
          );
        },
      },
      {
        'icon': Icons.help_outline,
        'label': 'Bantuan',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HelpPage()),
          );
        },
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
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Icon(
                    m['icon'] as IconData,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
                title: Text(
                  m['label'] as String,
                  style: const TextStyle(
                    fontSize: AppSizes.fontMd,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.textHint,
                  size: 20,
                ),
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
                'Apakah kamu yakin ingin keluar dari akun ini?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text(
                    'Keluar',
                    style: TextStyle(color: AppColors.statusAlfa),
                  ),
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

// ── Delete Account Button ─────────────────────────────────────────
class _DeleteAccountButton extends StatelessWidget {
  final BuildContext context;
  const _DeleteAccountButton({required this.context});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        icon: const Icon(Icons.delete_forever_outlined, color: AppColors.error),
        label: const Text(
          'Hapus Akun',
          style: TextStyle(
            color: AppColors.error,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
        ),
        onPressed: () async {
          final deleted = await showDialog<bool>(
            context: context,
            barrierDismissible: false, // User must choose Cancel or enter password
            builder: (ctx) => const DeleteAccountDialog(),
          );

          if (deleted == true) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Akun Anda berhasil dihapus secara permanen.'),
                  backgroundColor: AppColors.success,
                ),
              );
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            }
          }
        },
      ),
    );
  }
}

// ── Delete Account Confirmation Dialog ───────────────────────────
class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({super.key});

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleDeleteAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthService().deleteAccount(_passwordController.text);
      if (mounted) {
        Navigator.pop(context, true); // Return true on success
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      title: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.error,
            size: 28,
          ),
          const SizedBox(width: AppSizes.sm),
          const Expanded(
            child: Text(
              'Hapus Akun?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppSizes.fontXl,
              ),
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tindakan ini permanen dan tidak dapat dibatalkan. Semua data profil, riwayat kehadiran, dan akun Anda akan dihapus secara permanen dari sistem.',
                style: TextStyle(
                  fontSize: AppSizes.fontSm,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSizes.md),
              const Text(
                'Konfirmasi Password',
                style: TextStyle(
                  fontSize: AppSizes.fontSm,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscureText,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: 'Masukkan password Anda',
                  hintStyle: const TextStyle(fontSize: AppSizes.fontMd),
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                    vertical: AppSizes.sm,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password wajib diisi';
                  }
                  return null;
                },
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: AppSizes.sm),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: AppSizes.fontSm,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context, false),
          child: const Text(
            'Batal',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleDeleteAccount,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.sm,
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Hapus',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }
}
