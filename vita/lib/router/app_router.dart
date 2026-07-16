import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vita/screens/onboarding/onboarding_screen.dart';
import 'package:vita/screens/auth/auth_screen.dart';
import 'package:vita/screens/dashboard/dashboard_screen.dart';
import 'package:vita/screens/health/health_profile_screen.dart';
import 'package:vita/screens/health/edit_health_screen.dart';
import 'package:vita/screens/nfc/nfc_home_screen.dart';
import 'package:vita/screens/nfc/nfc_write_screen.dart';
import 'package:vita/screens/nfc/nfc_read_screen.dart';
import 'package:vita/screens/nfc/nfc_read_result_screen.dart';
import 'package:vita/screens/emergency/emergency_confirm_screen.dart';
import 'package:vita/screens/emergency/hospital_finder_screen.dart';
import 'package:vita/screens/emergency/emergency_receipt_screen.dart';
import 'package:vita/screens/group/group_create_screen.dart';
import 'package:vita/screens/group/members_screen.dart';
import 'package:vita/screens/group/admin_screen.dart';
import 'package:vita/screens/more/more_screen.dart';
import 'package:vita/screens/more/settings_screen.dart';
import 'package:vita/screens/more/privacy_policy_screen.dart';
// Terms is exported from privacy_policy_screen.dart
import 'package:vita/screens/more/about_screen.dart';
import 'package:vita/screens/web/vitavoice_screen.dart';
import 'package:vita/widgets/vita_bottom_nav.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/onboarding',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),

    // ── Main shell with bottom nav ──────────────────────────────────────────
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => VitaShell(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/health',
          builder: (context, state) => const HealthProfileScreen(),
        ),
        GoRoute(
          path: '/nfc',
          builder: (context, state) => const NFCHomeScreen(),
        ),
        GoRoute(
          path: '/more',
          builder: (context, state) => const MoreScreen(),
        ),
      ],
    ),

    // ── Health ──────────────────────────────────────────────────────────────
    GoRoute(
      path: '/health/edit',
      builder: (context, state) => const EditHealthScreen(),
    ),

    // ── NFC ─────────────────────────────────────────────────────────────────
    GoRoute(
      path: '/nfc/write',
      builder: (context, state) => const NFCWriteScreen(),
    ),
    GoRoute(
      path: '/nfc/read',
      builder: (context, state) => const NFCReadScreen(),
    ),
    GoRoute(
      path: '/nfc/read-result',
      builder: (context, state) => const NFCReadResultScreen(),
    ),

    // ── Emergency ───────────────────────────────────────────────────────────
    GoRoute(
      path: '/emergency',
      builder: (context, state) => const EmergencyConfirmScreen(),
    ),
    GoRoute(
      path: '/emergency/hospitals',
      builder: (context, state) => const HospitalFinderScreen(),
    ),
    GoRoute(
      path: '/emergency/receipt',
      builder: (context, state) => const EmergencyReceiptScreen(),
    ),

    // ── Group ───────────────────────────────────────────────────────────────
    GoRoute(
      path: '/group/create',
      builder: (context, state) => const GroupCreateScreen(),
    ),
    GoRoute(
      path: '/group/members',
      builder: (context, state) => const MembersScreen(),
    ),
    GoRoute(
      path: '/group/admin',
      builder: (context, state) => const AdminScreen(),
    ),

    // ── More / Settings / Legal ─────────────────────────────────────────────
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/privacy',
      builder: (context, state) => const PrivacyPolicyScreen(),
    ),
    GoRoute(
      path: '/terms',
      builder: (context, state) => const TermsScreen(),
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => const AboutScreen(),
    ),

    // ── Web / SMS ───────────────────────────────────────────────────────────
    GoRoute(
      path: '/vitavoice',
      builder: (context, state) => const VitaVoiceScreen(),
    ),
  ],
);
