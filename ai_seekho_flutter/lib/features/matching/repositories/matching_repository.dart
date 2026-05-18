import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/http_client.dart';
import '../../../core/network/websocket_client.dart';
import '../models/matching_models.dart';

class MatchingRepository {
  final HttpClient _httpClient;
  final WebSocketClient _wsClient;

  MatchingRepository({
    required HttpClient httpClient,
    required WebSocketClient wsClient,
  }) : _httpClient = httpClient,
       _wsClient = wsClient;

  Future<MatchResultModel> postMatchRequest({
    required String query,
    required double lat,
    required double lng,
    required String sessionId,
  }) async {
    final response = await _httpClient.post(ApiEndpoints.match, {
      "query": query,
      "lat": lat,
      "lng": lng,
      "session_id": sessionId,
    });
    return MatchResultModel.fromJson(response);
  }

  Future<List<ProviderModel>> getProviders() async {
    final response = await _httpClient.get(ApiEndpoints.providers);
    final list = response['providers'] as List? ?? [];
    return list.map((item) => ProviderModel.fromJson(item)).toList();
  }

  Stream<Map<String, dynamic>> listenToReasoningStream(String sessionId) {
    return _wsClient.connect(ApiEndpoints.wsTrace(sessionId));
  }

  void sendWsQuery(String query, double lat, double lng) {
    _wsClient.send({"query": query, "lat": lat, "lng": lng});
  }

  void disconnectWs() {
    _wsClient.disconnect();
  }
}
