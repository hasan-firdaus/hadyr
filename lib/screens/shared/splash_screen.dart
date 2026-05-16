import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();

    // Cek sesi login setelah animasi selesai
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) _checkAuthState();
    });
  }

  Future<void> _checkAuthState() async {
    try {
      final firebaseUser = _authService.currentUser;
      if (firebaseUser != null) {
        // User masih login, ambil data dari Firestore
        final user = await _authService.getUserData(firebaseUser.uid);
        if (user != null && mounted) {
          if (user.isLecturer) {
            Navigator.of(context).pushReplacementNamed(
              '/lecturer/dashboard',
              arguments: user,
            );
          } else {
            Navigator.of(context).pushReplacementNamed(
              '/student/home',
              arguments: user,
            );
          }
          return;
        }
      }
    } catch (e) {
      debugPrint('Auto-login error: $e');
    }

    // Tidak ada sesi aktif, ke halaman login
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo Icon
                const Icon(
                  Icons.school,
                  size: 90,
                  color: Colors.white,
                ),
                const SizedBox(height: AppSizes.lg),
                const Text(
                  AppStrings.appName,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  AppStrings.appTagline,
                  style: TextStyle(
                    fontSize: AppSizes.fontMd,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withAlpha(204),
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

