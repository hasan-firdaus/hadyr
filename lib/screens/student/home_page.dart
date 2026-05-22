import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../models/attendance_model.dart';
import '../../models/course_model.dart';
import '../../models/user_model.dart';
import '../../services/database_service.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/user_avatar.dart';
import '../shared/profile_page.dart';
import 'history_student.dart';
import 'all_courses_page.dart';

class StudentHomePage extends StatefulWidget {
  final UserModel user;
  const StudentHomePage({super.key, required this.user});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  int _currentIndex = 0;
  final DatabaseService _dbService = DatabaseService();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _StudentHomeTab(user: widget.user, dbService: _dbService),
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
  final DatabaseService dbService;

  const _StudentHomeTab({
    required this.user,
    required this.dbService,
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Jadwal Kuliah Hari Ini',
                      style: TextStyle(
                        fontSize: AppSizes.fontLg,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AllCoursesPage(user: user),
                          ),
                        );
                      },
                      child: const Text(
                        AppStrings.lihatSemua,
                        style: TextStyle(
                          fontSize: AppSizes.fontSm,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Course Cards ────────────────────────────────
            StreamBuilder<List<CourseModel>>(
              stream: dbService.getStudentCoursesStream(
                  user.prodi ?? '', user.semester ?? 0),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()));
                }
                final courses = snapshot.data ?? [];
                if (courses.isEmpty) {
                  return const SliverToBoxAdapter(
                      child: Center(child: Text('Tidak ada jadwal kuliah')));
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSizes.pagePadding,
                        i == 0 ? 0 : AppSizes.sm,
                        AppSizes.pagePadding,
                        0,
                      ),
                      child: _StudentCourseCard(course: courses[i]),
                    ),
                    childCount: courses.length,
                  ),
                );
              },
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
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
              sliver: StreamBuilder<List<AttendanceModel>>(
                stream: dbService.getStudentAttendanceStream(user.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverToBoxAdapter(
                        child: Center(child: CircularProgressIndicator()));
                  }
                  final records = snapshot.data ?? [];
                  if (records.isEmpty) {
                    return const SliverToBoxAdapter(
                        child: Center(child: Text('Belum ada riwayat')));
                  }
                  // Ambil 5 terakhir saja untuk dashboard
                  final displayRecords = records.take(5).toList();
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) =>
                          _RecentAttendanceTile(record: displayRecords[i]),
                      childCount: displayRecords.length,
                    ),
                  );
                },
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
    return StreamBuilder<UserModel>(
      stream: dbService.getUserStream(user.uid),
      initialData: user,
      builder: (context, snapshot) {
        final currentUser = snapshot.data ?? user;
        
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
                          currentUser.name,
                          style: const TextStyle(
                            fontSize: AppSizes.fontXl,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (currentUser.nim != null)
                          Text(
                            'NIM: ${currentUser.nim}',
                            style: const TextStyle(
                                fontSize: AppSizes.fontSm,
                                color: AppColors.textSecondary),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  UserAvatar(
                    user: currentUser,
                    size: AppSizes.avatarLg,
                    iconSize: 32,
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.md),
              // Stat summary — real data
              StreamBuilder<List<AttendanceModel>>(
                stream: dbService.getStudentAttendanceStream(user.uid),
                builder: (context, attSnap) {
                  final records = attSnap.data ?? [];
                  int hadir = records
                      .where((r) => r.status == AttendanceStatus.hadir)
                      .length;
                  int izin = records
                      .where((r) => r.status == AttendanceStatus.izin)
                      .length;
                  int sakit = records
                      .where((r) => r.status == AttendanceStatus.sakit)
                      .length;
                  int alfa = records
                      .where((r) => r.status == AttendanceStatus.alfa)
                      .length;
                  return StatCardRow(
                    hadir: hadir,
                    izin: izin,
                    sakit: sakit,
                    alfa: alfa,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

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
  final AttendanceModel record;
  const _RecentAttendanceTile({required this.record});

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
              color: record.status.bgColor,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Center(
              child: Text(
                record.status.code,
                style: TextStyle(
                  fontSize: AppSizes.fontMd,
                  fontWeight: FontWeight.w800,
                  color: record.status.color,
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
                  DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(record.date),
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
              color: record.status.bgColor,
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
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
    );
  }
}

