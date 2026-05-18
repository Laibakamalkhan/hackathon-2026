import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Onboarding screens
import '../../features/onboarding/screens/splash_screen.dart';
import '../../features/onboarding/screens/role_selection_screen.dart';
import '../../features/onboarding/screens/language_select_screen.dart';
import '../../features/onboarding/screens/phone_auth_screen.dart';
import '../../features/onboarding/screens/otp_verify_screen.dart';
import '../../features/onboarding/screens/setup_profile_screen.dart';

// Chat & Search screens
import '../../features/chat/screens/chat_home_screen.dart';
import '../../features/chat/screens/chat_active_screen.dart';
import '../../features/chat/screens/intent_confirm_screen.dart';
import '../../features/chat/screens/provider_ranking_screen.dart';
import '../../features/chat/screens/price_breakdown_screen.dart';
import '../../features/chat/screens/booking_confirmed_screen.dart';
import '../../features/chat/screens/browse_directory_screen.dart';

// Bookings & Dispute screens
import '../../features/bookings/screens/booking_history_screen.dart';
import '../../features/bookings/screens/booking_detail_screen.dart';
import '../../features/bookings/screens/booking_chat_screen.dart';
import '../../features/bookings/screens/feedback_screen.dart';
import '../../features/bookings/screens/dispute_screen.dart';
import '../../features/bookings/screens/dispute_resolution_screen.dart';

// Provider screens
import '../../features/provider/screens/provider_dashboard_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Onboarding & Registration flow
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/role-selection',
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: '/language-select',
      builder: (context, state) => const LanguageSelectScreen(),
    ),
    GoRoute(
      path: '/phone-auth',
      builder: (context, state) => const PhoneAuthScreen(),
    ),
    GoRoute(
      path: '/otp-verify',
      builder: (context, state) {
        final phone = state.uri.queryParameters['phone'] ?? '';
        return OTPVerifyScreen(phone: phone);
      },
    ),
    GoRoute(
      path: '/setup-profile',
      builder: (context, state) => const SetupProfileScreen(),
    ),

    // Main Portal (Seeker Home)
    GoRoute(
      path: '/home',
      builder: (context, state) => const ChatHomeScreen(),
    ),
    GoRoute(
      path: '/browse',
      builder: (context, state) => const BrowseDirectoryScreen(),
    ),

    // Interactive Search & Matchmaking pipeline
    GoRoute(
      path: '/chat-active',
      builder: (context, state) {
        final query = state.uri.queryParameters['query'] ?? '';
        return ChatActiveScreen(query: query);
      },
    ),
    GoRoute(
      path: '/intent-confirm',
      builder: (context, state) {
        final query = state.uri.queryParameters['query'] ?? '';
        return IntentConfirmScreen(query: query);
      },
    ),
    GoRoute(
      path: '/provider-ranking',
      builder: (context, state) {
        final service = state.uri.queryParameters['service'] ?? '';
        final providersJson = state.extra as List<dynamic>?;
        return ProviderRankingScreen(service: service, matchedProviders: providersJson);
      },
    ),
    GoRoute(
      path: '/price-breakdown',
      builder: (context, state) {
        final name = state.uri.queryParameters['name'] ?? '';
        final price = state.uri.queryParameters['price'] ?? '';
        final pid = state.uri.queryParameters['pid'] ?? 'P-01';
        final service = state.uri.queryParameters['service'] ?? 'General';
        return PriceBreakdownScreen(
          providerName: name, 
          basePrice: price, 
          providerId: pid, 
          serviceType: service
        );
      },
    ),
    GoRoute(
      path: '/booking-confirmed',
      builder: (context, state) {
        final provider = state.uri.queryParameters['provider'] ?? '';
        final total = state.uri.queryParameters['total'] ?? '';
        return BookingConfirmedScreen(providerName: provider, totalPrice: total);
      },
    ),

    // Post-Booking Tracking, Feedback & Disputes
    GoRoute(
      path: '/history',
      builder: (context, state) => const BookingHistoryScreen(),
    ),
    GoRoute(
      path: '/booking-detail',
      builder: (context, state) {
        final id = state.uri.queryParameters['id'] ?? '';
        final provider = state.uri.queryParameters['provider'] ?? '';
        final price = state.uri.queryParameters['price'] ?? '';
        return BookingDetailScreen(bookingId: id, providerName: provider, price: price);
      },
    ),
    GoRoute(
      path: '/booking-chat',
      builder: (context, state) {
        final id = state.uri.queryParameters['id'] ?? '';
        final name = state.uri.queryParameters['name'] ?? '';
        return BookingChatScreen(bookingId: id, providerName: name);
      },
    ),
    GoRoute(
      path: '/feedback',
      builder: (context, state) {
        final bid = state.uri.queryParameters['bid'] ?? '';
        return FeedbackScreen(bookingId: bid);
      },
    ),
    GoRoute(
      path: '/dispute',
      builder: (context, state) {
        final id = state.uri.queryParameters['id'] ?? '';
        final reason = state.uri.queryParameters['reason'];
        return DisputeScreen(bookingId: id, initialReason: reason);
      },
    ),
    GoRoute(
      path: '/dispute-resolution',
      builder: (context, state) {
        final id = state.uri.queryParameters['id'] ?? '';
        final category = state.uri.queryParameters['category'] ?? '';
        final details = state.uri.queryParameters['details'] ?? '';
        return DisputeResolutionScreen(bookingId: id, category: category, details: details);
      },
    ),

    // Provider Side Interface
    GoRoute(
      path: '/provider-dashboard',
      builder: (context, state) => const ProviderDashboardScreen(),
    ),
  ],
  errorBuilder: (context, state) =>
      Scaffold(body: Center(child: Text("Route error: ${state.error}"))),
);
