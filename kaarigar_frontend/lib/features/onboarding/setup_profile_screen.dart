import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/providers/app_providers.dart';
import '../../models/user_role.dart';
import '../../routes/app_routes.dart';
import '../../services/location_data.dart';
import '../../widgets/decorative_background.dart';
import '../../widgets/gradient_cta_button.dart';
import '../../widgets/onboarding_dots.dart';

class SetupProfileScreen extends ConsumerStatefulWidget {
  const SetupProfileScreen({super.key});

  @override
  ConsumerState<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends ConsumerState<SetupProfileScreen> {
  final _name = TextEditingController();
  final _street = TextEditingController();
  String? _city;
  String? _area;

  @override
  void dispose() {
    _name.dispose();
    _street.dispose();
    super.dispose();
  }

  List<String> get _areas => _city == null ? [] : LocationData.areas[_city] ?? [];

  bool get _valid =>
      _name.text.trim().length >= 2 &&
      _city != null &&
      _area != null &&
      _street.text.trim().length >= 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecorativeBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const OnboardingDots(count: 3, activeIndex: 2),
                const SizedBox(height: 24),
                const Text(
                  'Aap ki basic maloomat',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  'Taake hum aap ke liye behtar service dhundh sakein ✨',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 28),
                _field(Icons.person_outline, 'Aap ka naam', _name, hint: 'Jaise: Ayesha Malik'),
                const SizedBox(height: 20),
                _dropdown(Icons.location_on_outlined, 'Sheher', _city, LocationData.cities,
                    hint: 'Sheher select karein', onChanged: (v) => setState(() { _city = v; _area = null; })),
                const SizedBox(height: 20),
                _dropdown(Icons.my_location_outlined, 'Ilaka / Sector', _area, _areas,
                    hint: 'Apna ilaka select karein', enabled: _city != null, onChanged: (v) => setState(() => _area = v)),
                const SizedBox(height: 20),
                _field(Icons.home_outlined, 'Mukammal pata', _street,
                    hint: 'Ghar number, street, building ka naam...', maxLines: 3),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.accentLavender.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    '✨ Yeh maloomat aap ke najdeek behtar providers dhundhne mein madad karti hai',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                const SizedBox(height: 28),
                GradientCtaButton(
                  label: 'Shuru Karein →',
                  enabled: _valid,
                  onPressed: () {
                    ref.read(userProfileProvider.notifier).state =
                        ref.read(userProfileProvider).copyWith(
                              name: _name.text.trim(),
                              city: _city!,
                              area: _area!,
                              streetAddress: _street.text.trim(),
                            );
                    final role = ref.read(userRoleProvider);
                    context.go(role == UserRole.provider ? AppRoutes.providerDashboard : AppRoutes.home);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(IconData icon, String label, TextEditingController c, {String? hint, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Icon(icon, size: 16, color: AppColors.textSecondary), const SizedBox(width: 6), Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))]),
        const SizedBox(height: 8),
        TextField(
          controller: c,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _dropdown(
    IconData icon,
    String label,
    String? value,
    List<String> items, {
    required String hint,
    required ValueChanged<String?> onChanged,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Icon(icon, size: 16, color: AppColors.textSecondary), const SizedBox(width: 6), Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))]),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: items.contains(value) ? value : null,
          hint: Text(hint),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: enabled ? onChanged : null,
        ),
      ],
    );
  }
}
