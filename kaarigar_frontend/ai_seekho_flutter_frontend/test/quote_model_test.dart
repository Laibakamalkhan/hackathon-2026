import 'package:flutter_test/flutter_test.dart';
import 'package:ai_seekho/models/quote_model.dart';

void main() {
  group('QuoteDisplay.fromCoordinatorQuote', () {
    test('Should handle null raw quote gracefully', () {
      final quote = QuoteDisplay.fromCoordinatorQuote(null);
      expect(quote.totalPkr, equals(0.0));
      expect(quote.lines, isEmpty);
      expect(quote.currency, equals('PKR'));
    });

    test('Should parse single-nested coordinator pricing quote successfully', () {
      final rawQuote = {
        'provider_id': 'P001',
        'quote': {
          'base_service_fee': 1100,
          'visit_fee': 200,
          'distance_fee': 90,
          'urgency_surcharge': 0,
          'complexity_surcharge': 150,
          'loyalty_discount': 50,
          'total_pkr': 1490,
          'currency': 'PKR',
          'breakdown_reasoning': 'Base service fee with travel and complexity additions minus loyalty discount.'
        }
      };

      final quote = QuoteDisplay.fromCoordinatorQuote(rawQuote);
      expect(quote.totalPkr, equals(1490.0));
      expect(quote.currency, equals('PKR'));
      expect(quote.lines.length, equals(5)); // base, visit, distance, complexity, loyalty (urgency is 0, so ignored)

      expect(quote.lines[0].label, equals('Base Service Fee'));
      expect(quote.lines[0].amount, equals(1100.0));

      expect(quote.lines[1].label, equals('Visiting Fee'));
      expect(quote.lines[1].amount, equals(200.0));

      expect(quote.lines[2].label, equals('Travel Distance Fee'));
      expect(quote.lines[2].amount, equals(90.0));

      expect(quote.lines[3].label, equals('Complexity Surcharge'));
      expect(quote.lines[3].amount, equals(150.0));

      expect(quote.lines[4].label, equals('Loyalty Discount'));
      expect(quote.lines[4].amount, equals(-50.0)); // Loyalty discount must be negative
    });

    test('Should parse double-nested coordinator pricing quote and handle negative discounts', () {
      final rawQuote = {
        'quote': {
          'quote': {
            'base_service_fee': 950,
            'visit_fee': 200,
            'distance_fee': 40,
            'urgency_surcharge': 100,
            'complexity_surcharge': 0,
            'loyalty_discount': -100,
            'total_pkr': 1190,
            'currency': 'PKR'
          }
        }
      };

      final quote = QuoteDisplay.fromCoordinatorQuote(rawQuote);
      expect(quote.totalPkr, equals(1190.0));
      expect(quote.currency, equals('PKR'));
      expect(quote.lines.length, equals(5));

      final loyaltyLine = quote.lines.firstWhere((l) => l.label == 'Loyalty Discount');
      expect(loyaltyLine.amount, equals(-100.0));

      final urgencyLine = quote.lines.firstWhere((l) => l.label == 'Urgency Surcharge');
      expect(urgencyLine.amount, equals(100.0));
    });
  });
}
