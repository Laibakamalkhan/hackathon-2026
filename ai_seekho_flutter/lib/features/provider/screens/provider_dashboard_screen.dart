import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_seekho_flutter/app/theme.dart';
import 'package:ai_seekho_flutter/shared/widgets/glass_card.dart';
import 'package:ai_seekho_flutter/core/network/api_service.dart';

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  State<ProviderDashboardScreen> createState() => _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen>
    with SingleTickerProviderStateMixin {
  bool _isOnline = true;
  late TabController _tabController;

  // Pending bookings from real API
  List<Map<String, dynamic>> _pendingBookings = [];
  bool _isLoadingPending = false;

  // Static incoming requests (demo bids not yet in Firestore)
  final List<Map<String, dynamic>> _incomingRequests = [
    {
      "id": "RQ-992", "seeker": "Irtiza", "distance": "1.2 km away",
      "fault": "AC Cooling Failure",
      "detail": "AC running but not throwing cold air. Probably gas leak in condenser.",
      "proposedPrice": "PKR 1,500", "time": "3 mins ago"
    },
    {
      "id": "RQ-841", "seeker": "Hamza Ali", "distance": "3.4 km away",
      "fault": "Compressor Replacement",
      "detail": "Need full compressor exchange for Dawlance 1.5 Ton inverter.",
      "proposedPrice": "PKR 8,000", "time": "12 mins ago"
    },
  ];

  static const String _providerDemoId = 'provider_demo_001';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPendingBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPendingBookings() async {
    setState(() => _isLoadingPending = true);
    try {
      final result = await apiService.getUserBookings(_providerDemoId);
      final List all = result['bookings'] as List? ?? [];
      final pending = all
          .whereType<Map<String, dynamic>>()
          .where((b) => b['status'] == 'pending')
          .toList();
      if (mounted) setState(() { _pendingBookings = pending; _isLoadingPending = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoadingPending = false);
    }
  }

  Future<void> _updateStatus(String bid, String newStatus) async {
    try {
      await apiService.updateBookingStatus(bid, newStatus);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newStatus == 'confirmed'
              ? '✅ Booking $bid confirmed!'
              : '❌ Booking $bid declined.'),
          backgroundColor: newStatus == 'confirmed' ? AppColors.success : AppColors.error,
        ),
      );
      _loadPendingBookings();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    }
  }

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
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Color(0xFF1E1E1E), Color(0xFF121212)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => context.go('/home'),
                      ),
                      Column(children: [
                        const Text("Provider Portal",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                                fontFamily: 'Nunito', color: Colors.white)),
                        Text("پرووائیڈر ڈیش بورڈ",
                            style: AppTextStyles.urdu.copyWith(fontSize: 12, color: Colors.white70)),
                      ]),
                      Switch(
                        value: _isOnline,
                        onChanged: (val) {
                          setState(() => _isOnline = val);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(val ? "🟢 Active/Online" : "🔴 Offline"),
                            duration: const Duration(seconds: 1),
                          ));
                        },
                        activeThumbColor: Colors.green,
                        inactiveThumbColor: Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Stats row
                  Row(children: [
                    Expanded(child: GlassCard(
                      color: Colors.white.withOpacity(0.08),
                      borderColor: Colors.white.withOpacity(0.1),
                      padding: const EdgeInsets.all(16),
                      child: const Column(children: [
                        Text("Today's Earnings", style: TextStyle(color: Colors.white70, fontSize: 12)),
                        SizedBox(height: 4),
                        Text("PKR 4,800", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      ]),
                    )),
                    const SizedBox(width: 16),
                    Expanded(child: GlassCard(
                      color: Colors.white.withOpacity(0.08),
                      borderColor: Colors.white.withOpacity(0.1),
                      padding: const EdgeInsets.all(16),
                      child: Column(children: [
                        const Text("Pending Requests", style: TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          "${_pendingBookings.length + _incomingRequests.length}",
                          style: TextStyle(
                            color: _pendingBookings.isNotEmpty ? Colors.orangeAccent : Colors.white,
                            fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ]),
                    )),
                  ]),
                  const SizedBox(height: 20),

                  // Tabs
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(AppRadius.chip),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: AppColors.lavender.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(AppRadius.chip),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white38,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      tabs: [
                        Tab(text: "Incoming Jobs (${_incomingRequests.length})"),
                        Tab(
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            const Text("Pending Bookings"),
                            if (_pendingBookings.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange, borderRadius: BorderRadius.circular(10)),
                                child: Text("${_pendingBookings.length}",
                                    style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child: _isOnline
                        ? TabBarView(
                            controller: _tabController,
                            children: [
                              _buildIncomingList(),
                              _buildPendingBookingsList(),
                            ],
                          )
                        : const Center(
                            child: Text(
                              "You are currently offline.\nTurn on switch to receive jobs.",
                              style: TextStyle(color: Colors.white38),
                              textAlign: TextAlign.center,
                            ),
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

  Widget _buildIncomingList() {
    return ListView.separated(
      itemCount: _incomingRequests.length,
      separatorBuilder: (c, i) => const SizedBox(height: 16),
      itemBuilder: (context, index) => _buildRequestCard(_incomingRequests[index]),
    );
  }

  Widget _buildPendingBookingsList() {
    if (_isLoadingPending) {
      return const Center(child: CircularProgressIndicator(color: AppColors.lavender));
    }
    if (_pendingBookings.isEmpty) {
      return const Center(
        child: Text("Koi pending booking nahi hai.",
            style: TextStyle(color: Colors.white38), textAlign: TextAlign.center),
      );
    }
    return ListView.separated(
      itemCount: _pendingBookings.length,
      separatorBuilder: (c, i) => const SizedBox(height: 16),
      itemBuilder: (context, index) => _buildPendingBookingCard(_pendingBookings[index]),
    );
  }

  Widget _buildPendingBookingCard(Map<String, dynamic> b) {
    final bid = b['bid'] as String? ?? 'BK-???';
    final serviceType = (b['service_type'] as String? ?? 'Service').replaceAll('_', ' ');
    final scheduledTime = (b['scheduled_time'] as String? ?? '').substring(0, 10.clamp(0, (b['scheduled_time'] as String? ?? '').length));
    final location = (b['location'] as Map?)?.containsKey('address') == true
        ? b['location']['address'] as String? ?? '' : '';

    return GlassCard(
      color: Colors.white.withOpacity(0.06),
      borderColor: Colors.orangeAccent.withOpacity(0.3),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(bid, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
            child: const Text("PENDING", style: TextStyle(fontSize: 10, color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
          ),
        ]),
        const SizedBox(height: 8),
        Text(serviceType, style: const TextStyle(color: AppColors.lavender, fontWeight: FontWeight.bold, fontSize: 14)),
        if (scheduledTime.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text("📅 $scheduledTime", style: const TextStyle(fontSize: 12, color: Colors.white54)),
        ],
        if (location.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text("📍 $location", style: const TextStyle(fontSize: 12, color: Colors.white54)),
        ],
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.withOpacity(0.2),
                foregroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _updateStatus(bid, 'confirmed'),
              child: const Text("✅ Accept"),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.2),
                foregroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _updateStatus(bid, 'cancelled'),
              child: const Text("❌ Decline"),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> req) {
    return GlassCard(
      color: Colors.white.withOpacity(0.06),
      borderColor: Colors.white.withOpacity(0.12),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(req["seeker"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
          Text(req["time"], style: const TextStyle(fontSize: 11, color: Colors.white38)),
        ]),
        const SizedBox(height: 4),
        Row(children: [
          const Icon(Icons.location_on, size: 12, color: Colors.white54),
          const SizedBox(width: 4),
          Text(req["distance"], style: const TextStyle(fontSize: 11, color: Colors.white54)),
        ]),
        const SizedBox(height: 12),
        Text(req["fault"], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.lavender, fontSize: 13)),
        const SizedBox(height: 4),
        Text(req["detail"], style: const TextStyle(fontSize: 12, color: Colors.white70, height: 1.4)),
        const SizedBox(height: 14),
        Divider(color: Colors.white12),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("Estimated Budget", style: TextStyle(fontSize: 10, color: Colors.white38)),
            Text(req["proposedPrice"],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
          ]),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lavender,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Bidded successfully on ${req["id"]}")),
              );
            },
            child: const Text("Bid Now / بولی لگائیں", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ]),
      ]),
    );
  }
}
