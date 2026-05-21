import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/session_user.dart';
import '../../../core/network/api_service.dart';

class BookingChatState {
  final List<Map<String, dynamic>> messages;
  final bool isLoading;
  final String? error;

  const BookingChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });
}

class BookingChatNotifier extends StateNotifier<BookingChatState> {
  BookingChatNotifier(this._ref) : super(const BookingChatState());

  final Ref _ref;

  Future<void> load(String bid) async {
    state = const BookingChatState(isLoading: true);
    try {
      final res = await apiService.getBookingMessages(bid);
      final raw = res['messages'] as List<dynamic>? ?? [];
      state = BookingChatState(
        isLoading: false,
        messages: raw.map((m) => Map<String, dynamic>.from(m as Map)).toList(),
      );
    } catch (e) {
      state = BookingChatState(isLoading: false, error: e.toString());
    }
  }

  Future<void> send(String bid, String text) async {
    final uid = resolveUserId(_ref);
    try {
      final res = await apiService.postBookingMessage(
        bid,
        senderId: uid,
        senderRole: 'consumer',
        text: text,
      );
      final msg = Map<String, dynamic>.from(res['message'] as Map);
      state = BookingChatState(
        messages: [...state.messages, msg],
      );
    } catch (e) {
      state = BookingChatState(messages: state.messages, error: e.toString());
    }
  }
}

final bookingChatNotifierProvider =
    StateNotifierProvider.family<BookingChatNotifier, BookingChatState, String>(
  (ref, bid) {
    final n = BookingChatNotifier(ref);
    Future.microtask(() => n.load(bid));
    return n;
  },
);
