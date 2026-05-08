import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance_model.dart';
import '../models/course_model.dart';
import '../models/user_model.dart';
import '../core/utils/app_utils.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── COURSES ────────────────────────────────────────────────

  /// Stream jadwal dosen hari ini
  Stream<List<CourseModel>> getLecturerCoursesStream(String lecturerId) {
    final today = AppUtils.getCurrentDayName();
    return _db
        .collection('courses')
        .where('lecturerId', isEqualTo: lecturerId)
        .where('day', isEqualTo: today)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => CourseModel.fromMap(d.id, d.data()))
            .toList());
  }

  /// Stream semua jadwal dosen (untuk Lihat Semua)
  Stream<List<CourseModel>> getAllLecturerCoursesStream(String lecturerId) {
    return _db
        .collection('courses')
        .where('lecturerId', isEqualTo: lecturerId)
        .snapshots()
        .map((snap) {
      final courses =
          snap.docs.map((d) => CourseModel.fromMap(d.id, d.data())).toList();

      // Urutkan berdasarkan hari
      final dayOrder = [
        'Senin',
        'Selasa',
        'Rabu',
        'Kamis',
        'Jumat',
        'Sabtu',
        'Minggu'
      ];
      courses.sort((a, b) {
        int dayA = dayOrder.indexOf(a.day);
        int dayB = dayOrder.indexOf(b.day);
        if (dayA != dayB) return dayA.compareTo(dayB);
        return a.startTime.compareTo(b.startTime);
      });
      return courses;
    });
  }

  /// Stream semua kelas mahasiswa (by prodi/semester)
  Stream<List<CourseModel>> getStudentCoursesStream(String prodi, int semester) {
    final today = AppUtils.getCurrentDayName();
    return _db
        .collection('courses')
        .where('prodi', isEqualTo: prodi)
        .where('semester', isEqualTo: semester)
        .where('day', isEqualTo: today)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => CourseModel.fromMap(d.id, d.data()))
            .toList());
  }

  // ─── ATTENDANCE ─────────────────────────────────────────────

  /// Stream semua absensi untuk kelas tertentu (untuk dosen)
  Stream<List<AttendanceModel>> getCourseAttendanceStream(String courseId) {
    return _db
        .collection('attendance')
        .where('courseId', isEqualTo: courseId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => AttendanceModel.fromMap(d.id, d.data()))
            .toList());
  }

  /// Stream riwayat absensi mahasiswa
  Stream<List<AttendanceModel>> getStudentAttendanceStream(String studentId) {
    return _db
        .collection('attendance')
        .where('studentId', isEqualTo: studentId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => AttendanceModel.fromMap(d.id, d.data()))
            .toList());
  }

  /// Simpan atau update absensi (batch)
  Future<void> saveAttendanceBatch(List<AttendanceModel> records) async {
    final batch = _db.batch();
    for (final record in records) {
      final docRef = record.id.isEmpty
          ? _db.collection('attendance').doc()
          : _db.collection('attendance').doc(record.id);
      batch.set(docRef, record.toMap(), SetOptions(merge: true));
    }
    await batch.commit();
  }

  // ─── USERS ──────────────────────────────────────────────────

  /// Stream daftar mahasiswa (by prodi)
  Stream<List<UserModel>> getStudentsStream(String prodi) {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'student')
        .where('prodi', isEqualTo: prodi)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => UserModel.fromMap({'uid': d.id, ...d.data()}))
            .toList());
  }

  /// Update profil user
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }
}
