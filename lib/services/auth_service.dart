import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Login dengan email & password
  Future<UserModel?> login(String email, String password) async {
    try {
      // Validate input
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email dan password tidak boleh kosong');
      }
      
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.toLowerCase().trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) throw Exception('Login gagal: user tidak ditemukan');
      
      final userData = await getUserData(user.uid);
      if (userData == null) throw Exception('Data user tidak lengkap');
      
      return userData;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Register akun baru
  Future<UserModel?> register({
    required String email,
    required String password,
    required String name,
    required String role,
    String? nidn,
    String? nim,
    String? prodi,
    String? fakultas,
    int? semester,
  }) async {
    try {
      // Validate required fields
      if (email.isEmpty || password.isEmpty || name.isEmpty || role.isEmpty) {
        throw Exception('Email, password, nama, dan role tidak boleh kosong');
      }
      if (password.length < 6) {
        throw Exception('Password minimal 6 karakter');
      }
      
      // Additional validation for student/lecturer specific fields
      if (role == 'student' && nim == null) {
        throw Exception('NIM tidak boleh kosong untuk mahasiswa');
      }
      if (role == 'lecturer' && nidn == null) {
        throw Exception('NIDN tidak boleh kosong untuk dosen');
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.toLowerCase().trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) throw Exception('Registrasi gagal: user tidak ditemukan');

      final userModel = UserModel(
        uid: user.uid,
        name: name.trim(),
        email: email.toLowerCase().trim(),
        role: role,
        nidn: nidn?.trim(),
        nim: nim?.trim(),
        prodi: prodi?.trim(),
        fakultas: fakultas,
        semester: semester,
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toMap());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e));
    } catch (e) {
      throw Exception('Registrasi gagal: ${e.toString()}');
    }
  }

  /// Ambil data user dari Firestore
  Future<UserModel?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap({'uid': uid, ...doc.data()!});
  }

  /// Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Ubah password
  Future<void> changePassword(String oldPassword, String newPassword) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('Sesi telah berakhir, silakan login kembali.');
    }

    try {
      // Re-authenticate user first
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw Exception('Password lama salah.');
      }
      throw _handleAuthError(e);
    } catch (e) {
      throw Exception('Gagal mengubah password: $e');
    }
  }

  /// Hapus akun user secara permanen
  Future<void> deleteAccount(String password) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('Sesi telah berakhir, silakan login kembali.');
    }

    try {
      // Re-authenticate user first (wajib sebelum menghapus akun di Firebase Auth)
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      
      // Hapus data dari Firestore
      await _firestore.collection('users').doc(user.uid).delete();
      
      // Hapus akun dari Firebase Auth
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw Exception('Password yang dimasukkan salah.');
      }
      throw _handleAuthError(e);
    } catch (e) {
      throw Exception('Gagal menghapus akun: $e');
    }
  }

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
        return 'Email atau password salah';
      case 'user-not-found':
        return 'Akun tidak ditemukan';
      case 'wrong-password':
        return 'Password salah';
      case 'email-already-in-use':
        return 'Email sudah terdaftar';
      case 'weak-password':
        return 'Password terlalu lemah (min. 6 karakter)';
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet';
      default:
        return e.message ?? 'Terjadi kesalahan';
    }
  }
}
