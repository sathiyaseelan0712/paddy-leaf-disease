import 'package:go_router/go_router.dart';
import 'package:paddycrop/constants/route_constants.dart';
import 'package:paddycrop/views/screens/dashboard/camera_screen.dart';
import 'package:paddycrop/views/screens/dashboard/home_screen.dart';
import 'package:paddycrop/views/screens/dashboard/starting_screen.dart';
import 'package:paddycrop/views/screens/dashboard/verify_photo.dart';
import 'package:paddycrop/views/screens/results/happy_screen.dart';
import 'package:paddycrop/views/screens/results/not_paddy_screen.dart';
import 'package:paddycrop/views/screens/results/diseease_screen.dart';
import 'package:paddycrop/views/screens/results/treatment_screen.dart';
import 'package:paddycrop/views/screens/splash_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteConstants.splashScreen,
    routes: [
      GoRoute(
        path: RouteConstants.splashScreen,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteConstants.startingScreen,
        builder: (context, state) => const StartingScreen(),
      ),
      GoRoute(
        path: RouteConstants.homeScreen,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: RouteConstants.cameraScreen,
        builder: (context, state) => const CameraScreen(),
      ),
      GoRoute(
        path: RouteConstants.verifyImageScreen,
        builder: (context, state) {
          final e = state.extra as String;
          return VerifyPhotoScreen(imagePath: e);
        },
      ),
      GoRoute(
        path: RouteConstants.happyScreen,
        builder: (context, state) {
          final e = state.extra as Map<String, dynamic>;
          return HappyScreen(data: e);
        },
      ),
      GoRoute(
        path: RouteConstants.notPaddyScreen,
        builder: (context, state) {
          final e = state.extra as Map<String, dynamic>;
          return NotpaddyScreen(imagePath: e['imagePath'], data:e['response']);
        },
      ),
      GoRoute(
        path: RouteConstants.diseaseScreen,
        builder: (context, state) {
          final e = state.extra as Map<String, dynamic>;
          return DiseeaseScreen(data:e);
        },
      ),
      GoRoute(
        path: RouteConstants.treatmentScreen,
        builder: (context, state) {
          final e = state.extra as Map<String, dynamic>;
          return TreatmentScreen(imagePath: e['imagePath'], data: e['data']);
        },
      ),
    ],
  );
}
