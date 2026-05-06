import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';

import '../../models/user_model.dart';
import '../../widgets/stat_card.dart';

class HistoryTeachingPage extends StatefulWidget {
  final UserModel user;
  const HistoryTeachingPage({super.key, required this.user});

  @override
  State<HistoryTeachingPage> createState() => _HistoryTeachingPageState();
}

class _HistoryTeachingPageState extends State<HistoryTeachingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _courses = [
    'Semua',
    'Pemrog. Web',
    'Basis Data',
    'Rekayasa Data',
  ];

  final List<_TeachingRecord> _records = [
    _TeachingRecord(
      courseName: 'Pemrograman Web Lanjut',
      date: '25 April 2026',
      time: '08:00 - 10:30',
      room: 'Ruang 201, Gedung A',
      hadir: 28,
      izin: 2,
      sakit: 1,
      alfa: 1,
      meeting: 12,
    ),
    _TeachingRecord(
      courseName: 'Basis Data Relasional',
      date: '24 April 2026',
      time: '13:00 - 15:30',
      room: 'Ruang 101, Gedung B',
      hadir: 30,
      izin: 1,
      sakit: 0,
      alfa: 1,
      meeting: 11,
    ),
    _TeachingRecord(
      courseName: 'Pemrograman Web Lanjut',
      date: '18 April 2026',
      time: '08:00 - 10:30',
      room: 'Ruang 201, Gedung A',
      hadir: 27,
      izin: 3,
      sakit: 1,
      alfa: 1,
      meeting: 11,
    ),
    _TeachingRecord(
      courseName: 'Rekayasa Data',
      date: '17 April 2026',
      time: '16:00 - 17:40',
      room: 'Lab Komputer 2, Gedung C',
      hadir: 25,
      izin: 2,
      sakit: 2,
      alfa: 3,
      meeting: 10,
    ),
    _TeachingRecord(
      courseName: 'Basis Data Relasional',
      date: '17 April 2026',
      time: '13:00 - 15:30',
      room: 'Ruang 101, Gedung B',
      hadir: 29,
      izin: 2,
      sakit: 0,
      alfa: 1,
      meeting: 10,
    ),
    _TeachingRecord(
      courseName: 'Rekayasa Data',
      date: '10 April 2026',
      time: '16:00 - 17:40',
      room: 'Lab Komputer 2, Gedung C',
      hadir: 26,
      izin: 1,
      sakit: 3,
      alfa: 2,
      meeting: 9,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _courses.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.riwayatMengajar),
        centerTitle: true,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: AppSizes.fontSm,
            ),
            tabs: _courses.map((c) => Tab(text: c)).toList(),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _courses.map((course) {
          final filtered = course == 'Semua'
              ? _records
              : _records
                  .where((r) => r.courseName.contains(
                      course.replaceAll('Prog.', 'gramasi Web').replaceAll('.', '')))
                  .toList();
          return _RecordList(records: filtered);
        }).toList(),
      ),
    );
  }
}

class _RecordList extends StatelessWidget {
  final List<_TeachingRecord> records;
  const _RecordList({required this.records});

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada riwayat mengajar',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSizes.pagePadding),
      itemCount: records.length,
      separatorBuilder: (ctx, i) => const SizedBox(height: AppSizes.sm),
      itemBuilder: (ctx, i) => _TeachingRecordCard(record: records[i]),
    );
  }
}

class _TeachingRecordCard extends StatelessWidget {
  final _TeachingRecord record;
  const _TeachingRecordCard({required this.record});

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
          // Header Row
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
                    '${record.meeting}',
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
                      record.courseName,
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
                      record.date,
                      style: const TextStyle(
                        fontSize: AppSizes.fontSm,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${record.time}  •  ${record.room}',
                      style: const TextStyle(
                        fontSize: AppSizes.fontXs,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),

          // Stats
          StatCardRow(
            hadir: record.hadir,
            izin: record.izin,
            sakit: record.sakit,
            alfa: record.alfa,
          ),
        ],
      ),
    );
  }
}

class _TeachingRecord {
  final String courseName;
  final String date;
  final String time;
  final String room;
  final int hadir;
  final int izin;
  final int sakit;
  final int alfa;
  final int meeting;

  const _TeachingRecord({
    required this.courseName,
    required this.date,
    required this.time,
    required this.room,
    required this.hadir,
    required this.izin,
    required this.sakit,
    required this.alfa,
    required this.meeting,
  });
}
