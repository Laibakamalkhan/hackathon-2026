import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/network/api_service.dart';
import '../../core/providers/app_providers.dart';
import '../../features/booking/providers/booking_provider.dart';
import '../../features/dispute/providers/dispute_provider.dart';
import '../../core/constants/dispute_types.dart';
import '../../models/booking_model.dart';
import '../../routes/app_routes.dart';

import '../../widgets/consumer_bottom_nav.dart';
import '../../widgets/decorative_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_cta_button.dart';
import '../../widgets/primary_button.dart';

enum BookingFilter { all, active, completed, cancelled }

class BookingHistoryScreen extends ConsumerStatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  ConsumerState<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends ConsumerState<BookingHistoryScreen> {
  BookingFilter _filter = BookingFilter.all;

  @override
  void initState() {
    super.initState();
    // Fetch real bookings from the backend after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookingNotifierProvider.notifier).loadBookings('user_demo_001');
    });
  }

  List<Booking> _filtered(List<Booking> all) {
    return switch (_filter) {
      BookingFilter.all       => all,
      BookingFilter.active    => all.where((b) => b.status == BookingStatus.active).toList(),
      BookingFilter.completed => all.where((b) => b.status == BookingStatus.completed).toList(),
      BookingFilter.cancelled => all.where((b) => b.status == BookingStatus.cancelled).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final bookingState = ref.watch(bookingNotifierProvider);
    final bookings = _filtered(bookingState.bookings);
    final tabs = [
      (BookingFilter.all, s.tabAll),
      (BookingFilter.active, s.tabActive),
      (BookingFilter.completed, 'Mukammal'),
      (BookingFilter.cancelled, s.tabCancelled),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Meri Bookings 📋')),
      body: DecorativeBackground(
        child: Column(
          children: [
            // ── Offline banner ────────────────────────────────────────────
            if (bookingState.isOffline)
              Container(
                width: double.infinity,
                color: AppColors.warning.withValues(alpha: 0.85),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off, size: 16, color: AppColors.textPrimary),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Offline mode — showing cached data',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                    TextButton(
                      onPressed: () => ref
                          .read(bookingNotifierProvider.notifier)
                          .loadBookings('user_demo_001'),
                      child: const Text('Retry', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
            // ── Filter tabs ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: tabs.map((t) {
                    final sel = _filter == t.$1;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _filter = t.$1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: sel ? Colors.transparent : AppColors.textSecondary.withValues(alpha: 0.25),
                            ),
                            gradient: sel
                                ? const LinearGradient(
                                    colors: [Color(0xFFB8C6DB), Color(0xFFD0BEA3)],
                                  )
                                : null,
                            color: sel ? null : Colors.white.withValues(alpha: 0.85),
                          ),
                          child: Text(
                            t.$2,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            // ── List / Loading / Empty ────────────────────────────────────
            Expanded(
              child: bookingState.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accentLavender,
                      ),
                    )
                  : bookings.isEmpty
                      ? Center(
                          child: Text(
                            'No bookings in this category',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: bookings.length,
                          itemBuilder: (_, i) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _BookingListCard(
                              booking: bookings[i],
                              onOpen: () {
                                ref.read(selectedBookingIdProvider.notifier).state =
                                    bookings[i].id;
                                context.push(AppRoutes.bookingDetail);
                              },
                              onTrack: () => context.push(AppRoutes.liveTracking),
                              onFeedback: () => context.push(AppRoutes.feedback),
                              onDispute: () => context.push(AppRoutes.dispute),
                            ),
                          ),
                        ),
            ),
            ConsumerBottomNav(
              active: ConsumerTab.bookings,
              onTabSelected: (t) => _navConsumer(context, t),
            ),
          ],
        ),
      ),
    );
  }

}

class _BookingListCard extends StatelessWidget {
  const _BookingListCard({
    required this.booking,
    required this.onOpen,
    required this.onTrack,
    required this.onFeedback,
    required this.onDispute,
  });

  final Booking booking;
  final VoidCallback onOpen;
  final VoidCallback onTrack;
  final VoidCallback onFeedback;
  final VoidCallback onDispute;

  Color get _accent => switch (booking.status) {
        BookingStatus.active => AppColors.accentLavender,
        BookingStatus.completed => AppColors.success,
        BookingStatus.cancelled => AppColors.error,
      };

