import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_durations.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/providers/app_providers.dart';
import '../../models/user_role.dart';
import '../../routes/app_routes.dart';
import '../../widgets/ai_orb_logo.dart';
import '../../widgets/consumer_bottom_nav.dart';
import '../../widgets/decorative_background.dart';
import '../../widgets/glass_card.dart';

class ChatHomeScreen extends ConsumerStatefulWidget {
  const ChatHomeScreen({super.key});

  @override
  ConsumerState<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends ConsumerState<ChatHomeScreen> {
  final _input = TextEditingController();
  bool _recording = false;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _startChat([String? message, bool needsUrgency = false]) {
    final text = message ?? _input.text.trim();
    if (text.isEmpty && message == null) return;
    ref.read(chatMessageProvider.notifier).state =
        text.isEmpty ? 'AC repair chahiye' : text;
    ref.read(chatNeedsUrgencyProvider.notifier).state = needsUrgency;
    ref.read(chatFlowPhaseProvider.notifier).state = ChatFlowPhase.processing;
    context.push(AppRoutes.chatActive);
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final s = ref.watch(stringsProvider);

    return Scaffold(
      body: DecorativeBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.appName,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                        ),
                        Text(
                          '${s.salamGreeting}, ${profile.name.split(' ').first} 👋',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    Stack(
                      children: [
                        GlassCard(
                          padding: const EdgeInsets.all(10),
                          child: const Icon(Icons.notifications_outlined),
                        ),
                        Positioned(
                          right: 2,
                          top: 2,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColors.bgSecondary,
                      child: const AiOrbLogo(size: 70),
                    ),
                    const SizedBox(height: 24),
                    GlassCard(
                      child: Column(
                        children: [
                          Text(s.needHelp, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text(
                            'Type ya bol kar service book karein',
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: ref.watch(chatQuickActionsProvider).map((a) {
                          return GestureDetector(
                            onTap: () => a.opensCustom
                                ? _startChat()
                                : _startChat('${a.label} chahiye'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                              decoration: BoxDecoration(
                                color: AppColors.glassFill,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.glassBorder),
                                boxShadow: const [
                                  BoxShadow(
                                    color: AppColors.glassShadow,
                                    blurRadius: 12,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(a.emoji, style: const TextStyle(fontSize: 18)),
                                  const SizedBox(width: 8),
                                  Text(a.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _input,
                        onSubmitted: (_) => _startChat(),
                        decoration: InputDecoration(
                          hintText: s.chatHint,
                          filled: true,
                          fillColor: AppColors.glassFill,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: () {
                        if (_recording) return;
                        setState(() => _recording = true);
                        Future.delayed(AppDurations.voiceRecord, () {
                          if (mounted) {
                            setState(() => _recording = false);
                            _startChat('AC repair urgent hai');
                          }
                        });
                      },
                      icon: Icon(_recording ? Icons.stop : Icons.mic),
                      style: IconButton.styleFrom(
                        backgroundColor:
                            _recording ? AppColors.error : AppColors.accentLavender,
                      ),
                    ),
                    IconButton.filled(
                      onPressed: () => _startChat(),
                      icon: const Icon(Icons.send),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.textPrimary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              ConsumerBottomNav(
                active: ConsumerTab.chat,
                onTabSelected: (tab) {
                  switch (tab) {
                    case ConsumerTab.chat:
                      break;
                    case ConsumerTab.bookings:
                      context.go(AppRoutes.bookings);
                    case ConsumerTab.profile:
                      context.go(AppRoutes.profile);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
