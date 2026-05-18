import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../providers/booking_provider.dart';

class BookingPlaceholderScreen extends ConsumerWidget {
  const BookingPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingStateProvider);
    final booking = bookingState.currentBooking;

    final hasGoldDiscount =
        booking?.priceQuote != null &&
        (booking!.priceQuote!.loyaltyDiscount > 0);

    return Scaffold(
      backgroundColor: const Color(0xFF001F1A), // Dark emerald theme
      appBar: AppBar(
        backgroundColor: const Color(0xFF003028),
        elevation: 4,
        title: Text(
          "Booking Receipt",
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD4AF37)),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (booking == null) ...[
              const SizedBox(height: 40),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const Icon(
                      Icons.receipt_long,
                      color: Color(0xFFD4AF37),
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No Active Booking Found",
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Start matching from the home screen and choose a technician to view your receipt.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: const Color(0xFF003028),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(200, 48),
                      ),
                      onPressed: () => context.go('/'),
                      child: Text(
                        "Match a Technician",
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Premium Status Flow Indicator
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Booking Status Track",
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatusNode("Created", true),
                        _buildStatusLine(true),
                        _buildStatusNode("Assigned", true),
                        _buildStatusLine(booking.status != "pending"),
                        _buildStatusNode(
                          "Service",
                          booking.status == "completed",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Beautiful Ticket-Style Receipt Card
              Card(
                color: const Color(0xFF003028),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: hasGoldDiscount
                        ? const Color(0xFFD4AF37)
                        : Colors.white10,
                    width: hasGoldDiscount ? 2 : 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gold Tier User Badge
                      if (hasGoldDiscount) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFD4AF37,
                                ).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFD4AF37),
                                  width: 1,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.workspace_premium,
                                    color: Color(0xFFD4AF37),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "LOYALTY GOLD TIER",
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFFD4AF37),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "AI Seekho Service Ticket",
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Ticket ID: ${booking.bid.substring(0, booking.bid.length > 8 ? 8 : booking.bid.length).toUpperCase()}",
                                style: GoogleFonts.inter(
                                  color: Colors.white38,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF00796B),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            child: Text(
                              booking.status.toUpperCase(),
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white10),
                      const SizedBox(height: 12),

                      _buildTicketDetailRow(
                        Icons.engineering,
                        "Technician",
                        booking.providerId,
                      ),
                      _buildTicketDetailRow(
                        Icons.category,
                        "Service Category",
                        booking.serviceType,
                      ),
                      _buildTicketDetailRow(
                        Icons.calendar_today,
                        "Scheduled Time",
                        booking.scheduledTime,
                      ),
                      _buildTicketDetailRow(
                        Icons.location_on,
                        "Service Address",
                        booking.locationAddress,
                      ),

                      const SizedBox(height: 16),
                      const Divider(color: Colors.white10),
                      const SizedBox(height: 12),

                      if (booking.priceQuote != null) ...[
                        Text(
                          "BILLING RECEIPT",
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFD4AF37),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInvoiceItem(
                          Icons.payments,
                          "Base Technician Rate",
                          "PKR ${booking.priceQuote!.baseRatePkr}",
                        ),
                        _buildInvoiceItem(
                          Icons.commute,
                          "Standard Visit Fee",
                          "PKR ${booking.priceQuote!.visitFee}",
                        ),
                        _buildInvoiceItem(
                          Icons.navigation,
                          "Distance Proximity Surcharge",
                          "PKR ${booking.priceQuote!.distanceFee}",
                        ),
                        _buildInvoiceItem(
                          Icons.priority_high,
                          "Urgency Premium Charge",
                          "PKR ${booking.priceQuote!.urgencySurcharge}",
                        ),
                        _buildInvoiceItem(
                          Icons.architecture,
                          "Complexity Index Cost",
                          "PKR ${booking.priceQuote!.complexityPremium}",
                        ),
                        if (booking.priceQuote!.loyaltyDiscount > 0)
                          _buildInvoiceItem(
                            Icons.star,
                            "Loyalty Tier Discount",
                            "-PKR ${booking.priceQuote!.loyaltyDiscount}",
                            isDiscount: true,
                          ),
                        const Divider(color: Colors.white10, height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "TOTAL AMOUNT DUE",
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "PKR ${booking.priceQuote!.totalPkr}",
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFD4AF37),
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            booking.priceQuote!.breakdownReasoning,
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 11,
                              height: 1.4,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // File Dispute Link
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 48),
                ),
                icon: const Icon(Icons.report_problem),
                onPressed: () {
                  context.push('/dispute');
                },
                label: Text(
                  "File a Post-Service Dispute",
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusNode(String label, bool active) {
    return Column(
      children: [
        Icon(
          active ? Icons.check_circle : Icons.radio_button_off,
          color: active ? const Color(0xFFD4AF37) : Colors.white24,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            color: active ? Colors.white : Colors.white38,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusLine(bool active) {
    return Expanded(
      child: Container(
        height: 2,
        color: active ? const Color(0xFFD4AF37) : Colors.white10,
      ),
    );
  }

  Widget _buildTicketDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF00796B), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(color: Colors.white38, fontSize: 10),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceItem(
    IconData icon,
    String label,
    String price, {
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: isDiscount ? const Color(0xFFD4AF37) : Colors.white38,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: isDiscount ? const Color(0xFFD4AF37) : Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Text(
            price,
            style: GoogleFonts.inter(
              color: isDiscount ? const Color(0xFFD4AF37) : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
