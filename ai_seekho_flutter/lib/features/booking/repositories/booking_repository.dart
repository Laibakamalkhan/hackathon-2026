import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/http_client.dart';
import '../models/booking_model.dart';

class BookingRepository {
  final HttpClient _httpClient;

  BookingRepository({required HttpClient httpClient})
    : _httpClient = httpClient;

  Future<BookingModel> createBooking(BookingModel booking) async {
    final response = await _httpClient.post(
      ApiEndpoints.bookingCreate,
      booking.toJson(),
    );
    final status = response['status'] ?? '';
    if (status == 'success' && response['booking'] != null) {
      return BookingModel.fromJson(response['booking']);
    }
    throw Exception(
      "Failed to establish service booking: ${response['detail'] ?? 'Unknown error'}",
    );
  }
}
