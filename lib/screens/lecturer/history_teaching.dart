import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../models/attendance_model.dart';
import '../../models/user_model.dart';
import '../../services/database_service.dart';
import '../../widgets/stat_card.dart';

class HistoryTeachingPage extends StatefulWidget {
  final UserModel user;
  const HistoryTeachingPage({super.key, required this.user});

  @override
  State<HistoryTeachingPage> createState() => _HistoryTeachingPageState();
}

class _HistoryTeachingPageState extends State<HistoryTeachingPage> {
  final DatabaseService _dbService = DatabaseService();

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.riwayatMengajar),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<List<AttendanceModel>>(
        stream: _dbService.getLecturerAttendanceStream(widget.user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final records = snapshot.data ?? [];
          if (records.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada riwayat mengajar',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          final Map<String, List<AttendanceModel>> grouped = {};
          for (var r in records) {
            final key =
                '${r.courseId}_${DateFormat('yyyy-MM-dd').format(r.date)}';
            if (!grouped.containsKey(key)) {
              grouped[key] = [];
            }
            grouped[key]!.add(r);
          }

          final sessionKeys = grouped.keys.toList();

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSizes.pagePadding),
              itemCount: sessionKeys.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: AppSizes.sm),
              itemBuilder: (ctx, i) {
                final sessionRecords = grouped[sessionKeys[i]]!;
                final first = sessionRecords.first;

                int hadir = sessionRecords
                    .where((r) => r.status == AttendanceStatus.hadir)
                    .length;
                int izin = sessionRecords
                    .where((r) => r.status == AttendanceStatus.izin)
                    .length;
                int sakit = sessionRecords
                    .where((r) => r.status == AttendanceStatus.sakit)
                    .length;
                int alfa = sessionRecords
                    .where((r) => r.status == AttendanceStatus.alfa)
                    .length;

                return _TeachingSessionCard(
                  courseName: first.courseName,
                  date: DateFormat('dd MMMM yyyy', 'id_ID').format(first.date),
                  meeting: first.meetingNumber,
                  room: first.room,
                  hadir: hadir,
                  izin: izin,
                  sakit: sakit,
                  alfa: alfa,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _TeachingSessionCard extends StatelessWidget {
  final String courseName;
  final String date;
  final int meeting;
  final String room;
  final int hadir;
  final int izin;
  final int sakit;
  final int alfa;

  const _TeachingSessionCard({
    required this.courseName,
    required this.date,
    required this.meeting,
    required this.room,
    required this.hadir,
    required this.izin,
    required this.sakit,
    required this.alfa,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Center(
                  child: Text(
                    '$meeting',
                    style: const TextStyle(
                      fontSize: AppSizes.fontMd,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      courseName,
                      style: const TextStyle(
                        fontSize: AppSizes.fontMd,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: AppSizes.fontSm,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (room.isNotEmpty)
                      Text(
                        room,
                        style: const TextStyle(
                          fontSize: AppSizes.fontXs,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          StatCardRow(hadir: hadir, izin: izin, sakit: sakit, alfa: alfa),
        ],
      ),
    );
  }
}
