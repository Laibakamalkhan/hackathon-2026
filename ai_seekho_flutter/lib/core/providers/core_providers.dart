import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/http_client.dart';
import '../network/websocket_client.dart';
import '../../features/matching/repositories/matching_repository.dart';
import '../../features/booking/repositories/booking_repository.dart';
import '../../features/dispute/repositories/dispute_repository.dart';

final httpClientProvider = Provider<HttpClient>((ref) {
  return HttpClient();
});

final webSocketClientProvider = Provider<WebSocketClient>((ref) {
  return WebSocketClient();
});

final matchingRepositoryProvider = Provider<MatchingRepository>((ref) {
  return MatchingRepository(
    httpClient: ref.watch(httpClientProvider),
    wsClient: ref.watch(webSocketClientProvider),
  );
});

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository(httpClient: ref.watch(httpClientProvider));
});

final disputeRepositoryProvider = Provider<DisputeRepository>((ref) {
  return DisputeRepository(httpClient: ref.watch(httpClientProvider));
});
