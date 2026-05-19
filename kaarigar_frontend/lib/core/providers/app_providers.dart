import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/booking_model.dart';
import '../../models/provider_model.dart';
import '../../models/user_role.dart';
import '../../services/mock_data_service.dart';

final userRoleProvider = StateProvider<UserRole?>((ref) => null);

final userProfileProvider = StateProvider<UserProfile>((ref) {
  return const UserProfile();
});

final selectedProviderProvider = StateProvider<ServiceProvider?>((ref) => null);

final intentChipsProvider =
    StateProvider<List<String>>((ref) => List.from(MockDataService.intentChips));

final bookingsProvider = StateProvider<List<Booking>>((ref) {
  return List.from(MockDataService.bookings);
});

final selectedBookingIdProvider = StateProvider<String?>((ref) => null);

final otpProvider = StateProvider<String>((ref) => '');

final phoneProvider = StateProvider<String>((ref) => '');

final chatMessageProvider = StateProvider<String>((ref) => '');

final chatNeedsUrgencyProvider = StateProvider<bool>((ref) => false);

final chatFlowPhaseProvider =
    StateProvider<ChatFlowPhase>((ref) => ChatFlowPhase.processing);
