import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../routes/app_routes.dart';
import '../../widgets/decorative_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/provider_bottom_nav.dart';

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  State<ProviderDashboardScreen> createState() => _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  String _tab = 'upcoming';

  @override
  Widget build(BuildContext context) {
    final upcoming = [
      ('Zainab K.', 'AC Repair', '11:30 AM', 'G-13/3', 'PKR 880', true),
    ];
    final active = [
      ('Ahmed M.', 'AC Installation', '2:00 PM', 'F-10/4', 'PKR 1,200', false),
    ];
    final jobs = _tab == 'upcoming' ? upcoming : active;
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: DecorativeBackground(
        dark: true,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Assalam o Alaikum', style: AppTypography.darkBody(14)),
                        Text('Ali AC Services 👋', style: AppTypography.darkTitle(24)),
                      ],
                    ),
                    Row(
                      children: [
                        _darkIcon(Icons.notifications_outlined),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => context.push(AppRoutes.providerSettings),
                          child: _darkIcon(Icons.settings_outlined),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _stat('PKR 3,240', 'Aaj ki earnings', AppColors.success),
                    const SizedBox(width: 8),
                    _stat('4', 'Jobs mukammal', AppColors.accentLavender),
                    const SizedBox(width: 8),
                    _stat('4.8 ⭐', 'Avg. rating', AppColors.warning),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _tabBtn('upcoming', 'Upcoming'),
                    _tabBtn('active', 'Active'),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: jobs.length,
                  itemBuilder: (_, i) {
                    final j = jobs[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GlassCard(
                        dark: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(j.$1, style: const TextStyle(color: AppColors.textOnDark, fontWeight: FontWeight.w700)),
                                if (j.$6)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(color: AppColors.urgent.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(8)),
                                    child: const Text('Urgent', style: TextStyle(fontSize: 10, color: AppColors.textOnDark)),
                                  ),
                              ],
                            ),
                            Text(j.$2, style: TextStyle(color: AppColors.textOnDark.withValues(alpha: 0.7))),
                            Text('${j.$3} · ${j.$4}', style: TextStyle(color: AppColors.textOnDark.withValues(alpha: 0.55), fontSize: 12)),
                            const SizedBox(height: 8),
                            Text(j.$5, style: const TextStyle(color: AppColors.accentLavender, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              ProviderBottomNav(
                active: ProviderTab.home,
                onTabSelected: (t) => _providerNav(context, t),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(String v, String l, Color c) {
    return Expanded(
      child: GlassCard(
        dark: true,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.trending_up, color: c, size: 18),
            const SizedBox(height: 8),
            Text(l, style: TextStyle(fontSize: 11, color: AppColors.textOnDark.withValues(alpha: 0.55))),
            Text(v, style: const TextStyle(color: AppColors.textOnDark, fontWeight: FontWeight.w700, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _tabBtn(String id, String label) {
    final sel = _tab == id;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = id),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: sel ? AppColors.accentLavender : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700, color: sel ? AppColors.textPrimary : AppColors.textOnDark)),
        ),
      ),
    );
  }

  Widget _darkIcon(IconData icon) => Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.darkGlassFill,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.darkGlassBorder),
        ),
        child: Icon(icon, color: AppColors.textOnDark, size: 20),
      );
}

void _providerNav(BuildContext context, ProviderTab tab) {
  switch (tab) {
    case ProviderTab.home:
      context.go(AppRoutes.providerDashboard);
    case ProviderTab.jobs:
      context.go(AppRoutes.providerJobLeads);
    case ProviderTab.earnings:
      context.go(AppRoutes.providerEarnings);
    case ProviderTab.history:
      context.go(AppRoutes.providerHistory);
    case ProviderTab.profile:
      context.go(AppRoutes.providerAccountProfile);
  }
}

class ProviderJobLeadsScreen extends StatefulWidget {
  const ProviderJobLeadsScreen({super.key});

  @override
  State<ProviderJobLeadsScreen> createState() => _ProviderJobLeadsScreenState();
}