  @override
  Widget build(BuildContext context) {
    final isActive = booking.status == BookingStatus.active;
    final isCompleted = booking.status == BookingStatus.completed;

    return GestureDetector(
      onTap: onOpen,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: AppColors.glassShadow, blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 5, color: _accent),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (isActive && booking.timePill.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.accentSand.withValues(alpha: 0.45),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text('⏳ ${booking.timePill}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                              )
                            else if (isCompleted)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(alpha: 0.35),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text('✓ Completed', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                              ),
                            const Spacer(),
                            if (isActive)
                              const Text('Active', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w700, fontSize: 12))
                            else if (booking.shortDate.isNotEmpty)
                              Text(booking.shortDate, style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: isActive ? AppColors.accentLavender.withValues(alpha: 0.5) : AppColors.accentSand.withValues(alpha: 0.5),
                              child: Text(booking.initials, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(booking.providerName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                                  Text('${booking.providerRating} ⭐', style: Theme.of(context).textTheme.bodySmall),
                                ],
                              ),
                            ),
                            if (isCompleted)
                              Text(booking.price, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isCompleted ? '${booking.service} · ID: ${booking.id}' : '${booking.service} 📍 ${booking.location}',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        if (isActive && booking.canTrack) ...[
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: GradientCtaButton(
                                  label: 'Track Live',
                                  icon: const Icon(Icons.navigation_outlined, size: 18, color: AppColors.textPrimary),
                                  onPressed: onTrack,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: onOpen,
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                  ),
                                  child: const Text('Details'),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (isCompleted) ...[
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: onFeedback,
                                  icon: const Icon(Icons.thumb_up_outlined, size: 18),
                                  label: const Text('Give Feedback'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.success,
                                    foregroundColor: AppColors.textPrimary,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: onDispute,
                                  icon: const Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.error),
                                  label: const Text('Dispute', style: TextStyle(color: AppColors.error)),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppColors.error),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _navConsumer(BuildContext context, ConsumerTab tab) {
  switch (tab) {
    case ConsumerTab.chat:
      context.go(AppRoutes.home);
    case ConsumerTab.bookings:
      break;
    case ConsumerTab.profile:
      context.go(AppRoutes.profile);
  }
}

class LiveTrackingScreen extends StatelessWidget {
  const LiveTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('Booking Confirmed', '10:32 AM', '✓ Completed', true, false, AppColors.success),
      ('Provider Preparing', '9:45 AM', '✓ Completed', true, false, AppColors.accentLavender),
      ('On the Way', '9:58 AM', 'Ali is on the way to your location...', true, true, AppColors.warning),
      ('Arrived', 'ETA 10:15 AM', '', false, false, AppColors.textSecondary),
      ('Work in Progress', '', '', false, false, AppColors.textSecondary),
      ('Completed', '', '', false, false, AppColors.textSecondary),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Tracking 📍'),
        actions: [IconButton(icon: const Icon(Icons.close), onPressed: () => context.pop())],
      ),
      body: DecorativeBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: [AppColors.warning.withValues(alpha: 0.35), AppColors.success.withValues(alpha: 0.45)],
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Provider arriving in', style: Theme.of(context).textTheme.bodySmall),
                        const Text('17 min', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [AppColors.success, Color(0xFF7ED4B8)]),
                    ),
                    child: const Icon(Icons.navigation_outlined, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ...steps.asMap().entries.map((e) {
              final i = e.key;
              final s = e.value;
              final done = s.$4;
              final active = s.$5;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: done ? s.$6.withValues(alpha: active ? 1 : 0.9) : AppColors.textSecondary.withValues(alpha: 0.2),
                          ),
                          child: Icon(
                            active ? Icons.hourglass_top : Icons.check,
                            size: 16,
                            color: done ? AppColors.textPrimary : AppColors.textSecondary,
                          ),
                        ),
                        if (i < steps.length - 1)
                          Container(width: 2, height: 48, color: AppColors.textSecondary.withValues(alpha: 0.2)),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(18),
                          border: active ? Border.all(color: AppColors.warning, width: 2) : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(s.$1, style: const TextStyle(fontWeight: FontWeight.w800)),
                                if (s.$2.isNotEmpty) Text(s.$2, style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                            if (s.$3.isNotEmpty)
                              Text(
                                s.$3,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: active ? AppColors.warning : AppColors.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.darkBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🤖 AI Monitoring Active', style: TextStyle(color: AppColors.textOnDark, fontWeight: FontWeight.w700)),
                  SizedBox(height: 6),
                  Text(
                    'Tracking provider location · Monitoring ETA · Ready to assist',
                    style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.phone_outlined),
                    label: const Text('Call Provider'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push(AppRoutes.chatMessaging),
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Chat'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.go(AppRoutes.bookings),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              ),
              child: const Text('Cancel Booking', style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      ),
    );
  }
}

class BookingDetailScreen extends ConsumerStatefulWidget {
  const BookingDetailScreen({super.key});

  @override
  ConsumerState<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends ConsumerState<BookingDetailScreen> {
  bool _showCancel = false;

  @override
  Widget build(BuildContext context) {
    final id = ref.watch(selectedBookingIdProvider) ?? 'BSK-2024-1821';
    // Prefer real API data; fall back to mock list if not yet loaded.
    final allBookings = ref.watch(bookingNotifierProvider).bookings;
    final mockBookings = ref.watch(bookingsProvider);
    final booking = allBookings.isNotEmpty
        ? allBookings.firstWhere(
            (b) => b.id == id,
            orElse: () => allBookings.first,
          )
        : mockBookings.firstWhere(
            (b) => b.id == id,
            orElse: () => mockBookings.first,
          );
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: const Text('Booking Detail'),
      ),
      body: DecorativeBackground(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.id, style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Text(booking.service, style: Theme.of(context).textTheme.titleMedium),
                    Text(booking.providerName),
                    Text('${booking.date} · ${booking.time}'),
                    Text(booking.location),
                    Text(booking.price, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                  ],
                ),
              ),
              const Spacer(),
              if (_showCancel)
                GlassCard(
                  child: Column(
                    children: [
                      const Text('Cancel this booking?'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: OutlinedButton(onPressed: () => setState(() => _showCancel = false), child: const Text('No'))),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                // Update status via real API, then go back.
                                await ref
                                    .read(bookingNotifierProvider.notifier)
                                    .updateStatus(id, 'cancelled');
                                if (context.mounted) context.go(AppRoutes.bookings);
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                              child: const Text('Yes, Cancel'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              else ...[
                PrimaryButton(label: 'Track Live', onPressed: () => context.push(AppRoutes.liveTracking)),
                const SizedBox(height: 12),
                OutlinedButton(onPressed: () {}, child: const Text('Reschedule')),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => setState(() => _showCancel = true),
                  child: const Text('Cancel Booking', style: TextStyle(color: AppColors.error)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  int _rating = 5;
  bool _isSubmitting = false;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final bookingId = ref.read(selectedBookingIdProvider);
    if (bookingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No active booking selected for feedback submission.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await apiService.submitFeedback(
        bookingId: bookingId,
        rating: _rating.toDouble(),
        comment: _commentController.text.trim().isNotEmpty
            ? _commentController.text.trim()
            : 'Great service!',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Feedback submit ho gaya! Shukriya'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go(AppRoutes.bookings);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback')),
      body: DecorativeBackground(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text('Rate your experience',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return IconButton(
                    icon: Icon(
                      i < _rating ? Icons.star : Icons.star_border,
                      color: AppColors.warning, size: 40,
                    ),
                    onPressed: () => setState(() => _rating = i + 1),
                  );
                }),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _commentController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Share your experience...', filled: true),
              ),
              const Spacer(),
              _isSubmitting
                  ? const CircularProgressIndicator(color: AppColors.accentLavender)
                  : PrimaryButton(label: 'Submit Feedback', onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatMessagingScreen extends StatelessWidget {
  const ChatMessagingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final messages = [
      ('provider', 'Assalam o Alaikum, main 20 min mein pohanchunga'),
      ('user', 'Theek hai, main wait kar rahi hoon'),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ali AC Services'),
        actions: [
          IconButton(icon: const Icon(Icons.info_outline), onPressed: () => context.push(AppRoutes.bookingDetail)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: messages.map((m) {
                final isUser = m.$1 == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? AppColors.accentLavender.withValues(alpha: 0.4) : AppColors.glassFill,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(m.$2),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.attach_file)),
                const Expanded(child: TextField(decoration: InputDecoration(hintText: 'Message...', filled: true))),
                IconButton(onPressed: () {}, icon: const Icon(Icons.send)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DisputeScreen extends ConsumerStatefulWidget {
  const DisputeScreen({super.key});

  @override
  ConsumerState<DisputeScreen> createState() => _DisputeScreenState();
}

class _DisputeScreenState extends ConsumerState<DisputeScreen> {
  DisputeTypeUi _selectedType = DisputeTypeUi.poorService;
  bool _isSubmitting = false;
  final _descController = TextEditingController();

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe the issue')),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    final bookingId = ref.read(selectedBookingIdProvider) ?? 'BSK-2024-1821';
    // Navigate to resolving screen immediately; it auto-navigates when done.
    if (mounted) context.push(AppRoutes.disputeResolving);
    await ref.read(disputeNotifierProvider.notifier).resolve(
      bookingId: bookingId,
      disputeType: _selectedType.apiValue,
      description: _descController.text.trim(),
    );
    if (mounted) setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('File Dispute')),
      body: DecorativeBackground(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Issue type'),
              Wrap(
                spacing: 8,
                children: DisputeTypeUi.values.map((t) => ChoiceChip(
                  label: Text(t.label),
                  selected: _selectedType == t,
                  onSelected: (_) => setState(() => _selectedType = t),
                )).toList(),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _descController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Describe the issue...', filled: true),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Evidence upload coming soon')),
                  );
                },
                icon: const Icon(Icons.upload),
                label: const Text('Upload evidence'),
              ),
              const Spacer(),
              _isSubmitting
                  ? const Center(child: CircularProgressIndicator(color: AppColors.accentLavender))
                  : PrimaryButton(label: 'Submit Dispute', onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}

class DisputeResolutionScreen extends ConsumerWidget {
  const DisputeResolutionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disputeState = ref.watch(disputeNotifierProvider);
    final resolution = disputeState.resolution;
    final error = disputeState.error;

    if (resolution == null) {
      final errorMsg = error ?? 'Dispute resolution data is not available.';
      return Scaffold(
        appBar: AppBar(title: const Text('Resolution Error')),
        body: DecorativeBackground(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                Text('Resolution Failed', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 16),
                GlassCard(
                  child: Text(
                    errorMsg,
                    style: const TextStyle(color: AppColors.error, height: 1.5, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Spacer(),
                if (disputeState.lastBookingId != null)
                  PrimaryButton(
                    label: 'Retry',
                    onPressed: () {
                      final notifier = ref.read(disputeNotifierProvider.notifier);
                      context.go(AppRoutes.disputeResolving);
                      notifier.resolve(
                        bookingId: disputeState.lastBookingId!,
                        disputeType: disputeState.lastDisputeType!,
                        description: disputeState.lastDescription!,
                        userId: disputeState.lastUserId ?? 'user_demo_001',
                      );
                    },
                  ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => context.go(AppRoutes.bookings),
                  child: const Text('Go to Bookings'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final resObj = resolution['resolution'] as Map<String, dynamic>?;
    final type = resObj?['type']?.toString() ?? 'none';
    final amount = resObj?['amount_pkr'];
    final explanation = resolution['user_message_en']?.toString() ??
        resolution['user_message_urdu']?.toString() ??
        resObj?['reasoning']?.toString() ??
        'No explanation provided.';
    
    final isEscalated = resolution['escalation_needed'] == true;
    final summary = amount != null && amount > 0 
        ? 'PKR $amount refund approved.\n\n$explanation' 
        : explanation;

    return Scaffold(
      appBar: AppBar(title: const Text('Resolution')),
      body: DecorativeBackground(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                isEscalated ? Icons.assignment_late_outlined : Icons.gavel,
                size: 64,
                color: isEscalated ? AppColors.warning : AppColors.accentLavender,
              ),
              const SizedBox(height: 16),
              Text(
                isEscalated ? 'Manager Escalation' : 'AI Resolution',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: (isEscalated ? AppColors.warning : AppColors.success).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _label(type, isEscalated),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isEscalated ? AppColors.textPrimary : AppColors.success,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GlassCard(child: Text(summary, style: const TextStyle(height: 1.5))),
              const Spacer(),
              PrimaryButton(
                label: 'Accept Resolution',
                onPressed: () {
                  ref.read(disputeNotifierProvider.notifier).reset();
                  // Re-fetch bookings after resolution accepts
                  ref.read(bookingNotifierProvider.notifier).loadBookings('user_demo_001');
                  context.go(AppRoutes.bookings);
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Support request submitted. A manager will contact you soon.')),
                  );
                },
                child: const Text('Request Human Review'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _label(String t, bool isEscalated) {
    if (isEscalated) return '⚠️ Escalated to Manager';
    switch (t.toLowerCase()) {
      case 'refund':       return '✓ Refund Approved';
      case 'compensation': return '✓ Compensation Approved';
      case 'rebook':       return '✓ Rebooking Scheduled';
      case 'warning':      return '✓ Provider Warned';
      case 'none':         return 'No Action Required';
      default:             return 'Resolution: ${t.toUpperCase()}';
    }
  }
}

class DisputeResolvingScreen extends ConsumerStatefulWidget {
  const DisputeResolvingScreen({super.key});

  @override
  ConsumerState<DisputeResolvingScreen> createState() => _DisputeResolvingScreenState();
}

class _DisputeResolvingScreenState extends ConsumerState<DisputeResolvingScreen> {
  ProviderSubscription<DisputeState>? _sub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final current = ref.read(disputeNotifierProvider);
      if ((current.resolution != null || current.error != null) && mounted) {
        context.go(AppRoutes.disputeResolution);
        return;
      }
      _sub = ref.listenManual(disputeNotifierProvider, (_, next) {
        if ((next.resolution != null || next.error != null) && mounted) {
          context.go(AppRoutes.disputeResolution);
        }
      });
    });
  }

  @override
  void dispose() {
    _sub?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resolving Dispute')),
      body: DecorativeBackground(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppColors.accentLavender),
              const SizedBox(height: 24),
              Text('AI is reviewing your case...',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'View Status',
                onPressed: () => context.go(AppRoutes.disputeResolution),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

