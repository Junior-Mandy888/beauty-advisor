import 'package:go_router/go_router.dart';
import 'package:beauty_advisor/screens/splash/splash_screen.dart';
import 'package:beauty_advisor/screens/home/home_screen.dart';
import 'package:beauty_advisor/screens/profile/profile_screen.dart';
import 'package:beauty_advisor/screens/recommendation/recommendation_screen.dart';
import 'package:beauty_advisor/screens/face_analysis/face_analysis_screen.dart';
import 'package:beauty_advisor/screens/wardrobe/wardrobe_screen.dart';
import 'package:beauty_advisor/screens/onboarding/onboarding_screen.dart';
import 'package:beauty_advisor/screens/membership/membership_screen.dart';
import 'package:beauty_advisor/screens/hairstyle/hairstyle_screen.dart';
import 'package:beauty_advisor/screens/makeup/makeup_tutorial_screen.dart';
import 'package:beauty_advisor/screens/virtual_tryon/virtual_tryon_screen.dart';
import 'package:beauty_advisor/screens/community/community_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
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
      path: '/membership',
      name: 'membership',
      builder: (context, state) => const MembershipScreen(),
    ),
    GoRoute(
      path: '/hairstyle',
      name: 'hairstyle',
      builder: (context, state) => const HairstyleScreen(),
    ),
    GoRoute(
      path: '/makeup',
      name: 'makeup',
      builder: (context, state) => const MakeupTutorialScreen(),
    ),
    GoRoute(
      path: '/virtual-tryon',
      name: 'virtualTryOn',
      builder: (context, state) => const VirtualTryOnScreen(),
    ),
    GoRoute(
      path: '/community',
      name: 'community',
      builder: (context, state) => const CommunityScreen(),
    ),
    GoRoute(
      path: '/recommendation',
      name: 'recommendation',
      builder: (context, state) => const RecommendationScreen(),
    ),
    GoRoute(
      path: '/face-analysis',
      name: 'faceAnalysis',
      builder: (context, state) {
        final fromOnboarding = state.uri.queryParameters['fromOnboarding'] == 'true';
        return FaceAnalysisScreen(fromOnboarding: fromOnboarding);
      },
    ),
    GoRoute(
      path: '/wardrobe',
      name: 'wardrobe',
      builder: (context, state) => const WardrobeScreen(),
    ),
  ],
);
