import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../models/user_model.dart';
import '../../services/database_service.dart';

class NotificationSettingsPage extends StatefulWidget {
  final UserModel user;

  const NotificationSettingsPage({super.key, required this.user});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  late bool _notificationsEnabled;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _notificationsEnabled = widget.user.notificationsEnabled;
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await DatabaseService().updateNotificationPreference(widget.user.uid, value);
      setState(() {
        _notificationsEnabled = value;
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value ? 'Notifikasi diaktifkan' : 'Notifikasi dimatikan',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: value ? AppColors.success : AppColors.statusAlfa,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memperbarui pengaturan')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pengaturan Notifikasi'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kelola Notifikasi',
              style: TextStyle(
                fontSize: AppSizes.fontLg,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSizes.xs),
            const Text(
              'Atur bagaimana Anda menerima pemberitahuan dari aplikasi Hadyr.',
              style: TextStyle(
                fontSize: AppSizes.fontSm,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _NotificationTile(
                    title: 'Notifikasi Push',
                    subtitle: 'Dapatkan pemberitahuan langsung di perangkat Anda',
                    icon: Icons.notifications_active_outlined,
                    value: _notificationsEnabled,
                    onChanged: _isLoading ? null : _toggleNotifications,
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  _NotificationTile(
                    title: 'Jadwal Kuliah',
                    subtitle: 'Pengingat sebelum perkuliahan dimulai',
                    icon: Icons.calendar_today_outlined,
                    value: _notificationsEnabled,
                    onChanged: _isLoading ? null : (val) {},
                    enabled: _notificationsEnabled,
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  _NotificationTile(
                    title: 'Pengumuman Penting',
                    subtitle: 'Informasi terbaru dari prodi atau fakultas',
                    icon: Icons.campaign_outlined,
                    value: _notificationsEnabled,
                    onChanged: _isLoading ? null : (val) {},
                    enabled: _notificationsEnabled,
                  ),
                ],
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: AppSizes.lg),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final Function(bool)? onChanged;
  final bool enabled;

  const _NotificationTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.xs,
      ),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primaryLight : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? AppColors.primary : AppColors.textHint,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: AppSizes.fontMd,
          fontWeight: FontWeight.w600,
          color: enabled ? AppColors.textPrimary : AppColors.textHint,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: AppSizes.fontXs,
          color: enabled ? AppColors.textSecondary : AppColors.textHint,
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
        activeTrackColor: AppColors.primary.withAlpha(128),
      ),
    );
  }
}
