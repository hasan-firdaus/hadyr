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
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) return null;
      return await getUserData(user.uid);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
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
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) return null;

      final userModel = UserModel(
        uid: user.uid,
        name: name,
        email: email,
        role: role,
        nidn: nidn,
        nim: nim,
        prodi: prodi,
        fakultas: fakultas,
        semester: semester,
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toMap());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
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
      if (e.code == 'wrong-password') {
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
      if (e.code == 'wrong-password') {
        throw Exception('Password yang dimasukkan salah.');
      }
      throw _handleAuthError(e);
    } catch (e) {
      throw Exception('Gagal menghapus akun: $e');
    }
  }

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
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
