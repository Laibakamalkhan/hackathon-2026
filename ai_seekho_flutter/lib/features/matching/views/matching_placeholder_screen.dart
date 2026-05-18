import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../providers/matching_provider.dart';
import '../../booking/models/booking_model.dart';
import '../../booking/providers/booking_provider.dart';

class MatchingPlaceholderScreen extends ConsumerStatefulWidget {
  const MatchingPlaceholderScreen({super.key});

  @override
  ConsumerState<MatchingPlaceholderScreen> createState() =>
      _MatchingPlaceholderScreenState();
}

class _MatchingPlaceholderScreenState
    extends ConsumerState<MatchingPlaceholderScreen> {
  final TextEditingController _queryController = TextEditingController(
    text:
        "AC kharab ho gaya hai, kal subah G-13 mein technician chahiye, budget zyada nahi hai",
  );

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  // Pre-filled stress-test scenarios
  final List<Map<String, dynamic>> _demoScenarios = [
    {
      "title": "Scenario A: Mixed Chat Request",
      "subtitle":
          "Roman Urdu AC request with high urgency & budget sensitivity.",
      "query":
          "AC kharab ho gaya hai, kal subah G-13 mein technician chahiye, budget zyada nahi hai",
      "action": "ws", // Use WebSocket Stream
    },
    {
      "title": "Scenario B: Low Confidence / Ambiguous",
      "subtitle": "Extremely short request causing a clarification question.",
      "query": "Plumber",
      "action": "rest", // Use REST Match
    },
    {
      "title": "Scenario C: Overlapping Slot Conflict",
      "subtitle": "Attempt to double-book a technician's unavailable window.",
      "query": "AC bilkul cooling nahi kar raha, foran theek karo!",
      "action": "ws",
    },
    {
      "title": "Scenario D: No Provider Available",
      "subtitle": "Request in G-9 Islamabad where no AC service is loaded.",
      "query": "AC repair G-9 Sector kal dopehar ko",
      "action": "rest",
    },
    {
      "title": "Scenario E: Post-Service Dispute",
      "subtitle": "Submit no-show dispute to get automatic refund letter.",
      "query": "DS-TEST",
      "action": "route_dispute",
    },
  ];

  void _showStressTestPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF003028),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 20,
                offset: Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(
                    Icons.psychology,
                    color: Color(0xFFD4AF37),
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Stress Test Mode — Demo Panel",
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                "Trigger predefined PRD scenarios live during evaluations:",
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _demoScenarios.length,
                  itemBuilder: (ctx, index) {
                    final sc = _demoScenarios[index];
                    return Card(
                      color: const Color(0xFF004D40),
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.white10),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.pop(context);
                          if (sc["action"] == "route_dispute") {
                            context.push('/dispute');
                          } else {
                            setState(() {
                              _queryController.text = sc["query"];
                            });
                            if (sc["action"] == "ws") {
                              ref
                                  .read(matchingStateProvider.notifier)
                                  .startReasoningStream(
                                    query: sc["query"],
                                    lat: 33.649,
                                    lng: 72.973,
                                    sessionId: "demo-session-ws-${index + 1}",
                                  );
                            } else {
                              ref
                                  .read(matchingStateProvider.notifier)
                                  .runRestMatch(
                                    query: sc["query"],
                                    lat: 33.649,
                                    lng: 72.973,
                                    sessionId: "demo-session-rest-${index + 1}",
                                  );
                            }
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: const Color(0xFF003028),
                                child: Text(
                                  String.fromCharCode(65 + index),
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFFD4AF37),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sc["title"],
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      sc["subtitle"],
                                      style: GoogleFonts.inter(
                                        color: Colors.white70,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.play_arrow,
                                color: Color(0xFFD4AF37),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final matchingState = ref.watch(matchingStateProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF001F1A), // Sleek emerald dark background
      appBar: AppBar(
        backgroundColor: const Color(0xFF003028),
        elevation: 4,
        title: Row(
          children: [
            const Icon(Icons.settings_suggest, color: Color(0xFFD4AF37)),
            const SizedBox(width: 8),
            Text(
              "AI Seekho Platform",
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: "Bookings",
            icon: const Icon(Icons.receipt_long, color: Color(0xFFD4AF37)),
            onPressed: () => context.push('/booking'),
          ),
          IconButton(
            tooltip: "Disputes",
            icon: const Icon(Icons.gavel, color: Color(0xFFD4AF37)),
            onPressed: () => context.push('/dispute'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFD4AF37),
        icon: const Icon(Icons.flash_on, color: Color(0xFF001F1A)),
        label: Text(
          "STRESS TEST",
          style: GoogleFonts.outfit(
            color: const Color(0xFF001F1A),
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        onPressed: () => _showStressTestPanel(context),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Gradient Intro
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF003028), Color(0xFF001F1A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Apni Zindagi Asaan Karo!",
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Type Plumber, Electrician or AC service request in Roman Urdu or English:",
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _queryController,
                          style: GoogleFonts.inter(color: Colors.white),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText:
                                "E.g., AC cooling nahi kar raha foran aao...",
                            hintStyle: GoogleFonts.inter(color: Colors.white38),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00796B),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                icon: const Icon(Icons.rocket_launch, size: 18),
                                onPressed: matchingState.isLoading
                                    ? null
                                    : () {
                                        ref
                                            .read(
                                              matchingStateProvider.notifier,
                                            )
                                            .runRestMatch(
                                              query: _queryController.text,
                                              lat: 33.649,
                                              lng: 72.973,
                                              sessionId: "session-rest-123",
                                            );
                                      },
                                label: Text(
                                  "REST Match",
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD4AF37),
                                  foregroundColor: const Color(0xFF003028),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                icon: const Icon(Icons.stream, size: 18),
                                onPressed: matchingState.isLoading
                                    ? null
                                    : () {
                                        ref
                                            .read(
                                              matchingStateProvider.notifier,
                                            )
                                            .startReasoningStream(
                                              query: _queryController.text,
                                              lat: 33.649,
                                              lng: 72.973,
                                              sessionId: "session-ws-456",
                                            );
                                      },
                                label: Text(
                                  "Live ADK Stream",
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (matchingState.isLoading) ...[
                    const SizedBox(height: 10),
                    const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFD4AF37),
                      ),
                    ),
                  ],

                  if (matchingState.liveStatusMessage.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF004D40),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFD4AF37).withOpacity(0.3),
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(Icons.sync, color: Color(0xFFD4AF37)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              matchingState.liveStatusMessage,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (matchingState.error != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red.shade900.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        "Error: ${matchingState.error}",
                        style: GoogleFonts.inter(
                          color: Colors.red.shade100,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],

                  // Live ADK Reasoning Glass
                  if (matchingState.steps.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.psychology, color: Color(0xFFD4AF37)),
                        const SizedBox(width: 8),
                        Text(
                          "Live ADK Reasoning Glass Trace",
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: matchingState.steps.length,
                      itemBuilder: (context, index) {
                        final step = matchingState.steps[index];
                        IconData stepIcon = Icons.info_outline;
                        Color agentColor = const Color(0xFFD4AF37);
                        if (step.agent.toLowerCase().contains("intent")) {
                          stepIcon = Icons.translate;
                          agentColor = const Color(0xFF4FC3F7);
                        } else if (step.agent.toLowerCase().contains("match")) {
                          stepIcon = Icons.people_alt;
                          agentColor = const Color(0xFF81C784);
                        } else if (step.agent.toLowerCase().contains("price")) {
                          stepIcon = Icons.monetization_on;
                          agentColor = const Color(0xFFFFD54F);
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundColor: agentColor.withOpacity(0.2),
                                  radius: 20,
                                  child: Icon(
                                    stepIcon,
                                    color: agentColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "${step.agent} → ${step.action}",
                                            style: GoogleFonts.outfit(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black26,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            child: Text(
                                              "${step.latencyMs}ms",
                                              style: GoogleFonts.inter(
                                                color: const Color(0xFFD4AF37),
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        step.reasoning,
                                        style: GoogleFonts.inter(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 6,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white10,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            child: Text(
                                              "Confidence: ${(step.confidence * 100).toStringAsFixed(0)}%",
                                              style: GoogleFonts.inter(
                                                color: Colors.white60,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                          if (step.toolsUsed.isNotEmpty)
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white10,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              child: Text(
                                                "Tools: ${step.toolsUsed.join(', ')}",
                                                style: GoogleFonts.inter(
                                                  color: Colors.white60,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],

                  // Matched Service Providers
                  if (matchingState.matchingProviders.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.verified, color: Colors.greenAccent),
                        const SizedBox(width: 8),
                        Text(
                          "Verified Matching Professionals",
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...matchingState.matchingProviders.asMap().entries.map((
                      entry,
                    ) {
                      final idx = entry.key;
                      final prov = entry.value;

                      String medal = "🥉";
                      if (idx == 0) medal = "🥇";
                      if (idx == 1) medal = "🥈";

                      return Card(
                        color: const Color(0xFF003028),
                        margin: const EdgeInsets.only(bottom: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: idx == 0
                                ? const Color(0xFFD4AF37)
                                : Colors.white10,
                            width: idx == 0 ? 1.5 : 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        medal,
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        prov.name,
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.greenAccent.withOpacity(
                                        0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.greenAccent,
                                        width: 0.5,
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    child: Text(
                                      "${prov.matchScore.toStringAsFixed(1)}% Match",
                                      style: GoogleFonts.outfit(
                                        color: Colors.greenAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(color: Colors.white10, height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Location: ${prov.area} (${prov.distanceKm.toStringAsFixed(1)} km away)",
                                    style: GoogleFonts.inter(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    "⭐ ${prov.rating} (${prov.experienceYears}y exp)",
                                    style: GoogleFonts.inter(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Cancellation Rate: ${(prov.cancellationRate * 100).toStringAsFixed(0)}%",
                                style: GoogleFonts.inter(
                                  color: prov.cancellationRate > 0.05
                                      ? Colors.redAccent
                                      : Colors.white60,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 10),

                              // WOW Factor 2 Accordion
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.03),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.check_circle_outline,
                                          color: Color(0xFFD4AF37),
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "AI ne kyun choose kiya?",
                                          style: GoogleFonts.outfit(
                                            color: const Color(0xFFD4AF37),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      idx == 0
                                          ? "✓ AC specialist (12 saal ka tajruba)\n✓ 96% waqt per — area mein sab se behtareen record\n✓ Aap ke budget ke mutabiq sasta setup"
                                          : "✓ Qareeb tareen technician hai lekin on-time records thoday kam hain.",
                                      style: GoogleFonts.inter(
                                        color: Colors.white70,
                                        fontSize: 11,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 12),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD4AF37),
                                  foregroundColor: const Color(0xFF003028),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  minimumSize: const Size(double.infinity, 44),
                                ),
                                onPressed: () async {
                                  final booking = BookingModel(
                                    bid: '',
                                    userId: "user-flutter-demo",
                                    providerId: prov.pid,
                                    serviceType: "ac_repair",
                                    status: "pending",
                                    scheduledTime: DateTime.now()
                                        .add(const Duration(hours: 2))
                                        .toIso8601String(),
                                    locationAddress: "G-13 Sector, Islamabad",
                                    lat: 33.649,
                                    lng: 72.973,
                                    priceQuote: matchingState.primaryQuote,
                                    intentRaw: _queryController.text,
                                    intentParsed: {
                                      "service_type": "ac_repair",
                                      "urgency": "high",
                                    },
                                    createdAt: '',
                                    updatedAt: '',
                                  );
                                  final success = await ref
                                      .read(bookingStateProvider.notifier)
                                      .createServiceBooking(booking);

                                  if (!context.mounted) return;

                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Booking successfully posted!",
                                        ),
                                      ),
                                    );
                                    context.push('/booking');
                                  } else {
                                    final err =
                                        ref.read(bookingStateProvider).error ??
                                        "Booking conflict encountered.";
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        backgroundColor: const Color(
                                          0xFF003028,
                                        ),
                                        title: Text(
                                          "Booking Conflict / Error",
                                          style: GoogleFonts.outfit(
                                            color: Colors.white,
                                          ),
                                        ),
                                        content: Text(
                                          err,
                                          style: GoogleFonts.inter(
                                            color: Colors.white70,
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(),
                                            child: Text(
                                              "OK",
                                              style: GoogleFonts.outfit(
                                                color: const Color(0xFFD4AF37),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                                child: Text(
                                  "Book Technician Now",
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
