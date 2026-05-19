import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/providers/app_providers.dart';
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

  List<Booking> _filtered(List<Booking> all) {
    return switch (_filter) {
      BookingFilter.all => all,
      BookingFilter.active => all.where((b) => b.status == BookingStatus.active).toList(),
      BookingFilter.completed => all.where((b) => b.status == BookingStatus.completed).toList(),
      BookingFilter.cancelled => all.where((b) => b.status == BookingStatus.cancelled).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final bookings = _filtered(ref.watch(bookingsProvider));
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
            Expanded(
              child: bookings.isEmpty
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
                            ref.read(selectedBookingIdProvider.notifier).state = bookings[i].id;
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
    final booking = ref.watch(bookingsProvider).firstWhere((b) => b.id == id);
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
                              onPressed: () {
                                ref.read(bookingsProvider.notifier).state = ref
                                    .read(bookingsProvider)
                                    .map((b) => b.id == id ? Booking(id: b.id, providerName: b.providerName, service: b.service, date: b.date, time: b.time, location: b.location, price: b.price, status: BookingStatus.cancelled, providerRating: b.providerRating, providerInitials: b.providerInitials, shortDate: b.shortDate, timePill: b.timePill) : b)
                                    .toList();
                                context.go(AppRoutes.bookings);
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

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    int rating = 5;
    return StatefulBuilder(
      builder: (context, setState) {
        return Scaffold(
          appBar: AppBar(title: const Text('Feedback')),
          body: DecorativeBackground(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('Rate your experience', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      return IconButton(
                        icon: Icon(i < rating ? Icons.star : Icons.star_border, color: AppColors.warning, size: 40),
                        onPressed: () => setState(() => rating = i + 1),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  const TextField(maxLines: 4, decoration: InputDecoration(hintText: 'Share your experience...', filled: true)),
                  const Spacer(),
                  PrimaryButton(
                    label: 'Submit Feedback',
                    onPressed: () => context.go(AppRoutes.bookings),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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

class DisputeScreen extends StatelessWidget {
  const DisputeScreen({super.key});

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
                children: ['Poor service', 'No show', 'Overcharged', 'Other']
                    .map((t) => Chip(label: Text(t)))
                    .toList(),
              ),
              const SizedBox(height: 20),
              const TextField(maxLines: 5, decoration: InputDecoration(hintText: 'Describe the issue...', filled: true)),
              const SizedBox(height: 20),
              OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.upload), label: const Text('Upload evidence')),
              const Spacer(),
              PrimaryButton(
                label: 'Submit Dispute',
                onPressed: () => context.push(AppRoutes.disputeResolving),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DisputeResolutionScreen extends StatelessWidget {
  const DisputeResolutionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resolution')),
      body: DecorativeBackground(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(Icons.gavel, size: 64, color: AppColors.accentLavender),
              const SizedBox(height: 16),
              Text('AI Resolution', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              GlassCard(
                child: const Text(
                  'Based on evidence, a partial refund of PKR 200 has been approved. Provider has been notified.',
                ),
              ),
              const Spacer(),
              PrimaryButton(label: 'Accept Resolution', onPressed: () => context.go(AppRoutes.bookings)),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: () {}, child: const Text('Request Human Review')),
            ],
          ),
        ),
      ),
    );
  }
}

class DisputeResolvingScreen extends StatelessWidget {
  const DisputeResolvingScreen({super.key});

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
              Text('AI is reviewing your case...', style: Theme.of(context).textTheme.titleLarge),
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
