import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/auth/firebase_bootstrap.dart';
import 'core/constants/api_endpoints.dart';
import 'core/network/http_client.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';
import 'widgets/backend_status_banner.dart';

/// Pings GET / on the backend at startup.
/// Returns true if reachable, false otherwise.
Future<bool> _pingBackend() async {
  try {
    await HttpClient().get('${ApiEndpoints.baseHttpUrl}/');
    return true;
  } catch (_) {
    return false;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  final firebaseReady = await bootstrapFirebase();
  activateDemoSession();

  // Non-blocking ping — result is available to the app via backendOnlineProvider.
  final isOnline = await _pingBackend().timeout(
    const Duration(seconds: 3),
    onTimeout: () => false,
  );

  runApp(
    ProviderScope(
      overrides: [
        backendOnlineProvider.overrideWithValue(isOnline),
        firebaseEnabledProvider.overrideWithValue(firebaseReady),
      ],
      child: const KarigarApp(),
    ),
  );
}

/// Global provider — true when the backend responded on startup.
final backendOnlineProvider = Provider<bool>((ref) => false);

class KarigarApp extends ConsumerWidget {
  const KarigarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'KARIGAR',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
      // Inject the global offline banner above every route without modifying
      // individual scaffolds. BackendStatusBanner returns SizedBox.shrink()
      // when both backend is online and bookings are fresh.
      builder: (context, child) => Column(
        children: [
          const BackendStatusBanner(),
          Expanded(child: child ?? const SizedBox.shrink()),
        ],
      ),
    );
  }
}
