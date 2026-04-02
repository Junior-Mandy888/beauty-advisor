import 'package:go_router/go_router.dart';
import 'package:beauty_advisor/screens/home/home_screen.dart';
import 'package:beauty_advisor/screens/profile/profile_screen.dart';
import 'package:beauty_advisor/screens/recommendation/recommendation_screen.dart';
import 'package:beauty_advisor/screens/face_analysis/face_analysis_screen.dart';
import 'package:beauty_advisor/screens/wardrobe/wardrobe_screen.dart';
import 'package:beauty_advisor/screens/onboarding/onboarding_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/recommendation',
      name: 'recommendation',
      builder: (context, state) => const RecommendationScreen(),
    ),
    GoRoute(
      path: '/face-analysis',
      name: 'faceAnalysis',
      builder: (context, state) => const FaceAnalysisScreen(),
    ),
    GoRoute(
      path: '/wardrobe',
      name: 'wardrobe',
      builder: (context, state) => const WardrobeScreen(),
    ),
  ],
);
