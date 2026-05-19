import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../routes/app_routes.dart';
import '../../widgets/decorative_background.dart';
import '../../widgets/gradient_cta_button.dart';

class OtpVerifyScreen extends ConsumerStatefulWidget {
  const OtpVerifyScreen({super.key});

  @override
  ConsumerState<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends ConsumerState<OtpVerifyScreen> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  int _seconds = 83;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_seconds > 0 && mounted) setState(() => _seconds--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: DecorativeBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5D4C8),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Center(child: Text('✉️', style: TextStyle(fontSize: 48))),
                ),
                const SizedBox(height: 28),
                const Text('OTP Daliye', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text('+92 3XX-XXXXXXX par bheja gaya', style: Theme.of(context).textTheme.bodySmall),
                TextButton(onPressed: () => context.pop(), child: const Text('Galat number?')),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (i) => _otpBox(i)),
                ),
                const SizedBox(height: 20),
                Text(
                  '${_seconds ~/ 60}:${(_seconds % 60).toString().padLeft(2, '0')} mein expire hoga',
                  style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.w600),
                ),
                TextButton(onPressed: () {}, child: const Text('Dobara Bhejein')),
                const Spacer(),
                GradientCtaButton(
                  label: 'Verify Karein',
                  enabled: _otp.length == 6,
                  onPressed: () => context.go(AppRoutes.setupProfile),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _otpBox(int index) {
    return SizedBox(
      width: 48,
      height: 56,
      child: TextField(
        controller: _controllers[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onChanged: (v) {
          if (v.isNotEmpty && index < 5) FocusScope.of(context).nextFocus();
          setState(() {});
        },
      ),
    );
  }
}
