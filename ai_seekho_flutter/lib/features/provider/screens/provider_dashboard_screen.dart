import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_seekho_flutter/app/theme.dart';
import 'package:ai_seekho_flutter/shared/widgets/glass_card.dart';

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  State<ProviderDashboardScreen> createState() => _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  bool _isOnline = true;

  final List<Map<String, dynamic>> _incomingRequests = [
    {
      "id": "RQ-992",
      "seeker": "Irtiza",
      "distance": "1.2 km away",
      "fault": "AC Cooling Failure",
      "detail": "AC running but not throwing cold air. Probably gas leak in condenser.",
      "proposedPrice": "PKR 1,500",
      "time": "3 mins ago"
    },
    {
      "id": "RQ-841",
      "seeker": "Hamza Ali",
      "distance": "3.4 km away",
      "fault": "Compressor Replacement",
      "detail": "Need full compressor exchange for Dawlance 1.5 Ton inverter.",
      "proposedPrice": "PKR 8,000",
      "time": "12 mins ago"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: AppColors.lavender,
      ),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1E1E1E),
                Color(0xFF121212),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Provider App Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => context.go('/home'),
                      ),
                      Column(
                        children: [
                          const Text(
                            "Provider Portal",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Nunito',
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "پرووائیڈر ڈیش بورڈ",
                            style: AppTextStyles.urdu.copyWith(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      // Availability Toggle switch
                      Switch(
                        value: _isOnline,
                        onChanged: (val) {
                          setState(() {
                            _isOnline = val;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(val ? "🟢 Status: Active/Online" : "🔴 Status: Offline"),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        activeThumbColor: Colors.green,
                        inactiveThumbColor: Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Quick Statistics Cards
                  Row(
                    children: [
                      Expanded(
                        child: GlassCard(
                          color: Colors.white.withOpacity(0.08),
                          borderColor: Colors.white.withOpacity(0.1),
                          padding: const EdgeInsets.all(16),
                          child: const Column(
                            children: [
                              Text(
                                "Today's Earnings",
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "PKR 4,800",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GlassCard(
                          color: Colors.white.withOpacity(0.08),
                          borderColor: Colors.white.withOpacity(0.1),
                          padding: const EdgeInsets.all(16),
                          child: const Column(
                            children: [
                              Text(
                                "Jobs Completed",
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "4 Services",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "INCOMING JOBS / لائیو درخواستیں",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                          letterSpacing: 1.1,
                        ),
                      ),
                      if (_isOnline)
                        const Text(
                          "🟢 Scanning...",
                          style: TextStyle(fontSize: 11, color: Colors.green),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Request List View
                  Expanded(
                    child: !_isOnline
                        ? const Center(
                            child: Text(
                              "You are currently offline. Turn on switch to receive jobs.",
                              style: TextStyle(color: Colors.white38),
                            ),
                          )
                        : ListView.separated(
                            itemCount: _incomingRequests.length,
                            separatorBuilder: (c, i) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final req = _incomingRequests[index];
                              return _buildRequestCard(req);
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> req) {
    return GlassCard(
      color: Colors.white.withOpacity(0.06),
      borderColor: Colors.white.withOpacity(0.12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                req["seeker"],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
              ),
              Text(
                req["time"],
                style: const TextStyle(fontSize: 11, color: Colors.white38),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, size: 12, color: Colors.white54),
              const SizedBox(width: 4),
              Text(
                req["distance"],
                style: const TextStyle(fontSize: 11, color: Colors.white54),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            req["fault"],
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.lavender, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            req["detail"],
            style: const TextStyle(fontSize: 12, color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 14),
          Divider(color: Colors.white12),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Estimated Budget", style: TextStyle(fontSize: 10, color: Colors.white38)),
                  Text(req["proposedPrice"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lavender,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Bidded successfully on request ${req["id"]}")),
                  );
                },
                child: const Text("Bid Now / بولی لگائیں", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
