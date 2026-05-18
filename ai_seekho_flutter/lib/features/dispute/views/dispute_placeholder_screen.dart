import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../providers/dispute_provider.dart';
import '../../booking/providers/booking_provider.dart';

class DisputePlaceholderScreen extends ConsumerStatefulWidget {
  const DisputePlaceholderScreen({super.key});

  @override
  ConsumerState<DisputePlaceholderScreen> createState() =>
      _DisputePlaceholderScreenState();
}

class _DisputePlaceholderScreenState
    extends ConsumerState<DisputePlaceholderScreen> {
  late final TextEditingController _bookingIdController;
  final TextEditingController _descController = TextEditingController(
    text: "Technician did not arrive on time, calls are switched off!",
  );
  String _selectedType = "no_show";

  @override
  void initState() {
    super.initState();
    // Pre-fill active booking ID if one is loaded
    final activeBooking = ref.read(bookingStateProvider).currentBooking;
    _bookingIdController = TextEditingController(
      text: activeBooking?.bid ?? "BK-DEMO-99",
    );
  }

  @override
  void dispose() {
    _bookingIdController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disputeState = ref.watch(disputeStateProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF001F1A), // Dark emerald theme
      appBar: AppBar(
        backgroundColor: const Color(0xFF003028),
        elevation: 4,
        title: Text(
          "AI Resolution Mediator",
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
            // Top Header Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.gavel, color: Color(0xFFD4AF37), size: 36),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Empathetic AI Mediation",
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Our AI Agent reviews logs, cancellation patterns, and scores to automatically resolve disputes with instant refunds and empathetic letters in Urdu.",
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Dispute filing inputs
            Text(
              "FILE DISPUTE COMPLAINT",
              style: GoogleFonts.outfit(
                color: const Color(0xFFD4AF37),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),

            // Booking ID Input
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _bookingIdController,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: "Booking Identifier",
                  labelStyle: GoogleFonts.inter(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                  icon: const Icon(
                    Icons.receipt,
                    color: Color(0xFF00796B),
                    size: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Dispute Type Dropdown
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: DropdownButtonFormField<String>(
                initialValue: _selectedType,
                dropdownColor: const Color(0xFF003028),
                style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: "Complaint Category",
                  labelStyle: GoogleFonts.inter(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                  icon: const Icon(
                    Icons.category,
                    color: Color(0xFF00796B),
                    size: 18,
                  ),
                ),
                items: [
                  DropdownMenuItem(
                    value: "no_show",
                    child: Text(
                      "Technician No-Show",
                      style: GoogleFonts.inter(color: Colors.white),
                    ),
                  ),
                  DropdownMenuItem(
                    value: "overcharged",
                    child: Text(
                      "Overcharged Invoice Amount",
                      style: GoogleFonts.inter(color: Colors.white),
                    ),
                  ),
                  DropdownMenuItem(
                    value: "unsatisfactory_work",
                    child: Text(
                      "Poor Service/Work Quality",
                      style: GoogleFonts.inter(color: Colors.white),
                    ),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedType = val;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 14),

            // Dispute Details Input
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _descController,
                maxLines: 3,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: "Elaborate Complaint Details",
                  labelStyle: GoogleFonts.inter(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                  icon: const Icon(
                    Icons.description,
                    color: Color(0xFF00796B),
                    size: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Submit Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: const Color(0xFF003028),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: disputeState.isLoading
                  ? null
                  : () {
                      ref
                          .read(disputeStateProvider.notifier)
                          .fileEmpatheticDispute(
                            bookingId: _bookingIdController.text,
                            disputeType: _selectedType,
                            description: _descController.text,
                          );
                    },
              child: disputeState.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Color(0xFF003028),
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      "MEDITATE DISPUTE NOW",
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
            ),

            if (disputeState.error != null) ...[
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.red.shade900.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red),
                ),
                padding: const EdgeInsets.all(12),
                child: Text(
                  "Error: ${disputeState.error}",
                  style: GoogleFonts.inter(
                    color: Colors.red.shade100,
                    fontSize: 13,
                  ),
                ),
              ),
            ],

            // Gemini EM-Mediation Resolution Summary Container
            if (disputeState.resolvedDispute != null) ...[
              const SizedBox(height: 30),
              Row(
                children: [
                  const Icon(Icons.verified, color: Colors.greenAccent),
                  const SizedBox(width: 8),
                  Text(
                    "Mediation Result — Auto Resolved",
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF003028),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFD4AF37),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Dispute ID: ${disputeState.resolvedDispute!.disputeId.toUpperCase()}",
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.greenAccent,
                              width: 0.5,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Text(
                            disputeState.resolvedDispute!.status.toUpperCase(),
                            style: GoogleFonts.outfit(
                              color: Colors.greenAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white10, height: 24),

                    if (disputeState.resolvedDispute!.resolution != null) ...[
                      // Payout metric row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Resolution Payout Mode:",
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            disputeState.resolvedDispute!.resolution!.type
                                .toUpperCase(),
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Compensation Amount:",
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            "PKR ${disputeState.resolvedDispute!.resolution!.amountPkr}",
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFD4AF37),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "AI Mediation Log / Reasoning:",
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFD4AF37),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        disputeState.resolvedDispute!.resolution!.reasoning,
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Empathetic Urdu Parchment Container
                      Text(
                        "EMPATHETIC RESOLUTION CORRESPONDENCE",
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFD4AF37),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFE8F5E9,
                          ), // Light mint parchment look
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF81C784),
                            width: 1.5,
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.email,
                                  color: Color(0xFF2E7D32),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Support Email to Customer",
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFF2E7D32),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: Colors.black12, height: 16),
                            Text(
                              disputeState
                                  .resolvedDispute!
                                  .resolution!
                                  .empatheticResponse,
                              style: GoogleFonts.inter(
                                color: const Color(0xFF1B5E20),
                                fontSize: 13,
                                height: 1.5,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
