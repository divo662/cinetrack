import 'package:cinetrack/features/auth%20directory/login%20directory/screens/forgot_password.dart';
import 'package:cinetrack/features/auth%20directory/login%20directory/screens/login_screen.dart';
import 'package:cinetrack/features/auth%20directory/login%20directory/screens/otp_Screen.dart';
import 'package:cinetrack/features/auth%20directory/login%20directory/screens/reset_password.dart';
import 'package:cinetrack/features/auth%20directory/sign_up%20directory/screens/account_setup_screen.dart';
import 'package:cinetrack/features/auth%20directory/sign_up%20directory/screens/otp_verification_screen.dart';
import 'package:cinetrack/features/auth%20directory/sign_up%20directory/screens/sign_up_screen.dart';
import 'package:cinetrack/features/home%20directory/screens/bottom_nav_bar.dart';
import 'package:cinetrack/features/home%20directory/screens/home_screen.dart';
import 'package:cinetrack/features/profile%20directory/screens/change_password_screen.dart';
import 'package:cinetrack/features/splashscreen%20directory/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const SplashScreen();
      },
    ),
    GoRoute(
      path: '/onboarding',
      builder: (BuildContext context, GoRouterState state) {
        return const OnboardingScreen();
      },
    ),
    GoRoute(
      path: '/login_screen',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: '/sign_up_screen',
      builder: (BuildContext context, GoRouterState state) {
        return const SignUpScreen();
      },
    ),
    GoRoute(
      path: '/account_setup_screen',
      builder: (BuildContext context, GoRouterState state) {
        return const AccountSetupScreen();
      },
    ),
    GoRoute(
      path: '/otp_verify_screen',
      builder: (BuildContext context, GoRouterState state) {
        final email = state.uri.queryParameters['email'] ?? '';
        return OtpVerificationScreen(email: email);
      },
    ),
    GoRoute(
      path: '/forgotten_password_screen',
      builder: (BuildContext context, GoRouterState state) {
        return const ForgotPassword();
      },
    ),
    GoRoute(
      path: '/forgot_password_otp_screen',
      builder: (BuildContext context, GoRouterState state) {
        final email = state.uri.queryParameters['email'] ?? '';
        return OtpScreen(email: email);
      },
    ),
    GoRoute(
      path: '/reset_password_screen',
      builder: (BuildContext context, GoRouterState state) {
        final email = state.uri.queryParameters['email'] ?? '';
        return ResetPassword(email: email);
      },
    ),
    GoRoute(
      path: '/bottom_nav_screen',
      builder: (BuildContext context, GoRouterState state) {
        final String? token = state.extra as String?;
        if (token == null || JwtDecoder.isExpired(token)) {
          return const LoginScreen();
        }
        return BottomNavScreen(token: token);
      },
    ),
    GoRoute(
      path: '/home_screen',
      builder: (BuildContext context, GoRouterState state) {
        final String? token = state.extra as String?;
        return HomeScreen(token: token);
      },
    ),
    GoRoute(
      path: '/change_password_screen',
      builder: (BuildContext context, GoRouterState state) {
        return const ChangePasswordScreen();
      },
    ),
  ],
  errorBuilder: (context, state) => ErrorScreen(error: state.error),
);
class ErrorScreen extends StatelessWidget {
  final Exception? error;
  const ErrorScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(child: Text(error?.toString() ?? 'Unknown error occurred')),
    );
  }
}

