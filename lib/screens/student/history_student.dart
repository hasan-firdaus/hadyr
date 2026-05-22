import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../models/attendance_model.dart';
import '../../models/user_model.dart';
import '../../services/database_service.dart';
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
  final DatabaseService _dbService = DatabaseService();

  final List<String> _filterTabs = [
    'Semua',
    'Hadir',
    'Izin',
    'Sakit',
    'Alfa',
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

  List<AttendanceModel> _getFiltered(List<AttendanceModel> records) {
    final tab = _filterTabs[_tabController.index];
    if (tab == 'Semua') return records;
    return records.where((r) => r.status.label == tab).toList();
  }

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
      body: StreamBuilder<List<AttendanceModel>>(
        stream: _dbService.getStudentAttendanceStream(widget.user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final records = snapshot.data ?? [];
          final filtered = _getFiltered(records);

          // Hitung statistik
          int hadir = records.where((r) => r.status == AttendanceStatus.hadir).length;
          int izin = records.where((r) => r.status == AttendanceStatus.izin).length;
          int sakit = records.where((r) => r.status == AttendanceStatus.sakit).length;
          int alfa = records.where((r) => r.status == AttendanceStatus.alfa).length;

          return Column(
            children: [
              // ── Stats Summary ───────────────────────────────
              Container(
                padding: const EdgeInsets.all(AppSizes.pagePadding),
                color: AppColors.surface,
                child: StatCardRow(
                  hadir: hadir,
                  izin: izin,
                  sakit: sakit,
                  alfa: alfa,
                ),
              ),
              const Divider(height: 1, color: AppColors.border),

              // ── List ────────────────────────────────────────
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Text(
                          'Tidak ada data absensi',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(AppSizes.pagePadding),
                        itemCount: filtered.length,
                        separatorBuilder: (ctx, i) =>
                            const SizedBox(height: AppSizes.sm),
                        itemBuilder: (ctx, i) =>
                            _AttendanceRecordCard(record: filtered[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Attendance Record Card ──────────────────────────────────────
class _AttendanceRecordCard extends StatelessWidget {
  final AttendanceModel record;
  const _AttendanceRecordCard({required this.record});

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
                  color: record.status.bgColor,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Center(
                  child: Text(
                    record.status.code,
                    style: TextStyle(
                      fontSize: AppSizes.fontLg,
                      fontWeight: FontWeight.w800,
                      color: record.status.color,
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
                        color: record.status.bgColor,
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusFull),
                      ),
                      child: Text(
                        record.status.label,
                        style: TextStyle(
                          fontSize: AppSizes.fontXs,
                          fontWeight: FontWeight.w600,
                          color: record.status.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(record.date),
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
                      DateFormat('HH:mm').format(record.date),
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

