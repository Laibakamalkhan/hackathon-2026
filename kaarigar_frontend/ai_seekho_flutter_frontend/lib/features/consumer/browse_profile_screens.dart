import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/auth/session_user.dart';
import '../../core/network/api_service.dart';
import '../../core/providers/app_providers.dart';
import '../../features/booking/providers/booking_provider.dart';
import '../../main.dart';
import '../../routes/app_routes.dart';
import '../../widgets/consumer_bottom_nav.dart';
import '../../models/booking_model.dart';
import '../providers/providers_list_provider.dart';
import '../../widgets/decorative_background.dart';
import '../../widgets/glass_card.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookingNotifierProvider.notifier).loadBookings(
            resolveUserId(ref),
            backendWasOnline: ref.read(backendOnlineProvider),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final displayName = profile.name.isNotEmpty ? profile.name : 'Ayesha Malik';
    final location = profile.area.isNotEmpty ? '${profile.area}, ${profile.city}' : 'G-13, Islamabad';
    final initials = displayName.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join();

    return Scaffold(
      body: DecorativeBackground(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 52,
                      backgroundColor: AppColors.accentLavender,
                      child: Text(initials, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(displayName, style: Theme.of(context).textTheme.headlineMedium),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.accentLavender),
                        onPressed: () => context.push(AppRoutes.setupProfile),
                      ),
                    ],
                  ),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: AppColors.glassShadow, blurRadius: 8)],
                      ),
                      child: Text('📍 $location', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Builder(
                    builder: (context) {
                      final bookings = ref.watch(bookingNotifierProvider).bookings;
                      final count = bookings.length.toString();
                      final avgRating = bookings.isEmpty
                          ? '—'
                          : (bookings.map((b) => b.providerRating).reduce((a, b) => a + b) /
                                  bookings.length)
                              .toStringAsFixed(1);
                      return Row(
                        children: [
                          _profileStat(count, 'Bookings'),
                          const SizedBox(width: 10),
                          _profileStat(avgRating, 'Avg rating'),
                          const SizedBox(width: 10),
                          _profileStat(bookings.where((b) => b.status == BookingStatus.active).length.toString(), 'Active'),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Is Hafte ki Activity', style: TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                              .map((d) => Text(d, style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.7), fontWeight: FontWeight.w600)))
                              .toList(),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 72,
                          decoration: BoxDecoration(
                            color: AppColors.accentLavender.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.darkBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '“Har kaam waqt par karna success ki nishani hai.”',
                      style: TextStyle(color: AppColors.textOnDark, fontSize: 14, height: 1.5, fontStyle: FontStyle.italic),
                    ),
                  ),
                  const SizedBox(height: 14),
                  GlassCard(
                    child: Column(
                      children: [
                        _menuTile(Icons.settings_outlined, 'Settings', () {}),
                        _menuTile(Icons.language, 'Language', () => context.push(AppRoutes.languageSelect)),
                        _menuTile(Icons.help_outline, 'FAQ', () {}),
                        _menuTile(Icons.map_outlined, 'Map View', () => context.push(AppRoutes.mapView)),
                        _menuTile(Icons.history, 'Booking History', () => context.go(AppRoutes.bookings)),
                        if (kDebugMode)
                          _menuTile(
                            Icons.science_outlined,
                            'Stress Scenarios (Demo)',
                            () => context.push(AppRoutes.stressScenarios),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => context.go(AppRoutes.splash),
                    icon: const Icon(Icons.logout, color: AppColors.error),
                    label: const Text('Logout', style: TextStyle(color: AppColors.error)),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                  ),
                ],
              ),
            ),
            ConsumerBottomNav(
              active: ConsumerTab.profile,
              onTabSelected: (t) {
                switch (t) {
                  case ConsumerTab.chat:
                    context.go(AppRoutes.home);
                  case ConsumerTab.bookings:
                    context.go(AppRoutes.bookings);
                  case ConsumerTab.profile:
                    break;
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileStat(String value, String label) {
    return Expanded(
      child: GlassCard(
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _menuTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class MapViewScreen extends ConsumerWidget {
  const MapViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providersAsync = ref.watch(providersListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Providers')),
      body: Stack(
        children: [
          Container(color: AppColors.accentLavender.withValues(alpha: 0.15)),
          const Center(child: Icon(Icons.map, size: 80, color: AppColors.accentLavender)),
          DraggableScrollableSheet(
            initialChildSize: 0.35,
            minChildSize: 0.2,
            maxChildSize: 0.7,
            builder: (_, controller) {
              return Container(
                decoration: const BoxDecoration(
                  color: AppColors.bgPrimary,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: providersAsync.when(
                  data: (providers) {
                    if (providers.isEmpty) {
                      return const Center(child: Text('No providers available'));
                    }
                    return ListView.builder(
                      controller: controller,
                      padding: const EdgeInsets.all(20),
                      itemCount: providers.length,
                      itemBuilder: (_, i) {
                        final p = providers[i];
                        return ListTile(
                          title: Text(p.name),
                          subtitle: Text('${p.distance} · ${p.rating}★'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            ref.read(selectedProviderProvider.notifier).state = p;
                            context.push(AppRoutes.providerProfile);
                          },
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                          const SizedBox(height: 16),
                          Text('Failed to load providers: $e', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ConfidenceMeterScreen extends StatefulWidget {
  const ConfidenceMeterScreen({super.key});

  @override
  State<ConfidenceMeterScreen> createState() => _ConfidenceMeterScreenState();
}

class _ConfidenceMeterScreenState extends State<ConfidenceMeterScreen> {
  double _confidence = 0.72;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confidence Meter')),
      body: DecorativeBackground(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text('${(_confidence * 100).round()}%', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800)),
              Slider(
                value: _confidence,
                onChanged: (v) => setState(() => _confidence = v),
                activeColor: AppColors.accentLavender,
              ),
              LinearProgressIndicator(value: _confidence, minHeight: 12, borderRadius: BorderRadius.circular(8)),
              const SizedBox(height: 24),
              const Text('Multilingual AI confidence visualization demo'),
            ],
          ),
        ),
      ),
    );
  }
}

class LowConfidenceScreen extends StatelessWidget {
  const LowConfidenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('More Details Needed')),
      body: DecorativeBackground(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('AI confidence is low. Please clarify:', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              const TextField(decoration: InputDecoration(labelText: 'Exact location?', filled: true)),
              const SizedBox(height: 12),
              const TextField(decoration: InputDecoration(labelText: 'When do you need service?', filled: true)),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.chatActive),
                child: const Text('Submit & Re-match'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NoProvidersScreen extends StatelessWidget {
  const NoProvidersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecorativeBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_off_outlined, size: 64, color: AppColors.textSecondary),
                const SizedBox(height: 16),
                Text('Koi provider available nahi', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: () => context.go(AppRoutes.chatActive), child: const Text('Modify Search')),
                const SizedBox(height: 12),
                OutlinedButton(onPressed: () => context.go(AppRoutes.home), child: const Text('Notify When Available')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProviderCancelledScreen extends ConsumerStatefulWidget {
  const ProviderCancelledScreen({super.key});

  @override
  ConsumerState<ProviderCancelledScreen> createState() => _ProviderCancelledScreenState();
}

class _ProviderCancelledScreenState extends ConsumerState<ProviderCancelledScreen> {
  Map<String, dynamic>? _result;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reschedule();
  }

  Future<void> _reschedule() async {
    final bid = ref.read(selectedBookingIdProvider);
    if (bid == null) {
      setState(() {
        _loading = false;
        _result = {'status': 'error', 'message': 'No booking selected'};
      });
      return;
    }
    try {
      final res = await apiService.autoRescheduleBooking(bid);
      setState(() {
        _loading = false;
        _result = res;
      });
      if (res['status'] == 'rescheduled') {
        ref.read(bookingNotifierProvider.notifier).loadBookings(
              resolveUserId(ref),
              backendWasOnline: ref.read(backendOnlineProvider),
            );
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _result = {'status': 'error', 'message': e.toString()};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final alt = _result?['alternate_provider'] as Map<String, dynamic>?;
    final altName = alt?['name'] ?? 'Alternate provider';
    final msg = (_result?['message'] ?? '').toString();

    return Scaffold(
      body: DecorativeBackground(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.swap_horiz, size: 64, color: AppColors.warning),
              const SizedBox(height: 16),
              Text('Provider cancelled', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              if (_loading)
                const CircularProgressIndicator()
              else
                Text(
                  msg.isNotEmpty ? msg : 'AI ne doosra provider dhund raha hai: $altName',
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _result?['status'] == 'rescheduled'
                    ? () => context.go(AppRoutes.bookings)
                    : null,
                child: const Text('View Updated Booking'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.go(AppRoutes.chatActive),
                child: const Text('Search Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
