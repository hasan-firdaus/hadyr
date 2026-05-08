import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hadyr/firebase_options.dart';

import 'core/theme/app_theme.dart';
import 'models/user_model.dart';
import 'screens/shared/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/lecturer/dashboard_page.dart';
import 'screens/student/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('id_ID', null);
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
      initialRoute: '/splash',
      onGenerateRoute: _generateRoute,
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash':
        return _fade(const SplashScreen());

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
        return _fade(const SplashScreen());
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
