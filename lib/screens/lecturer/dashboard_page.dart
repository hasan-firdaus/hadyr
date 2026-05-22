import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';

import '../../models/course_model.dart';
import '../../models/user_model.dart';
import '../../services/database_service.dart';

import '../../widgets/user_avatar.dart';
import '../shared/profile_page.dart';
import 'history_teaching.dart';
import 'input_attendance.dart';
import 'all_schedules_page.dart';

class LecturerDashboard extends StatefulWidget {
  final UserModel user;
  const LecturerDashboard({super.key, required this.user});

  @override
  State<LecturerDashboard> createState() => _LecturerDashboardState();
}

class _LecturerDashboardState extends State<LecturerDashboard> {
  int _currentIndex = 0;
  final DatabaseService _dbService = DatabaseService();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _DashboardHome(
        user: widget.user,
        dbService: _dbService,
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
  final DatabaseService dbService;
  final void Function(CourseModel) onInputAbsensi;

  const _DashboardHome({
    required this.user,
    required this.dbService,
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AllSchedulesPage(user: user),
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
              stream: dbService.getLecturerCoursesStream(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                
                if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: Center(child: Text('Error: ${snapshot.error}')),
                  );
                }

                final courses = snapshot.data ?? [];
                
                if (courses.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSizes.xl),
                        child: Text('Tidak ada jadwal kuliah hari ini'),
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSizes.pagePadding,
                        i == 0 ? AppSizes.md : AppSizes.sm,
                        AppSizes.pagePadding,
                        0,
                      ),
                      child: _CourseCard(
                        course: courses[i],
                        onInputAbsensi: () => onInputAbsensi(courses[i]),
                      ),
                    ),
                    childCount: courses.length,
                  ),
                );
              },
            ),

            const SliverToBoxAdapter(
                child: SizedBox(height: AppSizes.xl)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
                          currentUser.name,
                          style: const TextStyle(
                            fontSize: AppSizes.fontXl,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (currentUser.nidn != null)
                          Text(
                            'NIDN: ${currentUser.nidn}',
                            style: const TextStyle(
                              fontSize: AppSizes.fontSm,
                              color: AppColors.textSecondary,
                            ),
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
            ],
          ),
        );
      },
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
