import 'package:flutter_test/flutter_test.dart';
import 'package:ai_seekho/models/provider_model.dart';
import 'package:ai_seekho/models/booking_model.dart';

void main() {
  group('ServiceProvider.fromJson', () {
    test('Should parse provider ID prioritizing pid -> id -> provider_id', () {
      // 1. Prioritize pid
      final json1 = {
        'pid': 'P001',
        'id': 'fallback_id',
        'provider_id': 'fallback_provider_id',
        'name': 'Hassan Mahmood',
        'service_categories': ['general_home', 'mechanics'],
      };
      final provider1 = ServiceProvider.fromJson(json1);
      expect(provider1.id, equals('P001'));

      // 2. Fallback to id
      final json2 = {
        'id': 'id_002',
        'provider_id': 'fallback_provider_id',
        'name': 'Farhan Siddiqui',
      };
      final provider2 = ServiceProvider.fromJson(json2);
      expect(provider2.id, equals('id_002'));

      // 3. Fallback to provider_id
      final json3 = {
        'provider_id': 'prov_003',
        'name': 'Yasmin Begum',
      };
      final provider3 = ServiceProvider.fromJson(json3);
      expect(provider3.id, equals('prov_003'));
    });

    test('Should parse service prioritizing service_categories[0] -> service -> service_type', () {
      // 1. service_categories[0]
      final json1 = {
        'pid': 'P001',
        'service_categories': ['general_home', 'mechanics'],
        'service': 'fallback_service',
        'service_type': 'fallback_service_type',
      };
      final provider1 = ServiceProvider.fromJson(json1);
      expect(provider1.service, equals('general_home'));

      // 2. fallback to service
      final json2 = {
        'pid': 'P001',
        'service': 'plumbing',
        'service_type': 'fallback_service_type',
      };
      final provider2 = ServiceProvider.fromJson(json2);
      expect(provider2.service, equals('plumbing'));

      // 3. fallback to service_type
      final json3 = {
        'pid': 'P001',
        'service_type': 'ac_repair',
      };
      final provider3 = ServiceProvider.fromJson(json3);
      expect(provider3.service, equals('ac_repair'));
    });

    test('Should safely parse rating, reviews, distance, matchScore, and verified', () {
      final json = {
        'pid': 'P001',
        'name': 'Hassan Mahmood',
        'rating': 4.9,
        'total_reviews': 164,
        'distance_km': 3.4,
        'match_score': 92.4,
        'verified': true,
      };

      final provider = ServiceProvider.fromJson(json);
      expect(provider.rating, equals(4.9));
      expect(provider.reviews, equals(164));
      expect(provider.distance, equals('3.4 km'));
      expect(provider.matchScore, equals(92));
      expect(provider.verified, isTrue);
    });
  });

  group('Booking.fromJson', () {
    test('Should parse booking ID prioritizing bid -> booking_id -> id', () {
      // 1. Prioritize bid
      final json1 = {
        'bid': 'BK-ABC123',
        'booking_id': 'fallback_booking_id',
        'id': 'fallback_id',
        'scheduled_time': '2026-05-20T11:00:00',
      };
      final booking1 = Booking.fromJson(json1);
      expect(booking1.id, equals('BK-ABC123'));

      // 2. Fallback to booking_id
      final json2 = {
        'booking_id': 'BK-XYZ456',
        'id': 'fallback_id',
        'scheduled_time': '2026-05-20T11:00:00',
      };
      final booking2 = Booking.fromJson(json2);
      expect(booking2.id, equals('BK-XYZ456'));

      // 3. Fallback to id
      final json3 = {
        'id': 'BK-789',
        'scheduled_time': '2026-05-20T11:00:00',
      };
      final booking3 = Booking.fromJson(json3);
      expect(booking3.id, equals('BK-789'));
    });

    test('Should resolve provider_name from flat field or nested provider map', () {
      final fromFlat = Booking.fromJson({
        'bid': 'BK-1',
        'provider_name': 'Hassan Mahmood',
        'scheduled_time': '2026-05-20T11:00:00',
      });
      expect(fromFlat.providerName, equals('Hassan Mahmood'));

      final fromNested = Booking.fromJson({
        'bid': 'BK-2',
        'provider': {'pid': 'P1', 'name': 'Ali AC Services'},
        'scheduled_time': '2026-05-20T11:00:00',
      });
      expect(fromNested.providerName, equals('Ali AC Services'));
    });

    test('Should parse location address from nested Map or flat fields', () {
      // 1. Nested map with address
      final json1 = {
        'bid': 'BK-ABC123',
        'location': {
          'address': 'H-13 Sector, Islamabad',
          'lat': 33.62621,
          'lng': 72.95738
        },
        'scheduled_time': '2026-05-20T11:00:00',
      };
      final booking1 = Booking.fromJson(json1);
      expect(booking1.location, equals('H-13 Sector, Islamabad'));

      // 2. Nested map with area fallback
      final json2 = {
        'bid': 'BK-ABC123',
        'location': {
          'area': 'G-13',
          'lat': 33.62621,
          'lng': 72.95738
        },
        'scheduled_time': '2026-05-20T11:00:00',
      };
      final booking2 = Booking.fromJson(json2);
      expect(booking2.location, equals('G-13'));

      // 3. Flat location_address field
      final json3 = {
        'bid': 'BK-ABC123',
        'location_address': 'F-11 Sector, Islamabad',
        'scheduled_time': '2026-05-20T11:00:00',
      };
      final booking3 = Booking.fromJson(json3);
      expect(booking3.location, equals('F-11 Sector, Islamabad'));
    });

    test('Should parse price dynamically from nested single or double nested structures', () {
      // 1. Single nesting: price_quote['quote']['total_pkr']
      final json1 = {
        'bid': 'BK-111',
        'scheduled_time': '2026-05-20T11:00:00',
        'price_quote': {
          'provider_id': 'P001',
          'quote': {
            'total_pkr': 1390,
            'currency': 'PKR',
          }
        }
      };
      final booking1 = Booking.fromJson(json1);
      expect(booking1.price, equals('PKR 1390'));

      // 2. Double nesting: price_quote['quote']['quote']['total_pkr']
      final json2 = {
        'bid': 'BK-222',
        'scheduled_time': '2026-05-20T11:00:00',
        'price_quote': {
          'quote': {
            'quote': {
              'total_pkr': 1450,
              'currency': 'PKR',
            }
          }
        }
      };
      final booking2 = Booking.fromJson(json2);
      expect(booking2.price, equals('PKR 1450'));
    });
  });
}
