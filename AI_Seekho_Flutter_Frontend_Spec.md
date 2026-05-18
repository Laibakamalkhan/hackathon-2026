# 🤖 AI Seekho — Flutter Frontend Specification
### Complete UI/UX & Screen Navigation Guide for Antigravity

**Based on:** Figma Design Code (Onboarding_Flow_Design.zip) + Blueprint Analysis  
**Stack:** Flutter 3.x · Riverpod 2.x · GoRouter · Firebase  
**Design System:** French Porcelain + Glass Morphism (see Section 1)

---

## TABLE OF CONTENTS

1. [Design System — Flutter Translation](#1-design-system--flutter-translation)
2. [App Architecture & Folder Structure](#2-app-architecture--folder-structure)
3. [Complete Screen Inventory (37 screens)](#3-complete-screen-inventory)
4. [Navigation Architecture (GoRouter)](#4-navigation-architecture--gorouter)
5. [Consumer Flow — Screen-by-Screen Specs](#5-consumer-flow--screen-by-screen-specs)
6. [Provider Flow — Screen-by-Screen Specs](#6-provider-flow--screen-by-screen-specs)
7. [Shared Components Library](#7-shared-components-library)
8. [Missing Screens — Build These](#8-missing-screens--build-these)
9. [Navigation Fixes Required](#9-navigation-fixes-required)
10. [pubspec.yaml Dependencies](#10-pubspecyaml-dependencies)

---

# 1. DESIGN SYSTEM — FLUTTER TRANSLATION

This section translates the Figma design system exactly into Flutter `ThemeData` and reusable constants. Every screen MUST use these values. No hardcoded colors or sizes anywhere else.

## 1.1 Color Palette

```dart
// lib/app/theme.dart

class AppColors {
  // === BACKGROUNDS ===
  static const bgPrimary      = Color(0xFFF5F4F7); // French Porcelain — consumer screens
  static const bgSecondary    = Color(0xFFEBDBD3); // Hudson — warm blush beige
  static const bgDark         = Color(0xFF1F1F1F); // Umbra — provider screens

  // === ACCENT COLORS ===
  static const lavender       = Color(0xFFBAC8E0); // Penna — AI elements, primary actions
  static const sand           = Color(0xFFD0BEA3); // Country Rubble — warm tan
  static const sage           = Color(0xFF8F917C); // Farmer's Market — muted olive

  // === TEXT ===
  static const textPrimary    = Color(0xFF1F1F1F); // near-black
  static const textSecondary  = Color(0xFF7B7080); // muted warm grey
  static const textOnDark     = Color(0xFFF5F4F7); // light on dark backgrounds

  // === FUNCTIONAL ===
  static const success        = Color(0xFFA8D5B5); // soft sage green
  static const warning        = Color(0xFFF5C97A); // warm amber
  static const error          = Color(0xFFE8A0A0); // soft coral
  static const urgent         = Color(0xFFF5B8A0); // warm peach-coral

  // === GRADIENTS ===
  static const primaryGradient = LinearGradient(
    colors: [lavender, sand],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const darkCardBg = Color(0x0FFFFFFF); // rgba(255,255,255,0.06) — provider cards
}
```

## 1.2 Glass Morphism — Reusable Box Decoration

```dart
// lib/shared/widgets/glass_card.dart

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? borderColor;

  const GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 24,
    this.borderColor,
  });

  static BoxDecoration get decoration => BoxDecoration(
    color: const Color(0xA6FFFFFF), // rgba(255,255,255,0.65)
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: const Color(0xCCFFFFFF), // rgba(255,255,255,0.8)
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF1F1F1F).withOpacity(0.06),
        blurRadius: 24,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // For dark (provider) screens
  static BoxDecoration get darkDecoration => BoxDecoration(
    color: const Color(0x0FFFFFFF), // rgba(255,255,255,0.06)
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: const Color(0x1AFFFFFF), // rgba(255,255,255,0.1)
      width: 1,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding,
          decoration: decoration,
          child: child,
        ),
      ),
    );
  }
}
```

## 1.3 Typography

```dart
// lib/app/theme.dart

// Primary font: Nunito (weights 200–900)
// Urdu font: Noto Nastaliq Urdu

class AppTextStyles {
  static const heading1 = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 26,
    fontWeight: FontWeight.w800,  // extrabold
    color: AppColors.textPrimary,
  );
  static const heading2 = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  static const body = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );
  static const bodyBold = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  static const caption = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
  static const urdu = TextStyle(
    fontFamily: 'NotoNastaliqUrdu',
    fontSize: 16,
    color: AppColors.textPrimary,
  );
  static const buttonLabel = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
}
```

## 1.4 Border Radius Constants

```dart
class AppRadius {
  static const double card      = 24.0;   // cards
  static const double cardLarge = 28.0;   // bottom sheets, large cards
  static const double button    = 50.0;   // rounded-full buttons
  static const double input     = 16.0;   // text inputs
  static const double chip      = 50.0;   // filter chips
}
```

## 1.5 Decorative Blob Widget (used on every screen)

```dart
// lib/shared/widgets/blob_background.dart
// Every screen has these ambient gradient circles for depth

class BlobBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 40, left: -80,
          child: _blob(180, AppColors.lavender, 0.25),
        ),
        Positioned(
          top: 0, right: -80,
          child: _blob(180, AppColors.bgSecondary, 0.25),
        ),
      ],
    );
  }

  Widget _blob(double size, Color color, double opacity) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(opacity),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: const SizedBox.expand(),
      ),
    );
  }
}
```

## 1.6 Primary Button Widget

```dart
// lib/shared/widgets/primary_button.dart

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled && !isLoading ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: isEnabled
              ? const LinearGradient(
                  colors: [AppColors.lavender, AppColors.sand],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: isEnabled ? null : AppColors.lavender.withOpacity(0.3),
          borderRadius: BorderRadius.circular(AppRadius.button),
          boxShadow: isEnabled
              ? [BoxShadow(
                  color: AppColors.lavender.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                )]
              : null,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.textPrimary,
                  ),
                )
              : Text(label, style: AppTextStyles.buttonLabel),
        ),
      ),
    );
  }
}
```

---

# 2. APP ARCHITECTURE & FOLDER STRUCTURE

```
lib/
├── main.dart
├── app/
│   ├── app.dart                          # MaterialApp with ThemeData
│   ├── router.dart                       # GoRouter — ALL routes defined here
│   └── theme.dart                        # AppColors, AppTextStyles, AppRadius
│
├── core/
│   ├── api/
│   │   ├── api_client.dart               # Dio singleton with auth interceptor
│   │   └── api_endpoints.dart
│   ├── firebase/
│   │   ├── firebase_options.dart
│   │   └── firestore_service.dart
│   └── constants/
│       ├── cities_areas.dart             # Map<city, List<area>>
│       └── service_categories.dart       # 8 categories with metadata
│
├── shared/
│   ├── widgets/
│   │   ├── glass_card.dart               # GlassCard (used everywhere)
│   │   ├── blob_background.dart          # Ambient gradient blobs
│   │   ├── primary_button.dart           # Main CTA button
│   │   ├── bottom_nav.dart               # Consumer bottom navigation
│   │   ├── provider_bottom_nav.dart      # Provider bottom navigation (dark)
│   │   ├── agent_trace_panel.dart        # ADK reasoning trace (WOW feature)
│   │   └── confidence_badge.dart         # AI confidence meter chip
│   └── models/                           # Shared data models
│
├── features/
│   ├── onboarding/
│   │   ├── screens/
│   │   │   ├── splash_screen.dart
│   │   │   ├── role_selection_screen.dart
│   │   │   ├── language_select_screen.dart
│   │   │   ├── phone_auth_screen.dart
│   │   │   ├── otp_verify_screen.dart
│   │   │   ├── setup_profile_screen.dart  # FIXED: City + Area + Address
│   │   │   ├── tutorial_1_screen.dart
│   │   │   └── tutorial_2_screen.dart
│   │   └── providers/
│   │       └── onboarding_provider.dart
│   │
│   ├── chat/
│   │   ├── screens/
│   │   │   ├── chat_home_screen.dart      # Home (empty state)
│   │   │   ├── chat_active_screen.dart    # AI processing screen
│   │   │   ├── intent_confirm_screen.dart
│   │   │   ├── provider_ranking_screen.dart
│   │   │   ├── reasoning_drawer_screen.dart
│   │   │   ├── price_breakdown_screen.dart
│   │   │   └── booking_confirmed_screen.dart
│   │   ├── widgets/
│   │   │   ├── message_bubble.dart
│   │   │   ├── category_chip.dart
│   │   │   ├── provider_card.dart
│   │   │   └── price_breakdown_card.dart
│   │   └── providers/
│   │       ├── chat_provider.dart
│   │       └── intent_provider.dart
│   │
│   ├── bookings/
│   │   ├── screens/
│   │   │   ├── booking_history_screen.dart
│   │   │   ├── booking_detail_screen.dart  # FIXED: Chat + Call wired
│   │   │   ├── booking_chat_screen.dart    # NEW: In-app chat
│   │   │   ├── live_tracking_screen.dart
│   │   │   ├── feedback_screen.dart        # FIXED: Smart routing on submit
│   │   │   ├── dispute_screen.dart
│   │   │   └── dispute_resolution_screen.dart
│   │   └── providers/
│   │       └── booking_provider.dart
│   │
│   ├── browse/
│   │   ├── screens/
│   │   │   ├── browse_directory_screen.dart  # FIXED: All 8 categories
│   │   │   ├── provider_profile_screen.dart
│   │   │   └── map_view_screen.dart
│   │   └── providers/
│   │       └── browse_provider.dart
│   │
│   ├── profile/
│   │   └── screens/
│   │       └── profile_screen.dart
│   │
│   ├── edge_cases/
│   │   ├── screens/
│   │   │   ├── low_confidence_screen.dart
│   │   │   ├── no_providers_screen.dart
│   │   │   └── provider_cancelled_screen.dart
│   │
│   └── provider_app/                      # PROVIDER SIDE (dark theme)
│       ├── screens/
│       │   ├── provider_dashboard_screen.dart
│       │   ├── provider_job_leads_screen.dart
│       │   ├── provider_en_route_screen.dart
│       │   ├── provider_earnings_screen.dart
│       │   ├── provider_wallet_screen.dart
│       │   ├── provider_performance_screen.dart
│       │   └── provider_settings_screen.dart
│       └── providers/
│           └── provider_app_provider.dart
```

---

# 3. COMPLETE SCREEN INVENTORY

**Total: 37 screens** (35 from Figma + 2 new screens needed)

## Consumer Screens (28)

| # | Screen Name | Flutter File | Route | Status |
|---|---|---|---|---|
| 1 | Splash | `splash_screen.dart` | `/` | ✅ Exists |
| 2 | Role Selection | `role_selection_screen.dart` | `/role-select` | ✅ Exists |
| 3 | Language Select | `language_select_screen.dart` | `/language-select` | ✅ Exists |
| 4 | Phone Auth | `phone_auth_screen.dart` | `/phone-auth` | ✅ Exists |
| 5 | OTP Verify | `otp_verify_screen.dart` | `/otp-verify` | ✅ Exists |
| 6 | Setup Profile | `setup_profile_screen.dart` | `/setup-profile` | ⚠️ **NEEDS FIX** (area dropdown + address field missing) |
| 7 | Tutorial 1 | `tutorial_1_screen.dart` | `/tutorial-1` | ✅ Exists |
| 8 | Tutorial 2 | `tutorial_2_screen.dart` | `/tutorial-2` | ✅ Exists |
| 9 | Chat Home | `chat_home_screen.dart` | `/home` | ✅ Exists (8 categories needed) |
| 10 | Chat Active | `chat_active_screen.dart` | `/chat-active` | ✅ Exists |
| 11 | Intent Confirm | `intent_confirm_screen.dart` | `/intent-confirm` | ✅ Exists |
| 12 | Provider Ranking | `provider_ranking_screen.dart` | `/provider-ranking` | ⚠️ **NEEDS FIX** (reasoning btn only on #1) |
| 13 | Provider Profile | `provider_profile_screen.dart` | `/provider-profile` | ✅ Exists |
| 14 | Reasoning Drawer | `reasoning_drawer_screen.dart` | `/reasoning-panel` | ✅ Exists |
| 15 | Price Breakdown | `price_breakdown_screen.dart` | `/price-breakdown` | ✅ Exists |
| 16 | Booking Confirmed | `booking_confirmed_screen.dart` | `/booking-confirmed` | ✅ Exists |
| 17 | Booking History | `booking_history_screen.dart` | `/bookings` | ⚠️ **NEEDS FIX** (feedback → dispute routing) |
| 18 | Booking Detail | `booking_detail_screen.dart` | `/booking-detail` | ⚠️ **NEEDS FIX** (Chat/Call buttons dead) |
| 19 | **Booking Chat** | `booking_chat_screen.dart` | `/booking-chat` | 🆕 **NEW — BUILD THIS** |
| 20 | Live Tracking | `live_tracking_screen.dart` | `/live-tracking` | ✅ Exists |
| 21 | Feedback | `feedback_screen.dart` | `/feedback` | ⚠️ **NEEDS FIX** (no routing after submit) |
| 22 | Dispute | `dispute_screen.dart` | `/dispute` | ⚠️ **NEEDS FIX** (back button dead, no navigation) |
| 23 | Dispute Resolution | `dispute_resolution_screen.dart` | `/dispute-resolution` | ⚠️ **NEEDS FIX** (Accept → /bookings not wired) |
| 24 | Browse Directory | `browse_directory_screen.dart` | `/browse` | ⚠️ **NEEDS FIX** (only 8 categories, no reasons) |
| 25 | Map View | `map_view_screen.dart` | `/map-view` | ✅ Exists |
| 26 | Low Confidence | `low_confidence_screen.dart` | `/low-confidence` | ✅ Exists |
| 27 | No Providers | `no_providers_screen.dart` | `/no-providers` | ✅ Exists |
| 28 | Provider Cancelled | `provider_cancelled_screen.dart` | `/provider-cancelled` | ✅ Exists |

## Provider Screens (7)

| # | Screen Name | Flutter File | Route | Status |
|---|---|---|---|---|
| 29 | Provider Dashboard | `provider_dashboard_screen.dart` | `/provider-dashboard` | ✅ Exists |
| 30 | Provider Job Leads | `provider_job_leads_screen.dart` | `/provider-job-leads` | ✅ Exists |
| 31 | Provider En Route | `provider_en_route_screen.dart` | `/provider-en-route` | ✅ Exists |
| 32 | Provider Earnings | `provider_earnings_screen.dart` | `/provider-earnings` | ✅ Exists |
| 33 | Provider Wallet | `provider_wallet_screen.dart` | `/provider-wallet` | ✅ Exists |
| 34 | Provider Performance | `provider_performance_screen.dart` | `/provider-performance` | ✅ Exists |
| 35 | Provider Settings | `provider_settings_screen.dart` | `/provider-settings` | ✅ Exists |

## Utility Screens (2)

| # | Screen Name | Route | Notes |
|---|---|---|---|
| 36 | Profile Screen | `/profile` | ✅ Exists |
| 37 | **In-App Chat** | `/booking-chat` | 🆕 **NEW — BUILD THIS** |

---

# 4. NAVIGATION ARCHITECTURE — GOROUTER

```dart
// lib/app/router.dart

final appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final isLoggedIn = ref.read(authProvider).isLoggedIn;
    final isOnboarded = ref.read(authProvider).isOnboarded;
    final role = ref.read(authProvider).role; // 'consumer' | 'provider'

    // First launch → onboarding
    if (!isLoggedIn && !state.uri.toString().startsWith('/role-select') &&
        !_isOnboardingRoute(state.uri.toString())) {
      return '/';
    }

    // Logged in but not onboarded → profile setup
    if (isLoggedIn && !isOnboarded) return '/setup-profile';

    // Redirect provider to their dashboard
    if (isLoggedIn && isOnboarded && role == 'provider' && state.uri.toString() == '/') {
      return '/provider-dashboard';
    }

    // Redirect consumer to home
    if (isLoggedIn && isOnboarded && role == 'consumer' && state.uri.toString() == '/') {
      return '/home';
    }

    return null;
  },
  routes: [
    // ── ONBOARDING ──────────────────────────────────────────
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/role-select', builder: (_, __) => const RoleSelectionScreen()),
    GoRoute(path: '/language-select', builder: (_, __) => const LanguageSelectScreen()),
    GoRoute(path: '/phone-auth', builder: (_, __) => const PhoneAuthScreen()),
    GoRoute(path: '/otp-verify', builder: (_, __) => const OtpVerifyScreen()),
    GoRoute(path: '/setup-profile', builder: (_, __) => const SetupProfileScreen()),
    GoRoute(path: '/tutorial-1', builder: (_, __) => const Tutorial1Screen()),
    GoRoute(path: '/tutorial-2', builder: (_, __) => const Tutorial2Screen()),

    // ── CONSUMER MAIN APP ────────────────────────────────────
    ShellRoute(
      builder: (context, state, child) => ConsumerShell(child: child),
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const ChatHomeScreen()),
        GoRoute(path: '/bookings', builder: (_, __) => const BookingHistoryScreen()),
        GoRoute(path: '/browse', builder: (_, __) => const BrowseDirectoryScreen()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      ],
    ),

    // ── CONSUMER DEEP ROUTES (no bottom nav) ─────────────────
    GoRoute(path: '/chat-active', builder: (_, __) => const ChatActiveScreen()),
    GoRoute(path: '/intent-confirm', builder: (_, __) => const IntentConfirmScreen()),
    GoRoute(path: '/provider-ranking', builder: (_, __) => const ProviderRankingScreen()),
    GoRoute(path: '/provider-profile', builder: (_, state) {
      final providerId = state.uri.queryParameters['id'] ?? '';
      return ProviderProfileScreen(providerId: providerId);
    }),
    GoRoute(path: '/reasoning-panel', builder: (_, __) => const ReasoningDrawerScreen()),
    GoRoute(path: '/price-breakdown', builder: (_, __) => const PriceBreakdownScreen()),
    GoRoute(path: '/booking-confirmed', builder: (_, __) => const BookingConfirmedScreen()),
    GoRoute(path: '/booking-detail', builder: (_, state) {
      final bookingId = state.uri.queryParameters['id'] ?? '';
      return BookingDetailScreen(bookingId: bookingId);
    }),
    GoRoute(path: '/booking-chat', builder: (_, state) {     // 🆕 NEW
      final bookingId = state.uri.queryParameters['bookingId'] ?? '';
      final providerName = state.uri.queryParameters['providerName'] ?? '';
      return BookingChatScreen(bookingId: bookingId, providerName: providerName);
    }),
    GoRoute(path: '/live-tracking', builder: (_, state) {
      final bookingId = state.uri.queryParameters['id'] ?? '';
      return LiveTrackingScreen(bookingId: bookingId);
    }),
    GoRoute(path: '/feedback', builder: (_, state) {
      final bookingId = state.uri.queryParameters['bookingId'] ?? '';
      return FeedbackScreen(bookingId: bookingId);
    }),
    GoRoute(path: '/dispute', builder: (_, state) {
      final bookingId = state.uri.queryParameters['bookingId'] ?? '';
      final prefillType = state.uri.queryParameters['type'];
      return DisputeScreen(bookingId: bookingId, prefillType: prefillType);
    }),
    GoRoute(path: '/dispute-resolution', builder: (_, state) {
      final disputeId = state.uri.queryParameters['disputeId'] ?? '';
      return DisputeResolutionScreen(disputeId: disputeId);
    }),
    GoRoute(path: '/map-view', builder: (_, __) => const MapViewScreen()),
    GoRoute(path: '/low-confidence', builder: (_, __) => const LowConfidenceScreen()),
    GoRoute(path: '/no-providers', builder: (_, __) => const NoProvidersScreen()),
    GoRoute(path: '/provider-cancelled', builder: (_, __) => const ProviderCancelledScreen()),

    // ── PROVIDER APP ─────────────────────────────────────────
    ShellRoute(
      builder: (context, state, child) => ProviderShell(child: child),
      routes: [
        GoRoute(path: '/provider-dashboard', builder: (_, __) => const ProviderDashboardScreen()),
        GoRoute(path: '/provider-job-leads', builder: (_, __) => const ProviderJobLeadsScreen()),
        GoRoute(path: '/provider-earnings', builder: (_, __) => const ProviderEarningsScreen()),
        GoRoute(path: '/provider-performance', builder: (_, __) => const ProviderPerformanceScreen()),
      ],
    ),
    GoRoute(path: '/provider-en-route', builder: (_, state) {
      final jobId = state.uri.queryParameters['jobId'] ?? '';
      return ProviderEnRouteScreen(jobId: jobId);
    }),
    GoRoute(path: '/provider-wallet', builder: (_, __) => const ProviderWalletScreen()),
    GoRoute(path: '/provider-settings', builder: (_, __) => const ProviderSettingsScreen()),
  ],
);
```

---

# 5. CONSUMER FLOW — SCREEN-BY-SCREEN SPECS

Each screen spec includes: what to show, what's interactive, where each button navigates, and what state it receives.

---

## SCREEN 1: Splash Screen `/`
**File:** `splash_screen.dart`

| Element | Spec |
|---|---|
| Logo | AI Seekho robot SVG centered, 120×120px |
| Tagline | "Apni Zindagi Asaan Karo" — Nunito extrabold 22px |
| Background | `AppColors.bgPrimary` + BlobBackground |
| Auto-navigate | After 2.5s → check auth state → `/role-select` (new user) OR `/home` (returning) |
| Animation | Logo fades in (opacity 0→1, 600ms), tagline slides up (y 20→0, delay 300ms) |

---

## SCREEN 2: Role Selection `/role-select`
**File:** `role_selection_screen.dart`

| Element | Spec |
|---|---|
| Title | "Aap kaun hain?" |
| Option A | "Service Seeker 🏠" card — tap selects, border becomes `AppColors.lavender` |
| Option B | "Service Provider 🔧" card — tap selects, border becomes `AppColors.lavender` |
| CTA | "Aage Barho →" button — disabled until selection — `PrimaryButton` |
| On CTA tap | → `/language-select` (pass role in provider state) |

---

## SCREEN 3: Language Select `/language-select`
**File:** `language_select_screen.dart`

| Element | Spec |
|---|---|
| Options | Roman Urdu · اردو · English — 3 cards, single-select |
| CTA | → `/phone-auth` on tap |
| Persist | Save selection to `Hive.box('prefs').put('language', ...)` immediately on selection |

---

## SCREEN 4: Phone Auth `/phone-auth`
**File:** `phone_auth_screen.dart`

| Element | Spec |
|---|---|
| Input | Pakistani phone format: `+92-XXX-XXXXXXX` — autofill +92 prefix |
| Validation | Must be 10 digits after +92 |
| CTA | "OTP Bhejein" → calls Firebase Auth phone sign-in → navigate `/otp-verify` |
| Loading state | Spinner inside `PrimaryButton` while Firebase call is pending |

---

## SCREEN 5: OTP Verify `/otp-verify`
**File:** `otp_verify_screen.dart`

| Element | Spec |
|---|---|
| Input | 6 individual digit boxes (pin_code_fields package) |
| Auto-submit | Auto-submit when 6th digit entered |
| Error state | Show "OTP galat hai. Dobara try karein." in `AppColors.error` |
| Resend | "OTP dobara bhejein" link, disabled for 60 seconds with countdown |
| Success | Animate checkmark → navigate to `/setup-profile` (new user) or `/home` (returning) |

---

## SCREEN 6: Setup Profile `/setup-profile` ⚠️ NEEDS FIX
**File:** `setup_profile_screen.dart`

**Current Issue:** Only has name + city dropdown + free-text area. Missing: cascading area dropdown and full address field.

**Required Fields (in order):**

```dart
// 1. Full Name
TextField(
  decoration: InputDecoration(
    hintText: 'Jaise: Ayesha Malik',
    labelText: 'Aap ka Naam',
  ),
)

// 2. City Dropdown (bottom sheet style — matching existing design)
// Cities: Islamabad, Karachi, Lahore, Rawalpindi, Peshawar, Faisalabad, Quetta, Hyderabad
// On city select → reload areas list

// 3. Area Dropdown (bottom sheet, city-dependent)
// Islamabad: G-6, G-7, G-8, G-9, G-10, G-11, G-12, G-13, F-6, F-7, F-8, F-10, F-11, I-8, I-9, I-10, Blue Area, Bahria Town
// Karachi: DHA, Clifton, Gulshan-e-Iqbal, Nazimabad, North Nazimabad, PECHS, Korangi, Malir
// Lahore: DHA, Gulberg, Model Town, Johar Town, Garden Town, Faisal Town, Bahria Town
// Rawalpindi: Saddar, Chaklala, Gulraiz, Westridge, Satellite Town
// Peshawar: Hayatabad, University Town, Saddar, Gulbahar

// 4. Full Address (free text)
TextField(
  hintText: 'Poora Pata — jaise House 12, Street 4, G-13/1',
  maxLines: 2,
  maxLength: 200,
)
```

**Data model to save:**
```dart
// Firestore users/{uid} update:
{
  'name': name,
  'location': {
    'city': selectedCity,
    'area': selectedArea,
    'full_address': addressText,
    'lat': 0.0, // resolved later by geocoding
    'lng': 0.0,
  },
  'language_preference': languageFromPreviousScreen,
}
```

**CTA:** Enabled only when all 4 fields are filled → Navigate `/tutorial-1`

---

## SCREEN 7 & 8: Tutorials `/tutorial-1`, `/tutorial-2`
**Files:** `tutorial_1_screen.dart`, `tutorial_2_screen.dart`

| Screen | Content |
|---|---|
| Tutorial 1 | Illustration + "Kisi bhi zaban mein type karein" + subtitle about Roman Urdu/Urdu/English |
| Tutorial 2 | Illustration + "Book karein, track karein — sab ek jagah" |
| Navigation | Tutorial 1 → "Aagla →" → Tutorial 2 → "Shuru Karein →" → `/home` |

---

## SCREEN 9: Chat Home (Empty State) `/home`
**File:** `chat_home_screen.dart`

**Current State:** 6 categories in horizontal scroll. Needs all 8 categories.

**Category List (full 8):**
```dart
const serviceCategories = [
  ServiceCategory(icon: '🌬️', label: 'AC Repair',    urdu: 'AC مرمت',     enum: 'ac_repair'),
  ServiceCategory(icon: '🔧', label: 'Plumber',      urdu: 'پلمبر',        enum: 'plumbing'),
  ServiceCategory(icon: '⚡', label: 'Electrician',  urdu: 'بجلی',         enum: 'electrical'),
  ServiceCategory(icon: '📚', label: 'Tutor',        urdu: 'ٹیوشن',        enum: 'tutoring'),
  ServiceCategory(icon: '💆', label: 'Beauty',       urdu: 'بیوٹی',        enum: 'beauty'),
  ServiceCategory(icon: '🚗', label: 'Driver',       urdu: 'ڈرائیور',      enum: 'driving'),
  ServiceCategory(icon: '🔩', label: 'Mechanic',     urdu: 'میکینک',       enum: 'mechanics'),
  ServiceCategory(icon: '🏠', label: 'Home Help',    urdu: 'گھریلو مدد',   enum: 'general_home'),
];
```

**Quick action chips (4 most common):** AC Repair · Plumber · Electrician · Kuch aur?

**Chat input bar:** Mic button + text input + send button  
**Voice:** Mic tap → recording animation (2s mock) → navigate to `/chat-active`  
**Send text:** Navigate to `/chat-active` (pass message as route extra)  
**Category tap:** Navigate to `/chat-active` (pass category as route extra)  

**Bottom Navigation:**

```dart
// ConsumerBottomNav — 4 tabs
// [💬 Chat → /home] [📋 Bookings → /bookings] [🔍 Browse → /browse] [👤 Profile → /profile]
// Active tab uses gradient background pill
// Inactive tabs use textSecondary color
```

---

## SCREEN 10: Chat Active `/chat-active`
**File:** `chat_active_screen.dart`

Multi-agent orchestration visualization screen.

**Agent Pipeline (5 stages):**
```
1. IntentAgent     → "Samajh raha hoon..." → "AC Repair, G-13, Kal Subah — 94% ✓"
2. MatchingAgent   → "23 providers dhundh raha hoon..." → "3 providers mile ✓"
3. PricingAgent    → "Prices calculate ho rahe hain..." → "PKR 880 best quote ✓"
4. BookingAgent    → (activates after user confirms)
5. FollowUpAgent   → (activates after booking confirmed)
```

**Each agent card shows:**
- Agent name + icon
- Status: `running` (pulse animation) → `complete` (green checkmark)
- Duration in ms when complete
- Key output text

**After agents 1-3 complete:** Auto-navigate to `/intent-confirm`

---

## SCREEN 11: Intent Confirm `/intent-confirm`
**File:** `intent_confirm_screen.dart`

| Element | Spec |
|---|---|
| AI bubble | "Mujhe samajh aaya — aap ko chahiye:" |
| Intent chips | Service Type, Location, Time, Urgency, Budget — each editable |
| Chip edit | Tap any chip → inline edit or bottom sheet → re-run AI → back to `/chat-active` |
| Confidence meter | Linear progress bar — e.g. "94% — sab samajh aaya ✓" |
| "Bilkul Sahi" | → navigate to `/provider-ranking` |
| "Badlo" | → back to `/chat-active` for re-input |

---

## SCREEN 12: Provider Ranking `/provider-ranking`
**File:** `provider_ranking_screen.dart`

**Current Issue:** "AI ne kyun chuna?" button only appears on rank #1 card.

**Fix:** Show "AI ne kyun chuna?" on ALL provider cards (not just #1). It is a key trust feature.

**Also add to Browse directory screen:** When accessed from Browse, show "Why AI Seekho for this category" blurb under the category header.

**Each provider card contains:**
- Rank emoji (🥇🥈🥉)
- Provider name + initials avatar
- Rating ⭐ + review count
- Distance chip + On-time % chip + Specialty chip
- Price + Next available slot
- 3 buttons:
  - "View Full Profile" → `/provider-profile?id={pid}`
  - "🤖 AI ne kyun chuna?" → `/reasoning-panel` (ALL cards, not just #1)
  - "Book Now →" → `/price-breakdown`

**Budget pill at bottom:** "💰 Lowest option: Raza Services — PKR 620"

---

## SCREEN 13: Provider Profile `/provider-profile`
**File:** `provider_profile_screen.dart`

| Element | Spec |
|---|---|
| Header | Avatar initials + name + verified badge + rating |
| Specialization tags | e.g. "Inverter AC", "Split AC", "Central AC" |
| AI Trust Score | Shown as a score bar (e.g. 92/100) with reasoning |
| Stats row | On-time %, Cancellation rate, Jobs done, Response time |
| Reviews | Last 3 reviews with date + rating |
| Available slots | Next 3 available time slots |
| CTA | "Is Provider ko Book Karein →" → `/price-breakdown?providerId={pid}` |
| Back | → `/provider-ranking` |

---

## SCREEN 14: Reasoning Drawer `/reasoning-panel`
**File:** `reasoning_drawer_screen.dart`

**This is a bottom sheet / full-screen drawer that shows the ADK trace.**

| Element | Spec |
|---|---|
| Title | "🤖 AI ne yeh faisla kyun kiya?" |
| Step cards | Each ADK agent step: name + action + reasoning text + latency ms |
| Urdu reasoning | Provider-specific selection reason in Roman Urdu |
| Score bars | 8-factor breakdown as mini progress bars |
| Close button | → back to `/provider-ranking` |

---

## SCREEN 15: Price Breakdown `/price-breakdown`
**File:** `price_breakdown_screen.dart`

| Element | Spec |
|---|---|
| Line items | Base fee, Visit fee, Distance, Urgency surcharge, Budget discount |
| Total | Bold PKR amount |
| "Doosra Provider Dekhein" | → `context.pop()` back to `/provider-ranking` |
| "Booking Confirm Karein" | → POST to `/api/v1/booking/confirm` → navigate `/booking-confirmed` |
| Budget alternative | Show if user is budget-sensitive: "Hassan offers PKR 750 — 30 min later" |

---

## SCREEN 16: Booking Confirmed `/booking-confirmed`
**File:** `booking_confirmed_screen.dart`

| Element | Spec |
|---|---|
| Animation | ✅ checkmark scale-in animation + confetti burst |
| Booking ID | #BSK-XXXX-XXXX |
| Provider name + time | "Ali AC Services — Kal 10:00 AM" |
| "Reminder set" badge | Shows T-1h reminder confirmation |
| Buttons | "Track Live 📍" → `/live-tracking` |
|  | "Meri Bookings" → `/bookings` |
|  | "Share Receipt" → share sheet (Flutter Share plugin) |

---

## SCREEN 17: Booking History `/bookings`
**File:** `booking_history_screen.dart`

**Tabs:** All · Active · Mukammal · Cancelled

**Active booking card shows:**
- Provider + service + time
- "Track Live" button → `/live-tracking?id={bid}`
- "View Details" → `/booking-detail?id={bid}`
- Status pulse dot (animated, green)

**Completed booking card shows:**
- Provider + service + amount + date
- Star rating already given (if any)
- **If no feedback given:** "Feedback Dein" button → `/feedback?bookingId={bid}`
- **If dispute filed:** "Dispute Dekhein" badge → `/dispute-resolution?disputeId={did}`
- "View Details" → `/booking-detail?id={bid}`

---

## SCREEN 18: Booking Detail `/booking-detail` ⚠️ NEEDS FIX
**File:** `booking_detail_screen.dart`

**Current Issue:** Chat and Call buttons have no `onTap` handlers.

**Fix:**

```dart
// CALL button
onTap: () async {
  final Uri phoneUri = Uri(scheme: 'tel', path: provider.phone);
  if (await canLaunchUrl(phoneUri)) {
    await launchUrl(phoneUri);
  }
},

// CHAT button  
onTap: () => context.push(
  '/booking-chat?bookingId=${booking.id}&providerName=${provider.name}'
),
```

**Provider info shown:** Name, avatar, rating, verified badge  
**Call button:** Uses `url_launcher` — `tel:` scheme → opens phone dialer  
**Chat button:** → `/booking-chat?bookingId={bid}&providerName={name}`

**Action buttons at bottom:**
- "Track Live 📍" → `/live-tracking?id={bid}`
- "Reschedule" → reschedule modal (date picker)
- "Cancel" → confirmation modal → DELETE booking → `/bookings`

---

## SCREEN 19: Booking Chat `/booking-chat` 🆕 NEW SCREEN
**File:** `booking_chat_screen.dart`

**This screen does NOT exist yet. Build from scratch.**

**Design spec:**
- Background: `AppColors.bgPrimary` + BlobBackground
- AppBar: Provider name + "Active Booking" subtitle + back arrow
- Messages: Chat bubble UI using `flutter_chat_ui` package
  - User messages: right-aligned, `AppColors.lavender` bubble
  - Provider messages: left-aligned, white glass card bubble
- System messages (centered, grey): "Booking confirmed — Ali arrives tomorrow at 10:00 AM"
- Input bar (bottom, glass card): Text field + send button
- Timestamps on each message

**Data:** Firebase Realtime Database  
```
Path: /chats/{bookingId}/messages/{msgId}
Fields: senderId, senderName, text, timestamp (epoch ms), isRead
```

**Auto first message:** On screen open, if no messages exist, create first system message:
```
"Booking #BSK-XXXX confirmed ✅ — {providerName} will arrive on {date} at {time}"
```

**Navigation:** Back arrow → `context.pop()` to `/booking-detail`

---

## SCREEN 20: Live Tracking `/live-tracking`
**File:** `live_tracking_screen.dart`

| Element | Spec |
|---|---|
| Map placeholder | Static map tile OR google_maps_flutter widget showing provider + user pins |
| ETA card | "Provider ~15 minutes away" — updates in real-time from Firestore |
| Stage timeline | Confirmed → En Route → Arrived → In Progress → Completed |
| Bottom sheet | Provider name + call button + service info |
| "Cancel Booking" | Only visible if status is `confirmed` or `en_route` — shows confirmation modal |
| Auto-navigate | On status = `completed` → `/feedback?bookingId={id}` |

---

## SCREEN 21: Feedback Screen `/feedback` ⚠️ NEEDS FIX
**File:** `feedback_screen.dart`

**Current Issue:** Submit button has no `onTap` handler and no navigation.

**Submit logic:**

```dart
void onSubmitFeedback() async {
  // 1. Submit to backend
  await bookingProvider.submitFeedback(
    bookingId: widget.bookingId,
    rating: rating,
    comment: feedbackText,
  );

  // 2. Smart routing
  if (_isComplaint(rating, feedbackText)) {
    context.go('/dispute?bookingId=${widget.bookingId}&type=${_detectType(feedbackText)}');
  } else {
    context.go('/bookings');
    // Show success snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Shukriya! Feedback submit ho gaya ✅'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}

bool _isComplaint(int rating, String? comment) {
  if (rating <= 2) return true;
  final keywords = ['nahi aaya', 'late', 'bura', 'ganda', 'paisa',
                    'zyada liya', 'worst', 'bad', 'poor', 'complaint', 'fraud'];
  final lower = (comment ?? '').toLowerCase();
  return keywords.any((kw) => lower.contains(kw));
}
```

---

## SCREEN 22: Dispute Screen `/dispute` ⚠️ NEEDS FIX
**File:** `dispute_screen.dart`

**Current Issues:**
1. Back arrow has no `onTap`
2. Submit button has no navigation

**Fixes:**

```dart
// Back button
onTap: () => context.pop(),

// Submit dispute button
onTap: () async {
  final disputeId = await disputeProvider.submitDispute(
    bookingId: widget.bookingId,
    type: selectedType,
    description: description,
    evidencePhotos: uploadedPhotos,
  );
  context.go('/dispute-resolution?disputeId=$disputeId');
},
```

**Evidence photo upload:** `image_picker` → `firebase_storage`  
**Add-photo button:** "+📷 Tasveer Lagaein" — opens ImagePicker (gallery or camera)

---

## SCREEN 23: Dispute Resolution `/dispute-resolution` ⚠️ NEEDS FIX
**File:** `dispute_resolution_screen.dart`

**Current Issue:** "Accept Resolution" button has no navigation.

```dart
// Accept Resolution
onTap: () {
  context.go('/bookings');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Resolution accept ho gaya. Refund 2-3 din mein process hoga.'))
  );
},

// Escalate to Human
onTap: () async {
  await disputeProvider.escalateToHuman(disputeId);
  context.go('/bookings');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Ticket #XYZ raise ho gaya — 24 ghante mein jawab milega.'))
  );
},
```

**Show ADK trace panel** (same `AgentTracePanel` widget from chat flow) — shows DisputeAgent reasoning steps. This is a strong hackathon demo moment.

---

## SCREEN 24: Browse Directory `/browse` ⚠️ NEEDS FIX
**File:** `browse_directory_screen.dart`

**Current Issue:** Categories list doesn't match the 8 official categories from Blueprint. Missing category descriptions.

**Fix — All 8 categories with descriptions:**

```dart
const browseCategories = [
  BrowseCategory(
    icon: '🌬️', label: 'AC Repair', bg: AppColors.lavender,
    reason: 'Specialist technicians — inverter, split, window AC experts',
  ),
  BrowseCategory(
    icon: '🔧', label: 'Plumber', bg: Color(0xFFEBDBD3),
    reason: 'Emergency-rated plumbers — waqt par, bharosa ke saath',
  ),
  BrowseCategory(
    icon: '⚡', label: 'Electrician', bg: AppColors.sand,
    reason: 'Verified electricians — zero cancellation record wale',
  ),
  BrowseCategory(
    icon: '📚', label: 'Tutor', bg: AppColors.success,
    reason: 'Subject-matched tutors — Matric, FSc, O/A-Levels',
  ),
  BrowseCategory(
    icon: '💆', label: 'Beauty', bg: Color(0xFFF5B8A0),
    reason: 'Home-visit beauticians — women-only option available',
  ),
  BrowseCategory(
    icon: '🚗', label: 'Driver', bg: AppColors.warning,
    reason: 'Trusted drivers — daily, monthly, airport transfer',
  ),
  BrowseCategory(
    icon: '🔩', label: 'Mechanic', bg: AppColors.sage,
    reason: 'Car specialists — Japanese, European, local vehicles',
  ),
  BrowseCategory(
    icon: '🏠', label: 'Home Help', bg: Color(0xFFBAC8E0),
    reason: 'Multi-skill helpers — cleaning, painting, shifting',
  ),
];
```

**Category card:** Shows icon + label + 1-line reason in small grey text.  
**On category tap:** → `/chat-active` with `prefillCategory` parameter

---

# 6. PROVIDER FLOW — SCREEN-BY-SCREEN SPECS

Provider screens use **dark theme** (`AppColors.bgDark` background, white text, dark glass cards).

## SCREEN 29: Provider Dashboard `/provider-dashboard`

**Bottom Nav (dark theme):**
```
[🏠 Home → /provider-dashboard] [💼 Jobs → /provider-job-leads]
[💰 Earnings → /provider-earnings] [👤 Profile → /provider-performance]
```

| Element | Spec |
|---|---|
| Header | "Salam, Tariq 👋" + bell icon + settings icon |
| Stats row | Today's earnings (PKR) + Jobs done + Avg rating |
| Today's jobs | Cards for each job — time, client, service, address, price |
| Upcoming jobs | Tomorrow's jobs |
| AI tip | "🤖 AI suggestion: Your peak hours are 10AM-2PM in G-13" |
| Job card CTAs | "Start Job" → `/provider-en-route?jobId={id}` |

---

## SCREEN 30: Provider Job Leads `/provider-job-leads`

| Element | Spec |
|---|---|
| Filter tabs | All · High Priority · Medium · Low |
| Job cards | AI match score chip + service + location + time + price |
| Accept/Decline | Accept → confirms job + notifies consumer + navigate `/provider-en-route` |
| Decline | Soft reject — job goes back to pool |

---

## SCREEN 31: Provider En Route `/provider-en-route`

| Element | Spec |
|---|---|
| Map | google_maps_flutter — provider location + customer location |
| ETA | Live countdown |
| Customer info | Name + masked phone + service summary |
| "Arrived" button | → changes status to `in_progress` → customer notified |
| "Open GPS" | `url_launcher` → Google Maps external app |

---

## SCREENS 32–35: Earnings, Wallet, Performance, Settings

These screens are well-designed in the Figma code. Implement as-is using dark theme. Key navigation wiring:

- `provider-earnings` → "Withdraw" button → `/provider-wallet`
- `provider-wallet` → submit withdrawal → `context.pop()` → show snackbar
- `provider-performance` → shows reviews, AI trust score, badges
- `provider-settings` → logout → `/role-select`

---

# 7. SHARED COMPONENTS LIBRARY

These components are used across multiple screens and must be built once in `lib/shared/widgets/`.

## AgentTracePanel Widget

Used on: ChatActive, ReasoningDrawer, DisputeResolution

```dart
class AgentTracePanel extends StatelessWidget {
  final List<AgentTraceStep> steps;
  final bool isLoading; // true = last step still running

  // Shows animated list of steps:
  // ✅ IntentAgent [342ms] — "AC bilkul kaam nahi" → AC Repair, 94%
  // ⚡ MatchingAgent [running...] — Scanning 23 providers in G-13
  //
  // Each step animates in with fade + slide-up when added to list
  // "running" step shows pulse animation
  // Background: dark glass card (rgba 31,31,31, 0.88)
  // Text: white + AppColors.lavender accent
}
```

## BottomNavBar Widget (Consumer)

```dart
class ConsumerBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  // Tabs: Chat (MessageCircle) | Bookings (ClipboardList) | Browse (Search) | Profile (User)
  // Active tab: gradient pill background
  // Badge support on Bookings tab (unread chat messages)
}
```

## ConfidenceBadge Widget

```dart
class ConfidenceBadge extends StatelessWidget {
  final double confidence; // 0.0–1.0

  // Shows: "94% — sab samajh aaya ✓"
  // Color: green if >80%, amber if 60-80%, coral if <60%
  // Animates progress bar when value changes
}
```

---

# 8. MISSING SCREENS — BUILD THESE

## 🆕 BookingChatScreen (Priority: HIGH)

Full spec in Section 5 Screen 19. Summary:

- Firebase Realtime DB for messages
- `flutter_chat_ui` package for bubble UI
- System message auto-created on first open
- User bubbles right (lavender), provider bubbles left (white glass)
- AppBar shows provider name + booking status

## 🔧 Fix: SetupProfile Area Dropdown

Full spec in Section 5 Screen 6. Summary:

- Replace free-text area field with cascading dropdown
- City selection → loads area list from `cities_areas.dart`
- Area selection (bottom sheet, same style as city selector)
- Add new field: Full Address (free text, 2 lines)

---

# 9. NAVIGATION FIXES REQUIRED

These are broken navigation paths found directly in the Figma code that Antigravity must fix:

| Screen | Element | Current State | Fix |
|---|---|---|---|
| `BookingDetail` | Call button | No `onTap` | `launchUrl(Uri(scheme: 'tel', path: phone))` |
| `BookingDetail` | Chat button | No `onTap` | `context.push('/booking-chat?bookingId=...')` |
| `DisputeScreen` | Back arrow | No `onTap` | `context.pop()` |
| `DisputeScreen` | Submit button | No `onTap` | Submit API → navigate `/dispute-resolution` |
| `DisputeResolution` | Accept button | No `onTap` | `context.go('/bookings')` + snackbar |
| `DisputeResolution` | Escalate button | No `onTap` | API call → `context.go('/bookings')` + snackbar |
| `FeedbackScreen` | Submit button | No `onTap` | Smart routing (see Screen 21 spec) |
| `ProviderRanking` | "AI ne kyun chuna?" | Only on card #1 | Add to ALL provider cards |
| `BrowseDirectory` | Category cards | Navigates but no context | Pass `prefillCategory` to `/chat-active` |
| `SetupProfile` | Area field | Free-text only | Replace with cascading dropdown (see Screen 6) |
| `BookingHistory` | "Feedback Dein" | No navigation | → `/feedback?bookingId={id}` |

---

# 10. PUBSPEC.YAML DEPENDENCIES

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0

  # Navigation
  go_router: ^13.0.0

  # Firebase
  firebase_core: ^2.24.0
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  firebase_database: ^10.4.0      # In-app chat
  firebase_storage: ^11.6.0       # Dispute evidence photos
  firebase_messaging: ^14.7.0     # Push notifications

  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # HTTP
  dio: ^5.4.0

  # Maps
  google_maps_flutter: ^2.6.0

  # UI
  flutter_chat_ui: ^1.6.12         # In-app chat bubbles
  pin_code_fields: ^8.0.1          # OTP input
  fl_chart: ^0.66.0               # Provider earnings charts
  shimmer: ^3.0.0                  # Loading states

  # Utilities
  url_launcher: ^6.2.5             # Phone call (tel:) + share
  image_picker: ^1.0.7             # Dispute evidence photos
  share_plus: ^7.2.1              # Share booking receipt
  intl: ^0.19.0                   # Date formatting

  # Fonts
  google_fonts: ^6.1.0             # Nunito

  # Animations
  lottie: ^3.0.0                   # Success animations (booking confirmed)

dev_dependencies:
  build_runner: ^2.4.0
  riverpod_generator: ^2.3.0
  flutter_lints: ^3.0.0
```

**pubspec.yaml — fonts section:**
```yaml
fonts:
  - family: Nunito
    fonts:
      - asset: assets/fonts/Nunito-Regular.ttf
      - asset: assets/fonts/Nunito-Medium.ttf    weight: 500
      - asset: assets/fonts/Nunito-Bold.ttf      weight: 700
      - asset: assets/fonts/Nunito-ExtraBold.ttf weight: 800
  - family: NotoNastaliqUrdu
    fonts:
      - asset: assets/fonts/NotoNastaliqUrdu-Regular.ttf
```

---

## IMPLEMENTATION PRIORITY ORDER

For hackathon time constraint, build in this order:

**Day 1 — Core Flow (Demo-critical):**
1. SetupProfile fix (City + Area + Address fields)
2. ChatHome (all 8 categories)
3. ChatActive → IntentConfirm → ProviderRanking → PriceBreakdown → BookingConfirmed
4. Fix all navigation dead ends listed in Section 9

**Day 2 — Post-Booking (Demo-critical):**
5. BookingHistory → BookingDetail (Chat + Call wired)
6. BookingChatScreen (new screen)
7. FeedbackScreen smart routing
8. DisputeScreen → DisputeResolution (fully wired)

**Day 3 — Provider + Polish:**
9. Provider flow (Dashboard → Jobs → En Route)
10. LiveTracking screen
11. BrowseDirectory (all 8 categories with reasons)
12. AgentTracePanel on dispute resolution (WOW moment)

---

*Document version: 1.0*  
*Based on: Figma Make Export (Onboarding_Flow_Design.zip) + AI_Seekho_Blueprint.md*  
*For: Antigravity Development Team*  
*Stack: Flutter 3.x · Riverpod 2.x · GoRouter · Firebase · Google Maps*
