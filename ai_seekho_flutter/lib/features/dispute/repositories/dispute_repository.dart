import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/http_client.dart';
import '../models/dispute_model.dart';

class DisputeRepository {
  final HttpClient _httpClient;

  DisputeRepository({required HttpClient httpClient})
    : _httpClient = httpClient;

  Future<DisputeModel> fileDispute({
    required String bookingId,
    required String disputeType,
    required String description,
  }) async {
    final response = await _httpClient.post(ApiEndpoints.disputeCreate, {
      "booking_id": bookingId,
      "type": disputeType,
      "description": description,
    });
    final status = response['status'] ?? '';
    if (status == 'success' && response['dispute'] != null) {
      return DisputeModel.fromJson(response['dispute']);
    }
    throw Exception(
      "Failed to file dispute: ${response['detail'] ?? 'Unknown error'}",
    );
  }
}
