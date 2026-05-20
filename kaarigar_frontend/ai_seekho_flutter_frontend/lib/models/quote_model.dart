class QuoteLine {
  final String label;
  final double amount;

  const QuoteLine({
    required this.label,
    required this.amount,
  });
}

class QuoteDisplay {
  final double totalPkr;
  final List<QuoteLine> lines;
  final String currency;

  const QuoteDisplay({
    required this.totalPkr,
    required this.lines,
    this.currency = 'PKR',
  });

  /// Factory method to defensively parse coordinator quote structure.
  /// Handles both single and double nested pricing maps safely.
  factory QuoteDisplay.fromCoordinatorQuote(Map<String, dynamic>? raw) {
    if (raw == null) {
      return const QuoteDisplay(totalPkr: 0.0, lines: []);
    }

    // Defensive lookup: find the inner breakdown map
    final nestedQuote = raw['quote'];
    final Map<String, dynamic> breakdown = (nestedQuote is Map)
        ? ((nestedQuote['quote'] is Map) ? Map<String, dynamic>.from(nestedQuote['quote']) : Map<String, dynamic>.from(nestedQuote))
        : Map<String, dynamic>.from(raw);

    final num totalRaw = breakdown['total_pkr'] ?? breakdown['total'] ?? breakdown['amount'] ?? 0.0;
    final totalPkr = totalRaw.toDouble();
    final currency = (breakdown['currency'] ?? 'PKR').toString();
    final lines = <QuoteLine>[];

    void addLine(String key, String label, {bool isDiscount = false}) {
      if (breakdown.containsKey(key) && breakdown[key] != null) {
        final num rawVal = breakdown[key];
        final val = rawVal.toDouble();
        if (val != 0.0) {
          lines.add(QuoteLine(
            label: label,
            amount: isDiscount ? -val.abs() : val,
          ));
        }
      }
    }

    addLine('base_service_fee', 'Base Service Fee');
    addLine('visit_fee', 'Visiting Fee');
    addLine('distance_fee', 'Travel Distance Fee');
    addLine('urgency_surcharge', 'Urgency Surcharge');
    addLine('complexity_surcharge', 'Complexity Surcharge');
    addLine('loyalty_discount', 'Loyalty Discount', isDiscount: true);

    return QuoteDisplay(
      totalPkr: totalPkr,
      lines: lines,
      currency: currency,
    );
  }
}