class _ProviderJobLeadsScreenState extends State<ProviderJobLeadsScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final jobs = [
      ('BSK-1824', 'AC Repair', 'G-13', 'PKR 880', 96, 'High'),
      ('BSK-1825', 'AC Gas', 'F-10', 'PKR 650', 78, 'Medium'),
    ];
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Job Leads', style: TextStyle(color: AppColors.textOnDark)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textOnDark), onPressed: () => context.pop()),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: ['All', 'High', 'Medium', 'Low'].map((f) {
                final sel = _filter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(f),
                    selected: sel,
                    onSelected: (_) => setState(() => _filter = f),
                    selectedColor: AppColors.accentLavender,
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: jobs.length,
              itemBuilder: (_, i) {
                final j = jobs[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassCard(
                    dark: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(j.$2, style: const TextStyle(color: AppColors.textOnDark, fontWeight: FontWeight.w700)),
                            Text('${j.$5}% match', style: const TextStyle(color: AppColors.success)),
                          ],
                        ),
                        Text('${j.$1} · ${j.$3}', style: TextStyle(color: AppColors.textOnDark.withValues(alpha: 0.55))),
                        Text(j.$4, style: const TextStyle(color: AppColors.accentLavender, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.textOnDark,
                                  side: const BorderSide(color: AppColors.darkGlassBorder),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                child: const Text('Decline', style: TextStyle(fontWeight: FontWeight.w700)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => context.push(AppRoutes.providerEnRoute),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accentLavender,
                                  foregroundColor: AppColors.textPrimary,
                                  elevation: 4,
                                  shadowColor: AppColors.accentLavender.withValues(alpha: 0.4),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                child: const Text('Accept Job', style: TextStyle(fontWeight: FontWeight.w800)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          ProviderBottomNav(active: ProviderTab.jobs, onTabSelected: (t) => _providerNav(context, t)),
        ],
      ),
    );
  }
}

