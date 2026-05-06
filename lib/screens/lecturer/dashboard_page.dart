import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../models/course_model.dart';
import '../../models/user_model.dart';
import '../../widgets/stat_card.dart';
import '../shared/profile_page.dart';
import 'history_teaching.dart';
import 'input_attendance.dart';

class LecturerDashboard extends StatefulWidget {
  final UserModel user;
  const LecturerDashboard({super.key, required this.user});

  @override
  State<LecturerDashboard> createState() => _LecturerDashboardState();
}

class _LecturerDashboardState extends State<LecturerDashboard> {
  int _currentIndex = 0;

  // ── Dummy data sesuai design ────────────────────────────────
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
      semester: 3,
      prodi: 'Teknik Informatika',
    ),
    CourseModel(
      id: '3',
      name: 'Rekayasa Data',
      code: 'TI-401',
      lecturerId: 'dosen1',
      lecturerName: 'Dr. Hendra Gunawan, M.Kom',
      room: 'Lab Komputer 2',
      building: 'Gedung C',
      day: 'Senin',
      startTime: '16:00',
      endTime: '17:40',
      semester: 7,
      prodi: 'Teknik Informatika',
    ),
  ];

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _DashboardHome(
        user: widget.user,
        todayCourses: _todayCourses,
        onInputAbsensi: (course) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => InputAttendancePage(
                course: course,
                user: widget.user,
              ),
            ),
          );
        },
      ),
      HistoryTeachingPage(user: widget.user),
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

// ── Dashboard Home Tab ──────────────────────────────────────────
class _DashboardHome extends StatelessWidget {
  final UserModel user;
  final List<CourseModel> todayCourses;
  final void Function(CourseModel) onInputAbsensi;

  const _DashboardHome({
    required this.user,
    required this.todayCourses,
    required this.onInputAbsensi,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────
            SliverToBoxAdapter(child: _buildHeader(context)),

            // ── Jadwal Hari Ini ─────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSizes.pagePadding, AppSizes.lg, AppSizes.pagePadding, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      AppStrings.jadwalHariIni,
                      style: TextStyle(
                        fontSize: AppSizes.fontLg,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
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
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSizes.pagePadding,
                    i == 0 ? AppSizes.md : AppSizes.sm,
                    AppSizes.pagePadding,
                    0,
                  ),
                  child: _CourseCard(
                    course: todayCourses[i],
                    onInputAbsensi: () => onInputAbsensi(todayCourses[i]),
                  ),
                ),
                childCount: todayCourses.length,
              ),
            ),

            const SliverToBoxAdapter(
                child: SizedBox(height: AppSizes.xl)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.pagePadding),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: greeting + avatar
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selamat Datang, 👋',
                      style: TextStyle(
                        fontSize: AppSizes.fontSm,
                        color: AppColors.textSecondary,
                      ),
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
                    if (user.nip != null)
                      Text(
                        'NIP: ${user.nip}',
                        style: const TextStyle(
                          fontSize: AppSizes.fontSm,
                          color: AppColors.textSecondary,
                        ),
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
                        child:
                            Image.network(user.photoUrl!, fit: BoxFit.cover))
                    : const Icon(Icons.person_rounded,
                        size: 32, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),

          // Stats Row
          StatCardRow(
            hadir: 42,
            izin: 5,
            sakit: 2,
            alfa: 1,
          ),
        ],
      ),
    );
  }
}

// ── Course Card ─────────────────────────────────────────────────
class _CourseCard extends StatelessWidget {
  final CourseModel course;
  final VoidCallback onInputAbsensi;

  const _CourseCard({required this.course, required this.onInputAbsensi});

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
          // Time + Room
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: Text(
                  course.timeRange,
                  style: const TextStyle(
                    fontSize: AppSizes.fontXs,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              const Icon(Icons.location_on_outlined,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  course.roomFull,
                  style: const TextStyle(
                    fontSize: AppSizes.fontXs,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),

          // Course Name
          Text(
            course.name,
            style: const TextStyle(
              fontSize: AppSizes.fontLg,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            course.code,
            style: const TextStyle(
              fontSize: AppSizes.fontSm,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.md),

          // Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.edit_note_rounded, size: 18),
              label: const Text(AppStrings.inputAbsensi),
              onPressed: onInputAbsensi,
            ),
          ),
        ],
      ),
    );
  }
}
