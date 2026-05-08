import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../models/attendance_model.dart';
import '../../models/course_model.dart';
import '../../models/user_model.dart';
import '../../services/database_service.dart';
import '../../widgets/custom_button.dart';

class InputAttendancePage extends StatefulWidget {
  final CourseModel course;
  final UserModel user;

  const InputAttendancePage({
    super.key,
    required this.course,
    required this.user,
  });

  @override
  State<InputAttendancePage> createState() => _InputAttendancePageState();
}

class _InputAttendancePageState extends State<InputAttendancePage> {
  final DatabaseService _dbService = DatabaseService();
  bool _isLoading = true;
  bool _isSaving = false;
  List<Map<String, dynamic>> _students = [];

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    try {
      // Mengambil daftar mahasiswa berdasarkan prodi matakuliah
      final students = await _dbService.getStudentsStream(widget.course.prodi).first;
      
      setState(() {
        _students = students.map((s) => {
          'uid': s.uid,
          'nim': s.nim ?? '-',
          'name': s.name,
          'status': AttendanceStatus.hadir, // DEFAULT HADIR
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data mahasiswa: $e')),
        );
      }
    }
  }

  void _setStatus(int index, AttendanceStatus status) {
    setState(() => _students[index]['status'] = status);
  }

  Future<void> _handleSave() async {
    if (_students.isEmpty) return;

    setState(() => _isSaving = true);
    try {
      final now = DateTime.now();
      final records = _students.map((s) => AttendanceModel(
        id: '', // Biarkan service generate ID otomatis di Firestore
        courseId: widget.course.id,
        courseName: widget.course.name,
        studentId: s['uid'],
        studentName: s['name'],
        studentNim: s['nim'],
        status: s['status'],
        date: now,
        meetingNumber: 1, // Bisa disesuaikan nanti
        room: widget.course.room,
        building: widget.course.building,
      )).toList();

      await _dbService.saveAttendanceBatch(records);

      if (!mounted) return;
      setState(() => _isSaving = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Absensi berhasil disimpan ke Firebase!'),
          backgroundColor: AppColors.statusHadir,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan absensi: $e')),
        );
      }
    }
  }

  int get _hadirCount =>
      _students.where((s) => s['status'] == AttendanceStatus.hadir).length;
  int get _izinCount =>
      _students.where((s) => s['status'] == AttendanceStatus.izin).length;
  int get _sakitCount =>
      _students.where((s) => s['status'] == AttendanceStatus.sakit).length;
  int get _alfaCount => _students
      .where(
        (s) =>
            s['status'] == AttendanceStatus.alfa ||
            s['status'] == AttendanceStatus.terlambat,
      )
      .length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Input Absensi'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ── Course Info Header ──────────────────────────
          _buildCourseHeader(),

          // ── Summary Stats ───────────────────────────────
          _buildSummaryStats(),

          // ── Student List ────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _students.isEmpty
                    ? const Center(child: Text('Tidak ada mahasiswa di prodi ini'))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                            AppSizes.pagePadding,
                            AppSizes.md,
                            AppSizes.pagePadding,
                            AppSizes.xl),
                        itemCount: _students.length,
                        separatorBuilder: (ctx, i) =>
                            const SizedBox(height: AppSizes.sm),
                        itemBuilder: (ctx, i) => _StudentAttendanceTile(
                          index: i + 1,
                          nim: _students[i]['nim'],
                          name: _students[i]['name'],
                          status: _students[i]['status'],
                          onStatusChanged: (s) => _setStatus(i, s),
                        ),
                      ),
          ),

          // ── Save Button ─────────────────────────────────
          _buildSaveBar(),
        ],
      ),
    );
  }

  Widget _buildCourseHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.pagePadding),
      color: AppColors.surface,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.course.name,
                  style: const TextStyle(
                    fontSize: AppSizes.fontLg,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${widget.course.timeRange}  •  ${widget.course.roomFull}',
                  style: const TextStyle(
                    fontSize: AppSizes.fontSm,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStats() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.pagePadding,
        vertical: AppSizes.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border),
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          _StatBadge(
            label: 'Hadir',
            count: _hadirCount,
            color: AppColors.statusHadir,
            bg: AppColors.statusHadirBg,
          ),
          const SizedBox(width: AppSizes.sm),
          _StatBadge(
            label: 'Izin',
            count: _izinCount,
            color: AppColors.statusIzin,
            bg: AppColors.statusIzinBg,
          ),
          const SizedBox(width: AppSizes.sm),
          _StatBadge(
            label: 'Sakit',
            count: _sakitCount,
            color: AppColors.statusSakit,
            bg: AppColors.statusSakitBg,
          ),
          const SizedBox(width: AppSizes.sm),
          _StatBadge(
            label: 'Alfa',
            count: _alfaCount,
            color: AppColors.statusAlfa,
            bg: AppColors.statusAlfaBg,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.pagePadding,
        AppSizes.md,
        AppSizes.pagePadding,
        AppSizes.lg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: CustomButton(
        label: AppStrings.simpanAbsensi,
        icon: Icons.check_circle_outline_rounded,
        onPressed: _handleSave,
        isLoading: _isSaving,
      ),
    );
  }
}

// ── Stat Badge ──────────────────────────────────────────────────
class _StatBadge extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final Color bg;

  const _StatBadge({
    required this.label,
    required this.count,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: AppSizes.fontXl,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: AppSizes.fontXs,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Student Attendance Tile ─────────────────────────────────────
class _StudentAttendanceTile extends StatelessWidget {
  final int index;
  final String nim;
  final String name;
  final AttendanceStatus status;
  final ValueChanged<AttendanceStatus> onStatusChanged;

  const _StudentAttendanceTile({
    required this.index,
    required this.nim,
    required this.name,
    required this.status,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name Row
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primaryLight,
                child: Text(
                  '$index',
                  style: const TextStyle(
                    fontSize: AppSizes.fontSm,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: AppSizes.fontMd,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      nim,
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

          // Status Buttons
          Row(
            children: AttendanceStatus.values.map((s) {
              final isSelected = status == s;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _StatusButton(
                    status: s,
                    isSelected: isSelected,
                    onTap: () => onStatusChanged(s),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  final AttendanceStatus status;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusButton({
    required this.status,
    required this.isSelected,
    required this.onTap,
  });

  Color get _activeColor {
    switch (status) {
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? _activeColor : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        ),
        alignment: Alignment.center,
        child: Text(
          status.code,
          style: TextStyle(
            fontSize: AppSizes.fontSm,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
