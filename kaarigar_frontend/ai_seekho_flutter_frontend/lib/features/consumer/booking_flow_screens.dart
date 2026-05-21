import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/auth/session_user.dart';
import '../../core/network/api_service.dart';
import '../../core/providers/app_providers.dart';
import '../../features/matching/providers/matching_provider.dart';
import '../../features/booking/providers/booking_provider.dart';
import '../../models/provider_model.dart';
import '../../models/quote_model.dart';
import '../../routes/app_routes.dart';
import '../../services/mock_data_service.dart';
import '../../widgets/ai_orb_logo.dart';
import '../../widgets/decorative_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_cta_button.dart';
import '../../widgets/primary_button.dart';
import '../../main.dart';

class ProviderRankingScreen extends ConsumerWidget {
  const ProviderRankingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    // Use real providers from the coordinator; fall back to mock if not yet loaded.
    final matchingState = ref.watch(matchingNotifierProvider);
    final backendOnline = ref.watch(backendOnlineProvider);
    final providers = matchingState.providers;
    final useMockFallback =
        providers.isEmpty && !backendOnline && !matchingState.isLoading;

    if (providers.isEmpty && backendOnline && !matchingState.isLoading) {
      return Scaffold(
        body: DecorativeBackground(
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.search_off, size: 48, color: AppColors.textSecondary),
                    const SizedBox(height: 16),
                    const Text(
                      'No providers loaded',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      matchingState.error ?? 'Run a new search from chat first.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton(
                      onPressed: () => context.go(AppRoutes.home),
                      child: const Text('Back to Chat'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final displayProviders =
        providers.isNotEmpty ? providers : (useMockFallback ? MockDataService.providers : providers);

    return Scaffold(
      body: DecorativeBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AiOrbLogo(size: 32),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${displayProviders.length} best providers mile hain! 🏆',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                          Text('8 factors se ranked — ${profile.area}, ${profile.city} mein',
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...List.generate(displayProviders.length, (i) {
                final p = displayProviders[i];
                return _ProviderRankingCard(
                  provider: p,
                  rank: i + 1,
                  isTopPick: i == 0,
                  onProfile: () {
                    ref.read(selectedProviderProvider.notifier).state = p;
                    context.push(AppRoutes.providerProfile);
                  },
                  onReason: () => context.push(AppRoutes.reasoningPanel),
                  onBook: () {
                    ref.read(selectedProviderProvider.notifier).state = p;
                    ref.read(matchingNotifierProvider.notifier).updateHandoffProvider(p);
                    context.push(AppRoutes.priceBreakdown);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProviderRankingCard extends StatelessWidget {
  const _ProviderRankingCard({
    required this.provider,
    required this.rank,
    required this.isTopPick,
    required this.onProfile,
    required this.onReason,
    required this.onBook,
  });

  final ServiceProvider provider;
  final int rank;
  final bool isTopPick;
  final VoidCallback onProfile;
  final VoidCallback onReason;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    final initials = provider.name.split(' ').map((w) => w[0]).take(2).join();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [BoxShadow(color: AppColors.glassShadow, blurRadius: 20, offset: Offset(0, 4))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.accentLavender.withValues(alpha: 0.5),
                    child: Text(initials, style: const TextStyle(fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(child: Text(provider.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
                            if (isTopPick) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.urgent.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text('Top Pick', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ],
                        ),
                        Text(rank == 1 ? '🥇 #1' : rank == 2 ? '🥈 #2' : '🥉 #3', style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.warning, size: 18),
                      Text(' ${provider.rating}', style: const TextStyle(fontWeight: FontWeight.w800)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _tag(Icons.location_on_outlined, provider.distance, AppColors.bgSecondary),
                  _tag(Icons.schedule, '${provider.matchScore}% on-time', rank == 1 ? AppColors.success.withValues(alpha: 0.2) : AppColors.error.withValues(alpha: 0.15)),
                  _tag(Icons.build_outlined, 'AC Specialist', AppColors.bgSecondary),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('From', style: Theme.of(context).textTheme.labelSmall),
                      Text(provider.price.split('–').first.trim(), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22)),
                    ],
                  ),
                  Text('Kal, 10:00 AM', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 16),
              OutlinedButton(onPressed: onProfile, child: const Text('View Full Profile')),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: onReason,
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.accentLavender),
                child: const Text('🤖 AI ne kyun chuna?'),
              ),
              const SizedBox(height: 8),
              GradientCtaButton(label: 'Book Now →', onPressed: onBook),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tag(IconData icon, String text, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class ReasoningDrawerScreen extends ConsumerWidget {
  const ReasoningDrawerScreen({super.key});

  String _formatTimestamp(String timestampStr) {
    try {
      final dt = DateTime.parse(timestampStr);
      final min = dt.minute.toString().padLeft(2, '0');
      final sec = dt.second.toString().padLeft(2, '0');
      final ms = dt.millisecond.toString().padLeft(3, '0');
      return '${dt.hour}:$min:$sec.$ms';
    } catch (_) {
      return timestampStr;
    }
  }

  Color _getColorForFactor(String key) {
    final cleanKey = key.replaceAll('_pts', '').toLowerCase();
    switch (cleanKey) {
      case 'proximity':
      case 'rating':
      case 'sentiment':
        return AppColors.accentLavender;
      case 'availability':
      case 'on_time':
      case 'experience':
      case 'specialization':
      case 'cancellation':
        return AppColors.success;
      case 'price':
        return AppColors.accentSand;
      default:
        return AppColors.accentLavender;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchingState = ref.watch(matchingNotifierProvider);
    final coordinatorResult = matchingState.coordinatorResult;
    final traceEvents = coordinatorResult?['trace_events'] as List<dynamic>?;
    
    final selected = ref.watch(selectedProviderProvider);
    final provider = selected ??
        (matchingState.providers.isNotEmpty
            ? matchingState.providers.first
            : null);
    final providerJson = provider?.rawJson ?? const {};
    final breakdownRaw = providerJson['match_breakdown'] ?? providerJson['match_factors'] ?? providerJson['factor_scores'];
    final breakdown = breakdownRaw is Map<String, dynamic> ? breakdownRaw : null;

    final hasTrace = traceEvents != null && traceEvents.isNotEmpty;
    final hasBreakdown = breakdown != null && breakdown.isNotEmpty;

    if (!hasTrace && !hasBreakdown) {
      return Scaffold(
        backgroundColor: AppColors.darkBg,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
              const Spacer(),
              const Icon(Icons.info_outline, size: 64, color: AppColors.darkTextSecondary),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Reasoning unavailable',
                  style: TextStyle(color: AppColors.textOnDark, fontWeight: FontWeight.w800, fontSize: 20),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'AI ne is decision ki explanation generate nahi ki.',
                  style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 14),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Wapas jayein', style: TextStyle(fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bgSecondary,
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final keyLabels = {
      'proximity_pts': 'Distance',
      'proximity': 'Distance',
      'experience_pts': 'Experience',
      'experience': 'Experience',
      'on_time_pts': 'On-Time',
      'on_time': 'On-Time',
      'rating_pts': 'Rating',
      'rating': 'Rating',
      'availability_pts': 'Availability',
      'availability': 'Availability',
      'specialization_pts': 'Specialization',
      'specialization': 'Specialization',
      'price_pts': 'Price Fit',
      'price': 'Price Fit',
      'cancellation_pts': 'Cancellations',
      'cancellation': 'Cancellations',
      'sentiment_pts': 'Reviews',
      'sentiment': 'Reviews',
    };

    final List<MapEntry<String, double>> factorItems = [];
    if (breakdown != null) {
      for (var entry in breakdown.entries) {
        final val = entry.value;
        if (val is num) {
          if (entry.key == 'complexity_multiplier' || entry.key == 'match_score') {
            continue;
          }
          factorItems.add(MapEntry(entry.key, val.toDouble()));
        }
      }
    }

    final iconMap = {
      'think': Icons.psychology,
      'act': Icons.play_arrow,
      'observe': Icons.visibility_outlined,
    };
    final iconColorMap = {
      'think': AppColors.accentLavender,
      'act': AppColors.accentLavender,
      'observe': AppColors.success,
    };

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🤖 AI ne ${provider?.name ?? 'Provider'} ko kyun choose kiya?', style: const TextStyle(color: AppColors.textOnDark, fontWeight: FontWeight.w800, fontSize: 18)),
                  if (factorItems.isNotEmpty)
                    Text('${factorItems.length} factor analysis', style: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 13)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  if (hasTrace) ...[
                    ...traceEvents.map((event) {
                      final type = event['type']?.toString().toLowerCase() ?? 'think';
                      final content = event['content']?.toString() ?? '';
                      final timestamp = event['timestamp']?.toString() ?? '';
                      final icon = iconMap[type] ?? Icons.info_outline;
                      final iconColor = iconColorMap[type] ?? AppColors.accentLavender;
                      final title = type.toUpperCase();
                      
                      return _agentCard(
                        icon: icon,
                        iconColor: iconColor,
                        title: title,
                        meta: timestamp.isNotEmpty ? _formatTimestamp(timestamp) : '',
                        body: content,
                      );
                    }),
                    const SizedBox(height: 12),
                  ],
                  if (hasBreakdown) ...[
                    const Text('Score Breakdown', style: TextStyle(color: AppColors.textOnDark, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    ...factorItems.map((f) {
                      final label = keyLabels[f.key] ?? f.key.replaceAll('_pts', '').replaceAll('_', ' ').toUpperCase();
                      final color = _getColorForFactor(f.key);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(label, style: const TextStyle(color: AppColors.textOnDark, fontSize: 13)),
                                Text('${f.value.round()}%', style: const TextStyle(color: AppColors.textOnDark, fontWeight: FontWeight.w700)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: f.value / 100.0,
                                color: color,
                                backgroundColor: Colors.white10,
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.check),
                label: const Text('Mujhe samajh aa gaya', style: TextStyle(fontWeight: FontWeight.w800)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bgSecondary,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _agentCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String meta,
    required String body,
    String? warning,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: AppColors.textOnDark, fontWeight: FontWeight.w700)),
              const Spacer(),
              if (meta.isNotEmpty) Text(meta, style: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 11)),
            ],
          ),
          if (body.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(body, style: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 12, height: 1.4)),
          ],
          if (warning != null) ...[
            const SizedBox(height: 8),
            Text('⚠ $warning', style: const TextStyle(color: AppColors.warning, fontSize: 11)),
          ],
        ],
      ),
    );
  }
}

class PriceBreakdownScreen extends ConsumerWidget {
  const PriceBreakdownScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matching = ref.watch(matchingNotifierProvider);
    final backendOnline = ref.watch(backendOnlineProvider);
    final provider = ref.watch(selectedProviderProvider) ??
        (matching.providers.isNotEmpty
            ? matching.providers.first
            : (backendOnline ? null : MockDataService.providers.first));
    if (provider == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
          title: const Text('Price Breakdown 💰'),
        ),
        body: const Center(child: Text('Select a provider from ranking first.')),
      );
    }
    final quoteDisplay = QuoteDisplay.fromCoordinatorQuote(matching.quote);
    final fields = matching.extractedFields ?? {};
    final locationLabel = [
      fields['location_mention'],
      fields['sector'],
      fields['location'],
    ].whereType<Object>().map((e) => e.toString()).where((s) => s.isNotEmpty).join(', ');
    final scheduleLabel = (fields['time_preference'] ?? fields['scheduled_time'] ?? 'Kal, 10:00 AM').toString();

    final lines = quoteDisplay.lines.isNotEmpty 
        ? quoteDisplay.lines.map((l) => (l.label, 'PKR ${l.amount.toStringAsFixed(0)}', l.amount < 0)).toList() 
        : [('Total', 'PKR ${quoteDisplay.totalPkr.toStringAsFixed(0)}', false)];
    final totalStr = 'PKR ${quoteDisplay.totalPkr.toStringAsFixed(0)}';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: const Text('Price Breakdown 💰'),
      ),
      body: DecorativeBackground(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            GlassCard(
              child: Row(
                children: [
                  CircleAvatar(backgroundColor: AppColors.accentLavender, child: Text(provider.name[0])),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(provider.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                        Text(
                          '📍 ${locationLabel.isNotEmpty ? locationLabel : "Islamabad"} · $scheduleLabel',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Row(children: [const Icon(Icons.star, color: AppColors.warning, size: 16), Text(' ${provider.rating}')]),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                children: [
                  ...lines.map((l) {
                    final isDiscount = l.$3;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(l.$1, style: TextStyle(color: isDiscount ? AppColors.success : null)),
                          Text(l.$2, style: TextStyle(fontWeight: FontWeight.w700, color: isDiscount ? AppColors.success : null)),
                        ],
                      ),
                    );
                  }),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TOTAL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                      Text(totalStr, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accentLavender.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('✓ Fixed price — koi hidden charges nahi\n✓ Cancellation free agar 2 ghante pehle karein', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.accentLavender.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('🤖 AI verified fair price', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
              ),
            ),
            const SizedBox(height: 20),
            GradientCtaButton(label: 'Booking Confirm Karein — $totalStr', onPressed: () => context.go(AppRoutes.bookingConfirmed)),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.go(AppRoutes.providerRanking),
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Doosra Provider Dekhein'),
            ),
          ],
        ),
      ),
    );
  }
}

class BookingConfirmedScreen extends ConsumerStatefulWidget {
  const BookingConfirmedScreen({super.key});

  @override
  ConsumerState<BookingConfirmedScreen> createState() => _BookingConfirmedScreenState();
}

class _BookingConfirmedScreenState extends ConsumerState<BookingConfirmedScreen> {
  bool _isBooking = true;
  String? _bookingId;
  String? _errorMessage;
  String? _scheduledLabel;
  int _reminderCount = 0;
  List<Map<String, dynamic>> _notifications = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _executeBooking());
  }

  Future<void> _executeBooking() async {
    final handoff = ref.read(matchingNotifierProvider).handoff;
    if (handoff == null) {
      if (mounted) {
        setState(() {
          _isBooking = false;
          _errorMessage = "Booking data missing. Go back and run search again.";
        });
      }
      return;
    }
    
    try {
      final result = await apiService.agentExecute(handoff: handoff);
      
      if (mounted) {
        final status = (result['status'] ?? '').toString().toLowerCase();
        if (status == 'success' ||
            status == 'booked' ||
            result['bid'] != null) {
          ref.read(bookingNotifierProvider.notifier).loadBookings(
                resolveUserId(ref),
                backendWasOnline: ref.read(backendOnlineProvider),
              );
          final booking = result['booking'];
          final scheduled = booking is Map
              ? (booking['scheduled_time'] ?? result['scheduled_time'])?.toString()
              : result['scheduled_time']?.toString();
          final reminders = result['reminders'];
          final notifs = result['notifications'];
          setState(() {
            _isBooking = false;
            _bookingId = (result['bid'] ?? result['booking_id']).toString();
            _scheduledLabel = _formatScheduled(scheduled);
            _reminderCount = reminders is List ? reminders.length : 3;
            if (notifs is List) {
              _notifications = notifs
                  .map((n) => Map<String, dynamic>.from(n as Map))
                  .toList();
            }
            ref.read(selectedBookingIdProvider.notifier).state = _bookingId;
          });
        } else if (result['status'] == 'conflict') {
          setState(() {
            _isBooking = false;
            _errorMessage = "Time slot conflict: ${result['suggested_slot'] ?? 'Please choose another time'}";
          });
        } else {
          setState(() {
            _isBooking = false;
            _errorMessage = "Failed to create booking.";
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isBooking = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  String _formatScheduled(String? iso) {
    if (iso == null || iso.isEmpty) return 'Scheduled';
    if (iso.contains('T')) {
      final parts = iso.split('T');
      final time = parts[1].length >= 5 ? parts[1].substring(0, 5) : parts[1];
      return '${parts[0]} $time';
    }
    return iso;
  }

  ServiceProvider? _resolvedProvider() {
    final selected = ref.read(selectedProviderProvider);
    if (selected != null) return selected;
    final handoff = ref.read(matchingNotifierProvider).handoff;
    final ctx = handoff?['full_context'];
    if (ctx is Map && ctx['provider'] is Map) {
      return ServiceProvider.fromJson(Map<String, dynamic>.from(ctx['provider'] as Map));
    }
    final providers = ref.read(matchingNotifierProvider).providers;
    return providers.isNotEmpty ? providers.first : null;
  }

  @override
  Widget build(BuildContext context) {
    final provider = _resolvedProvider();
    if (provider == null && !_isBooking && _errorMessage == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'Provider details unavailable',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );
    }
    if (_isBooking) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.accentLavender),
              SizedBox(height: 20),
              Text('Booking create ho rahi hai...', style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
    }
    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                const SizedBox(height: 16),
                Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w600, fontSize: 16)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    context.pop();
                  },
                  child: const Text('Retry Search'),
                )
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      body: DecorativeBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.success.withValues(alpha: 0.25),
                    boxShadow: [BoxShadow(color: AppColors.success.withValues(alpha: 0.4), blurRadius: 32)],
                  ),
                  child: const Icon(Icons.check_circle, size: 72, color: AppColors.success),
                ),
                const SizedBox(height: 20),
                Text('Booking Mukammal! 🎉', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text('Aap ka technician kal aayega', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 24),
                GlassCard(
                  child: Column(
                    children: [
                      _detailRow('Service', provider!.service),
                      _detailRow('Provider', provider.name, subtitle: '${provider.rating} · Top Rated'),
                      _detailRow('Date & Time', _scheduledLabel ?? 'Scheduled'),
                      _detailRow('Total', ref.watch(matchingNotifierProvider).quote?['total'] != null ? 'PKR ${ref.watch(matchingNotifierProvider).quote!["total"]}' : 'PKR 880', highlight: true),
                      if (_bookingId != null)
                        _detailRow('Booking ID', '#$_bookingId'),
                      const Divider(height: 28),
                      _infoBox(
                        Icons.alarm,
                        'Reminder Set',
                        '$_reminderCount reminders scheduled (simulated)',
                        AppColors.success.withValues(alpha: 0.25),
                      ),
                      if (_notifications.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _infoBox(
                          Icons.sms_outlined,
                          'SMS & WhatsApp sent',
                          _notifications.first['body']?.toString() ?? '',
                          AppColors.accentSand.withValues(alpha: 0.35),
                        ),
                      ],
                      const SizedBox(height: 10),
                      _infoBox(Icons.smart_toy_outlined, 'AI agents will monitor your booking', '', AppColors.textSecondary.withValues(alpha: 0.15)),
                    ],
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.receipt_outlined),
                        label: const Text('Receipt'),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.chat),
                        label: const Text('WhatsApp'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.go(AppRoutes.liveTracking),
                        icon: const Icon(Icons.navigation_outlined),
                        label: const Text('Track'),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextButton(onPressed: () => context.go(AppRoutes.home), child: const Text('Home par jayein')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _detailRow(String k, String v, {String? subtitle, bool highlight = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(k, style: const TextStyle(color: AppColors.textSecondary)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  v,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: highlight ? AppColors.success : AppColors.textPrimary,
                    fontSize: highlight ? 18 : 14,
                  ),
                ),
                if (subtitle != null)
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
      );

  Widget _infoBox(IconData icon, String title, String sub, Color bg) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            Icon(icon, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  if (sub.isNotEmpty) Text(sub, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      );
}

class ProviderProfileScreen extends ConsumerWidget {
  const ProviderProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(selectedProviderProvider) ??
        (ref.watch(matchingNotifierProvider).providers.isNotEmpty
            ? ref.watch(matchingNotifierProvider).providers.first
            : null);
    if (p == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Provider')),
        body: const Center(child: Text('Select a provider from ranking')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: Text(p.name),
      ),
      body: DecorativeBackground(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.accentLavender,
                child: Text(p.name[0], style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(height: 16),
            Center(child: Text('${p.rating} ★ · ${p.reviews} reviews')),
            const SizedBox(height: 24),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Services', style: TextStyle(fontWeight: FontWeight.w700)),
                  Text(p.service),
                  const SizedBox(height: 12),
                  ...p.badges.map((b) => Chip(label: Text(b))),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Recent Reviews', style: TextStyle(fontWeight: FontWeight.w700)),
            ...['Bahut acha kaam kiya!', 'Time par aaye, recommend'].map(
              (r) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: GlassCard(child: Text(r)),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Book ${p.name.split(' ').first}',
              onPressed: () => context.push(AppRoutes.priceBreakdown),
            ),
          ],
        ),
      ),
    );
  }
}
