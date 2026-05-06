import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../models/attendance_model.dart';
import '../../models/course_model.dart';
import '../../models/user_model.dart';
import '../../widgets/stat_card.dart';
import '../shared/profile_page.dart';
import 'history_student.dart';

class StudentHomePage extends StatefulWidget {
  final UserModel user;
  const StudentHomePage({super.key, required this.user});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  // Dummy jadwal hari ini
  final List<CourseModel> _todayCourses = [
    CourseModel(
      id: '1',
      name: 'Pemrograman Web Lanjut',
      code: 'TI-301',
      lecturerId: 'dosen1',
      lecturerName: 'Dr. Hendra Gunawan, M.Kom',
      room: 'Ruang 201',
      building: 'Gedung A',
      day: 'Senin',
      startTime: '08:00',
      endTime: '10:30',
      semester: 5,
      prodi: 'Teknik Informatika',
    ),
    CourseModel(
      id: '2',
      name: 'Basis Data Relasional',
      code: 'TI-201',
      lecturerId: 'dosen1',
      lecturerName: 'Dr. Hendra Gunawan, M.Kom',
      room: 'Ruang 101',
      building: 'Gedung B',
      day: 'Senin',
      startTime: '13:00',
      endTime: '15:30',
      semester: 5,
      prodi: 'Teknik Informatika',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pages = [
      _StudentHomeTab(user: widget.user, todayCourses: _todayCourses),
      StudentHistoryPage(user: widget.user),
      ProfilePage(user: widget.user),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.navBarBg,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        elevation: 0,
        backgroundColor: Colors.transparent,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: AppStrings.navBeranda,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history_rounded),
            label: AppStrings.navRiwayat,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person_rounded),
            label: AppStrings.navProfil,
          ),
        ],
      ),
    );
  }
}

// ── Student Home Tab ────────────────────────────────────────────
class _StudentHomeTab extends StatelessWidget {
  final UserModel user;
  final List<CourseModel> todayCourses;

  const _StudentHomeTab({
    required this.user,
    required this.todayCourses,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────
            SliverToBoxAdapter(child: _buildHeader()),

            // ── Jadwal Hari Ini ─────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSizes.pagePadding, AppSizes.lg,
                    AppSizes.pagePadding, AppSizes.md),
                child: const Text(
                  'Jadwal Kuliah Hari Ini',
                  style: TextStyle(
                    fontSize: AppSizes.fontLg,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),

            // ── Course Cards ────────────────────────────────
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSizes.pagePadding,
                    i == 0 ? 0 : AppSizes.sm,
                    AppSizes.pagePadding,
                    0,
                  ),
                  child: _StudentCourseCard(course: todayCourses[i]),
                ),
                childCount: todayCourses.length,
              ),
            ),

            // ── Riwayat Singkat ─────────────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    AppSizes.pagePadding, AppSizes.lg,
                    AppSizes.pagePadding, AppSizes.md),
                child: Text(
                  'Riwayat Kehadiran Terkini',
                  style: TextStyle(
                    fontSize: AppSizes.fontLg,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.pagePadding),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _RecentAttendanceTile(
                      record: _recentRecords[i]),
                  childCount: _recentRecords.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(
                child: SizedBox(height: AppSizes.xl)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.pagePadding),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Halo, 👋',
                      style: TextStyle(
                          fontSize: AppSizes.fontSm,
                          color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: AppSizes.fontXl,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (user.nim != null)
                      Text(
                        'NIM: ${user.nim}',
                        style: const TextStyle(
                            fontSize: AppSizes.fontSm,
                            color: AppColors.textSecondary),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Container(
                width: AppSizes.avatarLg,
                height: AppSizes.avatarLg,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: user.photoUrl != null
                    ? ClipOval(
                        child: Image.network(user.photoUrl!,
                            fit: BoxFit.cover))
                    : const Icon(Icons.person_rounded,
                        size: 32, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          // Stat summary
          StatCardRow(hadir: 38, izin: 3, sakit: 1, alfa: 2),
        ],
      ),
    );
  }

  // Dummy recent records
  static final List<_RecentRecord> _recentRecords = [
    _RecentRecord(
      courseName: 'Pemrograman Web Lanjut',
      date: 'Senin, 25 Apr 2026',
      status: AttendanceStatus.hadir,
    ),
    _RecentRecord(
      courseName: 'Basis Data Relasional',
      date: 'Senin, 25 Apr 2026',
      status: AttendanceStatus.hadir,
    ),
    _RecentRecord(
      courseName: 'Pemrograman Web Lanjut',
      date: 'Senin, 18 Apr 2026',
      status: AttendanceStatus.izin,
    ),
    _RecentRecord(
      courseName: 'Rekayasa Data',
      date: 'Kamis, 17 Apr 2026',
      status: AttendanceStatus.hadir,
    ),
  ];
}

// ── Student Course Card ─────────────────────────────────────────
class _StudentCourseCard extends StatelessWidget {
  final CourseModel course;
  const _StudentCourseCard({required this.course});

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
        children: [
          // Time indicator
          Container(
            width: 56,
            padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Column(
              children: [
                Text(
                  course.startTime,
                  style: const TextStyle(
                    fontSize: AppSizes.fontSm,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  color: AppColors.primary.withAlpha(77),
                ),
                Text(
                  course.endTime,
                  style: const TextStyle(
                    fontSize: AppSizes.fontSm,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.md),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.name,
                  style: const TextStyle(
                    fontSize: AppSizes.fontMd,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  course.lecturerName,
                  style: const TextStyle(
                    fontSize: AppSizes.fontSm,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 12, color: AppColors.textHint),
                    const SizedBox(width: 2),
                    Text(
                      course.roomFull,
                      style: const TextStyle(
                        fontSize: AppSizes.fontXs,
                        color: AppColors.textHint,
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

// ── Recent Attendance Tile ──────────────────────────────────────
class _RecentAttendanceTile extends StatelessWidget {
  final _RecentRecord record;
  const _RecentAttendanceTile({required this.record});

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
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _statusBg,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Center(
              child: Text(
                record.status.code,
                style: TextStyle(
                  fontSize: AppSizes.fontMd,
                  fontWeight: FontWeight.w800,
                  color: _statusColor,
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
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  record.date,
                  style: const TextStyle(
                    fontSize: AppSizes.fontXs,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _statusBg,
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
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
    );
  }
}

class _RecentRecord {
  final String courseName;
  final String date;
  final AttendanceStatus status;
  const _RecentRecord(
      {required this.courseName,
      required this.date,
      required this.status});
}
