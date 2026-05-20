import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/network/api_service.dart';
import '../../core/providers/app_providers.dart';
import '../../features/matching/providers/matching_provider.dart';
import '../../models/provider_model.dart';
import '../../routes/app_routes.dart';
import '../../services/mock_data_service.dart';
import '../../widgets/ai_orb_logo.dart';
import '../../widgets/decorative_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_cta_button.dart';
import '../../widgets/primary_button.dart';

class ProviderRankingScreen extends ConsumerWidget {
  const ProviderRankingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    // Use real providers from the coordinator; fall back to mock if not yet loaded.
    final matchingState = ref.watch(matchingNotifierProvider);
    final providers = matchingState.providers.isNotEmpty
        ? matchingState.providers
        : MockDataService.providers;

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
                          Text('${providers.length} best providers mile hain! 🏆',
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
              ...List.generate(providers.length, (i) {
                final p = providers[i];
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

class ReasoningDrawerScreen extends StatelessWidget {
  const ReasoningDrawerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final factors = [
      ('Distance', 75, AppColors.accentLavender),
      ('Availability', 100, AppColors.success),
      ('Rating', 88, AppColors.accentLavender),
      ('On-Time', 96, AppColors.success),
      ('Specialization', 95, AppColors.success),
      ('Price Fit', 80, AppColors.accentSand),
      ('Cancellations', 92, AppColors.success),
      ('Reviews', 85, AppColors.accentLavender),
    ];
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
                  const Text('🤖 AI ne Ali ko kyun choose kiya?', style: TextStyle(color: AppColors.textOnDark, fontWeight: FontWeight.w800, fontSize: 18)),
                  const Text('8 factor analysis', style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 13)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _agentCard('IntentAgent', '[342ms]', '"AC bilkul kaam nahi" -> AC Repair (94%)'),
                  _agentCard('MatchingAgent', '[611ms]', '8 providers scanned in G-13 — Ali ranked #1'),
                  _agentCard('Wajah:', '', '• Ali AC specialist — +12 pts\n• On-time: Ali 96% vs Hassan 71%\n• Budget discount — PKR 880 final', warning: 'Hassan 1km closer lekin on-time weak'),
                  const Text('Score Breakdown', style: TextStyle(color: AppColors.textOnDark, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  ...factors.map((f) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(f.$1, style: const TextStyle(color: AppColors.textOnDark, fontSize: 13)),
                                Text('${f.$2}%', style: const TextStyle(color: AppColors.textOnDark, fontWeight: FontWeight.w700)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(value: f.$2 / 100, color: f.$3, backgroundColor: Colors.white10, minHeight: 6),
                            ),
                          ],
                        ),
                      )),
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

  static Widget _agentCard(String title, String meta, String body, {String? warning}) {
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
              const Icon(Icons.check_circle, color: AppColors.success, size: 18),
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
    final provider = ref.watch(selectedProviderProvider) ?? MockDataService.providers.first;
    final quote = ref.watch(matchingNotifierProvider).quote;

    // Parse real breakdown lines from coordinator quote, fall back to mock.
    final List<(String, String, bool)> lines;
    final String totalStr;
    if (quote != null) {
      final rawTotal = quote['total'] ?? quote['amount'] ?? quote['total_price'] ?? 930;
      totalStr = '${quote['currency'] ?? 'PKR'} $rawTotal';
      final breakdown = quote['breakdown'] as List<dynamic>?;
      if (breakdown != null && breakdown.isNotEmpty) {
        lines = breakdown.map<(String, String, bool)>((b) {
          final label  = (b['label'] ?? b['item'] ?? '').toString();
          final amount = (b['amount'] ?? b['value'] ?? 0);
          final isDiscount = (b['is_discount'] as bool?) ?? amount < 0;
          return (label, 'PKR $amount', isDiscount);
        }).toList();
      } else {
        lines = [('Total', totalStr, false)];
      }
    } else {
      totalStr = 'PKR 930';
      lines = const [
        ('Base service fee', 'PKR 500', false),
        ('Visit fee',        'PKR 200', false),
        ('Distance (3.2km)', 'PKR 160', false),
        ('Urgency surcharge','PKR 100', false),
        ('Complexity charge','PKR 50',  false),
        ('Loyalty discount', 'PKR 80',  true),
      ];
    }
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
                        Text('📍 G-13, Islamabad · Kal 10:00 AM', style: Theme.of(context).textTheme.bodySmall),
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
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('TOTAL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                      Text('PKR 930', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _executeBooking());
  }

  Future<void> _executeBooking() async {
    final handoff = ref.read(matchingNotifierProvider).handoff;
    try {
      final result = await apiService.agentExecute(
        handoff: handoff ?? {
          'user_id': 'user_demo_001',
          'provider_id': ref.read(selectedProviderProvider)?.id ?? 'p1',
          'service_type': ref.read(selectedProviderProvider)?.service ?? 'AC Repair',
          'scheduled_time': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
          'location_address': 'G-13, Islamabad',
          'lat': 33.649,
          'lng': 72.973,
        },
      );
      if (mounted) {
        setState(() {
          _isBooking = false;
          _bookingId = (result['booking_id'] ?? result['id'] ?? 'BSK-${DateTime.now().millisecondsSinceEpoch}').toString();
        });
      }
    } catch (_) {
      if (mounted) setState(() { _isBooking = false; _bookingId = 'BSK-${DateTime.now().millisecondsSinceEpoch}'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(selectedProviderProvider) ?? MockDataService.providers.first;
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
                      _detailRow('Service', provider.service),
                      _detailRow('Provider', provider.name, subtitle: '${provider.rating} · Top Rated'),
                      _detailRow('Date & Time', 'Kal, 10:00 AM'),
                      _detailRow('Total', ref.watch(matchingNotifierProvider).quote?['total'] != null ? 'PKR ${ref.watch(matchingNotifierProvider).quote!["total"]}' : 'PKR 880', highlight: true),
                      _detailRow('Booking ID', '#${_bookingId ?? 'BSK-2024-1821'}'),
                      const Divider(height: 28),
                      _infoBox(
                        Icons.alarm,
                        'Reminder Set',
                        '9:00 AM notification scheduled',
                        AppColors.success.withValues(alpha: 0.25),
                      ),
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
    final p = ref.watch(selectedProviderProvider) ?? MockDataService.providers.first;
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
