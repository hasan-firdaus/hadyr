import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../models/attendance_model.dart';
import '../../models/user_model.dart';
import '../../widgets/stat_card.dart';

class StudentHistoryPage extends StatefulWidget {
  final UserModel user;
  const StudentHistoryPage({super.key, required this.user});

  @override
  State<StudentHistoryPage> createState() => _StudentHistoryPageState();
}

class _StudentHistoryPageState extends State<StudentHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _filterTabs = [
    'Semua',
    'Hadir',
    'Izin',
    'Sakit',
    'Alfa',
  ];

  // Dummy riwayat absensi sesuai design
  final List<_AttendanceRecord> _records = [
    _AttendanceRecord(
      courseName: 'Pemrograman Web Lanjut',
      date: 'Senin, 25 April 2026',
      time: '08:00 - 10:30',
      room: 'Ruang 201, Gedung A',
      status: AttendanceStatus.hadir,
      meeting: 12,
    ),
    _AttendanceRecord(
      courseName: 'Basis Data Relasional',
      date: 'Senin, 25 April 2026',
      time: '13:00 - 15:30',
      room: 'Ruang 101, Gedung B',
      status: AttendanceStatus.hadir,
      meeting: 11,
    ),
    _AttendanceRecord(
      courseName: 'Sistem Operasi',
      date: 'Selasa, 24 April 2026',
      time: '10:00 - 12:30',
      room: 'Ruang 304, Gedung G',
      status: AttendanceStatus.izin,
      meeting: 10,
    ),
    _AttendanceRecord(
      courseName: 'Pemrograman Web Lanjut',
      date: 'Senin, 18 April 2026',
      time: '08:00 - 10:30',
      room: 'Ruang 201, Gedung A',
      status: AttendanceStatus.hadir,
      meeting: 11,
    ),
    _AttendanceRecord(
      courseName: 'Sistem Operasi',
      date: 'Selasa, 17 April 2026',
      time: '10:00 - 12:30',
      room: 'Ruang 304, Gedung G',
      status: AttendanceStatus.terlambat,
      meeting: 9,
    ),
    _AttendanceRecord(
      courseName: 'Kalkulus Lanjut',
      date: 'Rabu, 16 April 2026',
      time: '07:30 - 09:10',
      room: 'Ruang 102, Gedung F',
      status: AttendanceStatus.sakit,
      meeting: 10,
    ),
    _AttendanceRecord(
      courseName: 'Basis Data Relasional',
      date: 'Senin, 18 April 2026',
      time: '13:00 - 15:30',
      room: 'Ruang 101, Gedung B',
      status: AttendanceStatus.alfa,
      meeting: 10,
    ),
    _AttendanceRecord(
      courseName: 'Pemrograman Web Lanjut',
      date: 'Senin, 11 April 2026',
      time: '08:00 - 10:30',
      room: 'Ruang 201, Gedung A',
      status: AttendanceStatus.hadir,
      meeting: 10,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filterTabs.length, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<_AttendanceRecord> get _filtered {
    final tab = _filterTabs[_tabController.index];
    if (tab == 'Semua') return _records;
    return _records
        .where((r) => r.status.label == tab)
        .toList();
  }

  int get _hadirCount =>
      _records.where((r) => r.status == AttendanceStatus.hadir).length;
  int get _izinCount =>
      _records.where((r) => r.status == AttendanceStatus.izin).length;
  int get _sakitCount =>
      _records.where((r) => r.status == AttendanceStatus.sakit).length;
  int get _alfaCount =>
      _records.where((r) => r.status == AttendanceStatus.alfa).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Riwayat Absensi'),
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
            tabs: _filterTabs.map((t) => Tab(text: t)).toList(),
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Stats Summary ───────────────────────────────
          Container(
            padding: const EdgeInsets.all(AppSizes.pagePadding),
            color: AppColors.surface,
            child: StatCardRow(
              hadir: _hadirCount,
              izin: _izinCount,
              sakit: _sakitCount,
              alfa: _alfaCount,
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // ── List ────────────────────────────────────────
          Expanded(
            child: _filtered.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada data absensi',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSizes.pagePadding),
                    itemCount: _filtered.length,
                    separatorBuilder: (ctx, i) =>
                        const SizedBox(height: AppSizes.sm),
                    itemBuilder: (ctx, i) =>
                        _AttendanceRecordCard(record: _filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Attendance Record Card ──────────────────────────────────────
class _AttendanceRecordCard extends StatelessWidget {
  final _AttendanceRecord record;
  const _AttendanceRecordCard({required this.record});

  Color get _statusColor {
    switch (record.status) {
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

  Color get _statusBg {
    switch (record.status) {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meeting number + status indicator
          Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _statusBg,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Center(
                  child: Text(
                    record.status.code,
                    style: TextStyle(
                      fontSize: AppSizes.fontLg,
                      fontWeight: FontWeight.w800,
                      color: _statusColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSizes.md),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        record.courseName,
                        style: const TextStyle(
                          fontSize: AppSizes.fontMd,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _statusBg,
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusFull),
                      ),
                      child: Text(
                        record.status.label,
                        style: TextStyle(
                          fontSize: AppSizes.fontXs,
                          fontWeight: FontWeight.w600,
                          color: _statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  record.date,
                  style: const TextStyle(
                    fontSize: AppSizes.fontSm,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.access_time_outlined,
                        size: 12, color: AppColors.textHint),
                    const SizedBox(width: 3),
                    Text(
                      record.time,
                      style: const TextStyle(
                        fontSize: AppSizes.fontXs,
                        color: AppColors.textHint,
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    const Icon(Icons.location_on_outlined,
                        size: 12, color: AppColors.textHint),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        record.room,
                        style: const TextStyle(
                          fontSize: AppSizes.fontXs,
                          color: AppColors.textHint,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceRecord {
  final String courseName;
  final String date;
  final String time;
  final String room;
  final AttendanceStatus status;
  final int meeting;

  const _AttendanceRecord({
    required this.courseName,
    required this.date,
    required this.time,
    required this.room,
    required this.status,
    required this.meeting,
  });
}
