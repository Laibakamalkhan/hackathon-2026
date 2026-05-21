import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/provider_model.dart';
import '../../models/user_role.dart';
/// Preset service shortcuts on chat home — wired into [ChatHomeScreen._startChat].
class ChatQuickAction {
  const ChatQuickAction({
    required this.emoji,
    required this.label,
    this.opensCustom = false,
  });

  final String emoji;
  final String label;

  /// When true, opens chat with empty preset so the user types freely.
  final bool opensCustom;
}

final chatQuickActionsProvider = Provider<List<ChatQuickAction>>((ref) {
  return const [
    ChatQuickAction(emoji: '🔧', label: 'Plumber'),
    ChatQuickAction(emoji: '🌬️', label: 'AC Repair'),
    ChatQuickAction(emoji: '⚡', label: 'Electrician'),
    ChatQuickAction(emoji: '💬', label: 'Kuch aur?', opensCustom: true),
  ];
});

final userRoleProvider = StateProvider<UserRole?>((ref) => null);

final userProfileProvider = StateProvider<UserProfile>((ref) {
  return const UserProfile();
});

final selectedProviderProvider = StateProvider<ServiceProvider?>((ref) => null);

const defaultIntentChips = [
  'AC repair',
  'Plumber',
  'Electrician',
  'G-13 sector',
];

final intentChipsProvider = Provider<List<String>>((ref) => defaultIntentChips);

final selectedBookingIdProvider = StateProvider<String?>((ref) => null);

final otpProvider = StateProvider<String>((ref) => '');

final phoneProvider = StateProvider<String>((ref) => '');

final chatMessageProvider = StateProvider<String>((ref) => '');

final chatNeedsUrgencyProvider = StateProvider<bool>((ref) => false);

final chatFlowPhaseProvider =
    StateProvider<ChatFlowPhase>((ref) => ChatFlowPhase.processing);
