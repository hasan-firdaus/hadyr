import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hadyr/firebase_options.dart';

import 'core/theme/app_theme.dart';
import 'models/user_model.dart';
import 'services/auth_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/lecturer/dashboard_page.dart';
import 'screens/student/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Tangkap error UI dari Flutter
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.exception}');
  };

  // Tangkap error asinkron (Dart/Platform)
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Async Error: $error');
    debugPrint('Stack trace: $stack');
    return true; // Mencegah aplikasi crash (grey screen) jika memungkinkan
  };
  
  try {
    // Inisialisasi Firebase dengan penanganan khusus untuk duplicate-app
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).catchError((e) {
      if (e.toString().contains('duplicate-app')) {
        debugPrint('Firebase already initialized, continuing...');
        return Firebase.app(); // Gunakan app yang sudah ada
      }
      throw e;
    });

    await initializeDateFormatting('id_ID', null);
  } catch (e) {
    debugPrint('Initialization warning: $e');
    // Kita tetap lanjut ke runApp agar tidak hang di splash
  }

  runApp(const HadyrApp());
}


class HadyrApp extends StatelessWidget {
  const HadyrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hadyr',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      onGenerateRoute: _generateRoute,
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _fade(const AuthWrapper());

      case '/login':
        return _fade(const LoginScreen());

      case '/register':
        return _fade(const RegisterScreen());

      case '/lecturer/dashboard':
        final user = settings.arguments as UserModel?;
        if (user == null) return _fade(const LoginScreen());
        return _slide(LecturerDashboard(user: user));

      case '/student/home':
        final user = settings.arguments as UserModel?;
        if (user == null) return _fade(const LoginScreen());
        return _slide(StudentHomePage(user: user));

      default:
        return _fade(const AuthWrapper());
    }
  }

  PageRouteBuilder<dynamic> _fade(Widget page) => PageRouteBuilder(
        pageBuilder: (context, a1, a2) => page,
        transitionsBuilder: (context, anim, a2, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      );

  PageRouteBuilder<dynamic> _slide(Widget page) => PageRouteBuilder(
        pageBuilder: (context, a1, a2) => page,
        transitionsBuilder: (context, anim, a2, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      );
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      final firebaseUser = _authService.currentUser;
      if (firebaseUser != null) {
        final userData = await _authService.getUserData(firebaseUser.uid);
        if (mounted) {
          setState(() {
            _user = userData;
            _isLoading = false;
          });
        }
        return;
      }
    } catch (e) {
      debugPrint('Auto-login error: $e');
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_user != null) {
      if (_user!.isLecturer) {
        return LecturerDashboard(user: _user!);
      } else {
        return StudentHomePage(user: _user!);
      }
    }

    return const LoginScreen();
  }
}
