import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/providers/app_providers.dart';
import '../../routes/app_routes.dart';
import '../../widgets/decorative_background.dart';
import '../../widgets/gradient_cta_button.dart';
import '../../widgets/phone_input_field.dart';

class PhoneAuthScreen extends ConsumerStatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  ConsumerState<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends ConsumerState<PhoneAuthScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    return Scaffold(
      body: DecorativeBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 100,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            colors: [AppColors.bgSecondary, Colors.white],
                          ),
                        ),
                        child: const Center(child: Text('📱', style: TextStyle(fontSize: 40))),
                      ),
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.accentSand,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.lock, size: 14, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Text('Apna Number Daliye', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text('${s.phoneHint} 🔒', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 28),
                PhoneInputField(controller: _controller),
                const Spacer(),
                GradientCtaButton(
                  label: s.sendOtp,
                  onPressed: () {
                    ref.read(phoneProvider.notifier).state = _controller.text;
                    context.go(AppRoutes.otpVerify);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
