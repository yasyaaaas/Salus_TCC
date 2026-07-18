import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/chat/screens/chat_screen.dart';
import 'features/exams/screens/exam_screen.dart';
import 'features/location/screens/location_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'core/services/api_service.dart';

void main() {
  runApp(const SalusApp());
}

class SalusApp extends StatelessWidget {
  const SalusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Salus',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/onboarding',
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/chat': (context) => const ChatScreen(),
        '/exams': (context) => const ExamScreen(),
        '/location': (context) => const LocationScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
