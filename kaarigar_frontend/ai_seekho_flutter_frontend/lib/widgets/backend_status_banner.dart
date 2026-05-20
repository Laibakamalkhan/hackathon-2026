import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_colors.dart';
import '../features/booking/providers/booking_provider.dart';
import '../main.dart';

/// Slim persistent banner shown whenever the backend is unreachable or the
/// booking list is being served from local cache.
///
/// Shows one of:
///   • "Backend offline — limited mode"           (backendOnline == false)
///   • "Using cached bookings — connect to refresh" (booking.isOffline only)
///
/// When both conditions are true the global "Backend offline" message takes
/// priority and only one strip is shown.
///
/// Inject this above the page content via [MaterialApp.router]'s `builder:`.
/// Individual screens do NOT need to include it.
class BackendStatusBanner extends ConsumerWidget {
  const BackendStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backendOnline = ref.watch(backendOnlineProvider);
    final bookingOffline = ref.watch(
      bookingNotifierProvider.select((s) => s.isOffline),
    );

    final bool show = !backendOnline || bookingOffline;
    if (!show) return const SizedBox.shrink();

    final String message = !backendOnline
        ? 'Backend offline — limited mode'
        : 'Using cached bookings — connect to refresh';

    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        color: AppColors.warning.withValues(alpha: 0.15),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 14,
              color: AppColors.warning,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