class ProviderEnRouteScreen extends StatelessWidget {
  const ProviderEnRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('En Route', style: TextStyle(color: AppColors.textOnDark)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textOnDark), onPressed: () => context.pop()),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.accentLavender.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(child: Icon(Icons.navigation, size: 64, color: AppColors.accentLavender)),
            ),
          ),
          GlassCard(
            dark: true,
            child: Column(
              children: [
                const Text('Zainab K.', style: TextStyle(color: AppColors.textOnDark, fontWeight: FontWeight.w700, fontSize: 18)),
                Text('AC Repair · G-13/3', style: TextStyle(color: AppColors.textOnDark.withValues(alpha: 0.55))),
                const SizedBox(height: 16),
                PrimaryButton(label: 'Open Navigation', dark: true, onPressed: () {}),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => context.go(AppRoutes.providerDashboard),
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.textOnDark),
                  child: const Text('Arrived at Location'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class ProviderEarningsScreen extends StatefulWidget {
  const ProviderEarningsScreen({super.key});

  @override
  State<ProviderEarningsScreen> createState() => _ProviderEarningsScreenState();
}

class _ProviderEarningsScreenState extends State<ProviderEarningsScreen> {
  String _chartPeriod = 'week';

  static const _mint = Color(0xFF7ED4B8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: DecorativeBackground(
        dark: true,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Earnings', style: AppTypography.darkTitle(28)),
                    Text('Track your income & growth', style: AppTypography.darkBody(13)),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.darkGlassFill,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: _mint.withValues(alpha: 0.5), width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Available Balance', style: AppTypography.darkBody(12)),
                                    const Text('PKR 65,790', style: TextStyle(color: _mint, fontSize: 32, fontWeight: FontWeight.w800)),
                                    const SizedBox(height: 8),
                                    Text('Pending', style: AppTypography.darkBody(12)),
                                    const Text('PKR 2,100', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(color: Color(0xFF2A2A2A), shape: BoxShape.circle),
                                child: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.textOnDark),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => context.push(AppRoutes.providerWallet),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _mint,
                                foregroundColor: AppColors.textPrimary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text('Withdraw', style: TextStyle(fontWeight: FontWeight.w800)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _quickStat(Icons.calendar_today_outlined, 'Today', '3,240'),
                        const SizedBox(width: 8),
                        _quickStat(Icons.trending_up, 'This Week', '18,500'),
                        const SizedBox(width: 8),
                        _quickStat(Icons.payments_outlined, 'This Month', '67,890'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GlassCard(
                      dark: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Performance', style: TextStyle(color: AppColors.textOnDark, fontWeight: FontWeight.w800)),
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2A2A2A),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: ['week', 'month'].map((p) {
                                    final sel = _chartPeriod == p;
                                    return GestureDetector(
                                      onTap: () => setState(() => _chartPeriod = p),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: sel ? AppColors.textOnDark.withValues(alpha: 0.15) : Colors.transparent,
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Text(p, style: TextStyle(fontSize: 11, color: sel ? AppColors.textOnDark : AppColors.darkTextSecondary)),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 100,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((d) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 40 + (d.hashCode % 30).toDouble(),
                                      decoration: BoxDecoration(
                                        color: _mint.withValues(alpha: 0.35),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(d, style: AppTypography.darkBody(10)),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Recent Activity', style: TextStyle(color: AppColors.textOnDark, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    ...[
                      ('AC Repair', 'Zainab K.', '+PKR 880', 'Today, 11:45 AM', true),
                      ('Installation', 'Ahmed M.', '+PKR 1,200', 'Yesterday', true),
                      ('Bank Transfer', 'May 16', 'PKR 5000', 'May 16', false),
                    ].map(
                      (t) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GlassCard(
                          dark: true,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: (t.$5 ? AppColors.success : AppColors.error).withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  t.$5 ? Icons.arrow_upward : Icons.arrow_downward,
                                  color: t.$5 ? _mint : AppColors.error,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(t.$1, style: const TextStyle(color: AppColors.textOnDark, fontWeight: FontWeight.w600)),
                                    Text(t.$2, style: AppTypography.darkBody(11)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    t.$3,
                                    style: TextStyle(
                                      color: t.$5 ? _mint : AppColors.error,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(t.$4, style: AppTypography.darkBody(10)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ProviderBottomNav(active: ProviderTab.earnings, onTabSelected: (t) => _providerNav(context, t)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickStat(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.darkGlassFill,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.darkGlassBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.textOnDark, size: 20),
            const SizedBox(height: 8),
            Text(label, style: AppTypography.darkBody(11)),
            Text(value, style: const TextStyle(color: AppColors.textOnDark, fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class ProviderWalletScreen extends StatefulWidget {
  const ProviderWalletScreen({super.key});

  @override
  State<ProviderWalletScreen> createState() => _ProviderWalletScreenState();
}

class _ProviderWalletScreenState extends State<ProviderWalletScreen> {
  final _amount = TextEditingController(text: '5000');
  String _method = 'bank';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Withdraw', style: TextStyle(color: AppColors.textOnDark)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textOnDark), onPressed: () => context.pop()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Balance: PKR 12,400', style: AppTypography.darkTitle(20)),
            const SizedBox(height: 24),
            TextField(
              controller: _amount,
              style: const TextStyle(color: AppColors.textOnDark),
              decoration: const InputDecoration(labelText: 'Amount', labelStyle: TextStyle(color: AppColors.textOnDark)),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [1000, 5000, 10000].map((a) {
                return ActionChip(
                  label: Text('PKR $a'),
                  onPressed: () => _amount.text = a.toString(),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'bank', label: Text('Bank')),
                ButtonSegment(value: 'jazzcash', label: Text('JazzCash')),
              ],
              selected: {_method},
              onSelectionChanged: (s) => setState(() => _method = s.first),
            ),
            const Spacer(),
            PrimaryButton(
              label: 'Withdraw',
              dark: true,
              onPressed: () => context.go(AppRoutes.providerEarnings),
            ),
          ],
        ),
      ),
    );
  }
}

class ProviderHistoryScreen extends StatelessWidget {
  const ProviderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final past = [
      ('Fatima S.', 'AC Maintenance', '10 May', 'PKR 650', true),
      ('Hassan A.', 'AC Gas Refill', '8 May', 'PKR 900', false),
    ];
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Job History', style: TextStyle(color: AppColors.textOnDark)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text('Completed jobs', style: AppTypography.darkBody(14)),
                const SizedBox(height: 12),
                ...past.map((j) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GlassCard(
                        dark: true,
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.accentLavender.withValues(alpha: 0.3),
                              child: Text(j.$1[0], style: const TextStyle(color: AppColors.textOnDark)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(j.$2, style: const TextStyle(color: AppColors.textOnDark, fontWeight: FontWeight.w700)),
                                  Text('${j.$1} · ${j.$3}', style: TextStyle(color: AppColors.textOnDark.withValues(alpha: 0.55), fontSize: 12)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(j.$4, style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w700)),
                                if (j.$5) const Icon(Icons.star, color: AppColors.warning, size: 16),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )),
              ],
            ),
          ),
          ProviderBottomNav(active: ProviderTab.history, onTabSelected: (t) => _providerNav(context, t)),
        ],
      ),
    );
  }
}

class ProviderAccountProfileScreen extends StatelessWidget {
  const ProviderAccountProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: DecorativeBackground(
        dark: true,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Profile', style: AppTypography.darkTitle(28)),
                        IconButton(
                          onPressed: () => context.push(AppRoutes.providerSettings),
                          icon: const Icon(Icons.settings_outlined, color: AppColors.textOnDark),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: AppColors.accentLavender,
                            child: const Text('A', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                          ),
                          const SizedBox(height: 12),
                          Text('Ali AC Services', style: AppTypography.darkTitle(22)),
                          Text('AC Repair · Islamabad', style: AppTypography.darkBody(14)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.star, color: AppColors.warning, size: 18),
                              Text(' 4.9 · 234 reviews', style: AppTypography.darkBody(14)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(child: _profileStat('324', 'Jobs done')),
                        const SizedBox(width: 10),
                        Expanded(child: _profileStat('94', 'Trust score')),
                        const SizedBox(width: 10),
                        Expanded(child: _profileStat('98%', 'Response')),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GlassCard(
                      dark: true,
                      onTap: () {},
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.accentLavender.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.insights, color: AppColors.accentLavender),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Performance & Analytics', style: TextStyle(color: AppColors.textOnDark, fontWeight: FontWeight.w700)),
                                Text('AI trust score, badges, tips', style: AppTypography.darkBody(12)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: AppColors.textOnDark),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    GlassCard(
                      dark: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Recent reviews', style: TextStyle(color: AppColors.textOnDark, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 12),
                          ...['Excellent AC repair!', 'On time and professional'].map(
                            (r) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text('★ $r', style: TextStyle(color: AppColors.textOnDark.withValues(alpha: 0.8))),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ProviderBottomNav(active: ProviderTab.profile, onTabSelected: (t) => _providerNav(context, t)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileStat(String value, String label) {
    return GlassCard(
      dark: true,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Text(value, style: AppTypography.darkTitle(20)),
          Text(label, style: AppTypography.darkBody(11), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class ProviderSettingsScreen extends StatefulWidget {
  const ProviderSettingsScreen({super.key});

  @override
  State<ProviderSettingsScreen> createState() => _ProviderSettingsScreenState();
}

class _ProviderSettingsScreenState extends State<ProviderSettingsScreen> {
  bool _notifications = true;
  bool _autoAccept = false;
  String _language = 'roman';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Settings', style: TextStyle(color: AppColors.textOnDark)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textOnDark), onPressed: () => context.pop()),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                SwitchListTile(
                  title: const Text('Notifications', style: TextStyle(color: AppColors.textOnDark)),
                  value: _notifications,
                  onChanged: (v) => setState(() => _notifications = v),
                ),
                SwitchListTile(
                  title: const Text('Auto-accept jobs', style: TextStyle(color: AppColors.textOnDark)),
                  value: _autoAccept,
                  onChanged: (v) => setState(() => _autoAccept = v),
                ),
                ListTile(
                  title: const Text('Language', style: TextStyle(color: AppColors.textOnDark)),
                  subtitle: Text(_language, style: TextStyle(color: AppColors.textOnDark.withValues(alpha: 0.55))),
                  onTap: () => setState(() => _language = _language == 'roman' ? 'urdu' : 'roman'),
                ),
                ListTile(
                  title: const Text('Help & Support', style: TextStyle(color: AppColors.textOnDark)),
                  onTap: () {},
                ),
                ListTile(
                  title: const Text('Logout', style: TextStyle(color: AppColors.error)),
                  onTap: () => context.go(AppRoutes.splash),
                ),
              ],
            ),
          ),
          ProviderBottomNav(active: ProviderTab.home, onTabSelected: (t) => _providerNav(context, t)),
        ],
      ),
    );
  }
}
