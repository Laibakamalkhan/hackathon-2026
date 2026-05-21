import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/animations/page_transitions.dart';
import '../features/consumer/booking_flow_screens.dart';
import '../features/consumer/browse_profile_screens.dart';
import '../features/consumer/chat_active_screen.dart';
import '../features/consumer/chat_home_screen.dart';
import '../features/consumer/post_booking_screens.dart';
import '../features/debug/stress_scenarios_screen.dart';
import '../features/onboarding/language_selection_screen.dart';
import '../features/onboarding/otp_verify_screen.dart';
import '../features/onboarding/phone_auth_screen.dart';
import '../features/onboarding/role_selection_screen.dart';
import '../features/onboarding/setup_profile_screen.dart';
import '../features/onboarding/splash_screen.dart';
import '../features/onboarding/tutorial_screens.dart';
import '../features/provider/provider_screens.dart';
import '../screens/auth_gate.dart';
import 'app_routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(path: AppRoutes.splash, pageBuilder: (_, s) => fadeSlidePage(key: s.pageKey, child: const SplashScreen())),
      GoRoute(path: AppRoutes.languageSelect, pageBuilder: (_, s) => fadeSlidePage(key: s.pageKey, child: const LanguageSelectionScreen())),
      GoRoute(path: AppRoutes.tutorial1, pageBuilder: (_, s) => fadeSlidePage(key: s.pageKey, child: const Tutorial1Screen())),
      GoRoute(path: AppRoutes.tutorial2, pageBuilder: (_, s) => fadeSlidePage(key: s.pageKey, child: const Tutorial2Screen())),
      GoRoute(path: AppRoutes.roleSelect, pageBuilder: (_, s) => fadeSlidePage(key: s.pageKey, child: const RoleSelectionScreen())),
      GoRoute(path: AppRoutes.phoneAuth, pageBuilder: (_, s) => fadeSlidePage(key: s.pageKey, child: const PhoneAuthScreen())),
      GoRoute(path: AppRoutes.otpVerify, pageBuilder: (_, s) => fadeSlidePage(key: s.pageKey, child: const OtpVerifyScreen())),
      GoRoute(path: AppRoutes.setupProfile, pageBuilder: (_, s) => fadeSlidePage(key: s.pageKey, child: const SetupProfileScreen())),
      GoRoute(path: AppRoutes.home, pageBuilder: (_, s) => fadeSlidePage(key: s.pageKey, child: const ChatHomeScreen())),
      GoRoute(path: AppRoutes.chatActive, pageBuilder: (_, s) => fadeSlidePage(key: s.pageKey, child: const ChatActiveScreen())),
      GoRoute(path: AppRoutes.providerRanking, pageBuilder: (_, s) => fadeSlidePage(key: s.pageKey, child: const ProviderRankingScreen())),
      GoRoute(path: AppRoutes.reasoningPanel, pageBuilder: (_, s) => fadeSlidePage(key: s.pageKey, child: const ReasoningDrawerScreen())),
      GoRoute(path: AppRoutes.priceBreakdown, pageBuilder: (_, s) => fadeSlidePage(key: s.pageKey, child: const PriceBreakdownScreen())),
      GoRoute(path: AppRoutes.bookingConfirmed, pageBuilder: (_, s) => fadeSlidePage(key: s.pageKey, child: const BookingConfirmedScreen())),
      GoRoute(path: AppRoutes.bookings, pageBuilder: (_, s) => fadeSlidePage(key: s.pageKey, child: const BookingHistoryScreen())),
      GoRoute(path: AppRoutes.feedback, pageBuilder: (_, s) => fadeSlidePage(key: s.pageKey, child: const FeedbackScreen())),
      GoRoute(path: AppRoutes.dispute, pageBuilder: (_, s) => fadeSlidePage(key: s.pageKey, child: const DisputeScreen())),
      GoRoute(path: AppRoutes.liveTracking, pageBuilder: (_, s) => fadeSlidePage(key: s.pageKey, child: const LiveTrackingScreen())),
      GoRoute(path: AppRoutes.bookingDetail, pageBuilder: (_, s) => fadeSlidePage(key: s.pageKey, child: const BookingDetailScreen())),
      GoRoute(
        path: AppRoutes.chatMessaging,
        pageBuilder: (_, s) => fadeSlidePage(
          key: s.pageKey,
          child: ChatMessagingScreen(bookingId: s.extra as String?),
        ),
      ),
      GoRoute(path: AppRoutes.profile, pageBuilder: (_, s) => fadeSlidePage(key: s.pageKey, child: const ProfileScreen())),
      GoRoute(path: AppRoutes.mapView, pageBuilder: (_, s) => fadeSlidePage(key: s.pageKey, child: const MapViewScreen())),
      GoRoute(path: AppRoutes.providerProfile, pageBuilder: (_, s) => fadeSlidePage(key: s.pageKey, child: const ProviderProfileScreen())),
      GoRoute(path: AppRoutes.providerDashboard, pageBuilder: (_, s) => fadeSlidePage(key: s.pageKey, child: const ProviderDashboardScreen())),
      GoRoute(path: AppRoutes.providerEnRoute, pageBuilder: (_, s) => fadeSlidePage(key: s.pageKey, child: const ProviderEnRouteScreen())),
      GoRoute(path: AppRoutes.providerJobLeads, pageBuilder: (_, s) => fadeSlidePage(key: s.pageKey, child: const ProviderJobLeadsScreen())),
      GoRoute(path: AppRoutes.providerEarnings, pageBuilder: (_, s) => fadeSlidePage(key: s.pageKey, child: const ProviderEarningsScreen())),
      GoRoute(path: AppRoutes.providerWallet, pageBuilder: (_, s) => fadeSlidePage(key: s.pageKey, child: const ProviderWalletScreen())),
      GoRoute(path: AppRoutes.providerHistory, pageBuilder: (_, s) => fadeSlidePage(key: s.pageKey, child: const ProviderHistoryScreen())),
      GoRoute(path: AppRoutes.providerAccountProfile, pageBuilder: (_, s) => fadeSlidePage(key: s.pageKey, child: const ProviderAccountProfileScreen())),
      GoRoute(path: AppRoutes.providerSettings, pageBuilder: (_, s) => fadeSlidePage(key: s.pageKey, child: const ProviderSettingsScreen())),
      GoRoute(path: AppRoutes.lowConfidence, pageBuilder: (_, s) => fadeSlidePage(key: s.pageKey, child: const LowConfidenceScreen())),
      GoRoute(path: AppRoutes.login, pageBuilder: (_, s) => fadeSlidePage(key: s.pageKey, child: const AuthGate())),
      GoRoute(path: AppRoutes.noProviders, pageBuilder: (_, s) => fadeSlidePage(key: s.pageKey, child: const NoProvidersScreen())),
      GoRoute(path: AppRoutes.providerCancelled, pageBuilder: (_, s) => fadeSlidePage(key: s.pageKey, child: const ProviderCancelledScreen())),
      GoRoute(path: AppRoutes.disputeResolution, pageBuilder: (_, s) => fadeSlidePage(key: s.pageKey, child: const DisputeResolutionScreen())),
      GoRoute(path: AppRoutes.disputeResolving, pageBuilder: (_, s) => fadeSlidePage(key: s.pageKey, child: const DisputeResolvingScreen())),
      GoRoute(path: AppRoutes.confidenceMeter, pageBuilder: (_, s) => fadeSlidePage(key: s.pageKey, child: const ConfidenceMeterScreen())),
      GoRoute(path: AppRoutes.stressScenarios, pageBuilder: (_, s) => fadeSlidePage(key: s.pageKey, child: const StressScenariosScreen())),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri}')),
    ),
  );
});
