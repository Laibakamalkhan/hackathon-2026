import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_seekho_flutter/app/theme.dart';
import 'package:ai_seekho_flutter/shared/widgets/blob_background.dart';
import 'package:ai_seekho_flutter/shared/widgets/glass_card.dart';
import 'package:ai_seekho_flutter/shared/widgets/primary_button.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _activeBookings = [
    {
      "bid": "BK-88F9A",
      "provider": "Kamran Khan",
      "service": "AC Cooling Diagnostic",
      "price": "PKR 1,350",
      "date": "Today, 02:30 PM",
      "status": "In Progress",
      "statusColor": AppColors.lavender,
    }
  ];

  final List<Map<String, dynamic>> _pastBookings = [
    {
      "bid": "BK-22E4D",
      "provider": "Muhammad Asif",
      "service": "Gas Refilling",
      "price": "PKR 3,500",
      "date": "14 May 2026",
      "status": "Completed",
      "statusColor": AppColors.success,
    },
    {
      "bid": "BK-11A8B",
      "provider": "Sajid Mahmood",
      "service": "Electrical Socket Fix",
      "price": "PKR 800",
      "date": "10 May 2026",
      "status": "Completed",
      "statusColor": AppColors.success,
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlobBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                      onPressed: () => context.go('/home'),
                    ),
                    const Text(
                      "My Bookings",
                      style: AppTextStyles.heading2,
                    ),
                    const SizedBox(width: 48), // spacer balance
                  ],
                ),
                const SizedBox(height: 12),
                
                // Tabs Indicator
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(AppRadius.chip),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  padding: const EdgeInsets.all(4.0),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: AppColors.textPrimary,
                    labelColor: AppColors.textPrimary,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.chip),
                    ),
                    labelStyle: AppTextStyles.bodyBold.copyWith(fontSize: 13),
                    unselectedLabelStyle: AppTextStyles.body.copyWith(fontSize: 13),
                    tabs: const [
                      Tab(text: "Active Bookings"),
                      Tab(text: "Archived / Past"),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildBookingsList(_activeBookings, isActive: true),
                      _buildBookingsList(_pastBookings, isActive: false),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingsList(List<Map<String, dynamic>> list, {required bool isActive}) {
    if (list.isEmpty) {
      return const Center(
        child: Text(
          "No bookings found in this category.",
          style: AppTextStyles.caption,
        ),
      );
    }

    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (c, i) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final b = list[index];
        return _buildBookingCard(b, isActive);
      },
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> b, bool isActive) {
    return GestureDetector(
      onTap: () {
        context.push(
          '/booking-detail?id=${b["bid"]}&provider=${Uri.encodeComponent(b["provider"])}&price=${Uri.encodeComponent(b["price"])}',
        );
      },
      child: GlassCard(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  b["bid"],
                  style: AppTextStyles.bodyBold.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: b["statusColor"].withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: b["statusColor"].withOpacity(0.4)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: Text(
                    b["status"],
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              b["service"],
              style: AppTextStyles.bodyBold.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.person, color: AppColors.textSecondary, size: 14),
                const SizedBox(width: 6),
                Text(
                  b["provider"],
                  style: AppTextStyles.caption,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: Colors.white.withOpacity(0.3)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  b["date"],
                  style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  b["price"],
                  style: AppTextStyles.bodyBold.copyWith(color: AppColors.textPrimary),
                ),
              ],
            ),
            if (!isActive) ...[
              const SizedBox(height: 14),
              PrimaryButton(
                label: "Leave Feedback / فیڈ بیک",
                onPressed: () {
                  context.push('/feedback?bid=${b["bid"]}');
                },
              ),
            ]
          ],
        ),
      ),
    );
  }
}
