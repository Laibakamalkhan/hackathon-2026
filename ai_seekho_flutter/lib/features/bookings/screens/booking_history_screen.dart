import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_seekho_flutter/app/theme.dart';
import 'package:ai_seekho_flutter/shared/widgets/blob_background.dart';
import 'package:ai_seekho_flutter/shared/widgets/glass_card.dart';
import 'package:ai_seekho_flutter/shared/widgets/primary_button.dart';
import 'package:ai_seekho_flutter/core/network/api_service.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, dynamic>> _activeBookings = [];
  List<Map<String, dynamic>> _pastBookings = [];
  bool _isLoading = true;
  String? _errorMessage;

  static const String _demoUserId = 'user_demo_001';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final result = await apiService.getUserBookings(_demoUserId);
      final List bookings = result['bookings'] as List? ?? [];

      final active = <Map<String, dynamic>>[];
      final past = <Map<String, dynamic>>[];

      for (final b in bookings) {
        final bMap = b as Map<String, dynamic>;
        final status = bMap['status'] as String? ?? 'pending';
        if (status == 'completed' || status == 'cancelled' || status == 'disputed') {
          past.add(_normalizeBooking(bMap));
        } else {
          active.add(_normalizeBooking(bMap));
        }
      }

      if (mounted) {
        setState(() {
          _activeBookings = active;
          _pastBookings = past;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Map<String, dynamic> _normalizeBooking(Map<String, dynamic> b) {
    final status = b['status'] as String? ?? 'pending';
    final scheduledTime = b['scheduled_time'] as String? ?? '';
    final quote = b['price_quote'] as Map<String, dynamic>? ?? {};
    final quoteInner = quote['quote'] as Map<String, dynamic>? ?? quote;
    final totalPkr = quoteInner['total_pkr'] ?? 0;
    final serviceType = (b['service_type'] as String? ?? 'Service')
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');

    return {
      'bid': b['bid'] ?? 'BK-???',
      'provider': b['provider_id'] ?? 'Provider',
      'service': serviceType,
      'price': 'PKR $totalPkr',
      'date': scheduledTime.isNotEmpty ? scheduledTime.substring(0, 10) : 'TBD',
      'status': _statusLabel(status),
      'statusColor': _statusColor(status),
      'raw_status': status,
    };
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending': return 'Pending';
      case 'confirmed': return 'Confirmed';
      case 'en_route': return 'En Route';
      case 'in_progress': return 'In Progress';
      case 'completed': return 'Completed';
      case 'cancelled': return 'Cancelled';
      case 'disputed': return 'Disputed';
      default: return status.replaceAll('_', ' ').toUpperCase();
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed': return AppColors.success;
      case 'cancelled': return AppColors.error;
      case 'disputed': return Colors.orange;
      case 'confirmed':
      case 'in_progress':
      case 'en_route': return AppColors.lavender;
      default: return AppColors.textSecondary;
    }
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
                    const Text("My Bookings", style: AppTextStyles.heading2),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
                      onPressed: _loadBookings,
                      tooltip: "Refresh",
                    ),
                  ],
                ),
                const SizedBox(height: 12),

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
                    tabs: [
                      Tab(text: "Active (${_activeBookings.length})"),
                      Tab(text: "Past (${_pastBookings.length})"),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.lavender))
                      : _errorMessage != null
                          ? _buildErrorState()
                          : TabBarView(
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

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          const Text("Could not load bookings", style: AppTextStyles.bodyBold),
          const SizedBox(height: 8),
          Text("Backend unavailable. Showing empty state.",
              style: AppTextStyles.caption, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          PrimaryButton(label: "Retry / دوبارہ", onPressed: _loadBookings),
        ],
      ),
    );
  }

  Widget _buildBookingsList(List<Map<String, dynamic>> list, {required bool isActive}) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isActive ? Icons.calendar_today : Icons.history,
                size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(
              isActive ? "Koi active booking nahi mili." : "Koi past booking nahi mili.",
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (c, i) => const SizedBox(height: 16),
      itemBuilder: (context, index) => _buildBookingCard(list[index], isActive),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> b, bool isActive) {
    final statusColor = b['statusColor'] as Color? ?? AppColors.textSecondary;
    return GestureDetector(
      onTap: () => context.push(
        '/booking-detail?id=${b["bid"]}&provider=${Uri.encodeComponent(b["provider"])}&price=${Uri.encodeComponent(b["price"])}',
      ),
      child: GlassCard(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(b['bid'], style: AppTextStyles.bodyBold.copyWith(color: AppColors.textSecondary, fontSize: 12)),
                Container(
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withOpacity(0.4)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: Text(b['status'],
                      style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, fontSize: 10)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(b['service'], style: AppTextStyles.bodyBold.copyWith(fontSize: 16)),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.person, color: AppColors.textSecondary, size: 14),
              const SizedBox(width: 6),
              Text(b['provider'], style: AppTextStyles.caption),
            ]),
            const SizedBox(height: 12),
            Divider(color: Colors.white.withOpacity(0.3)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(b['date'], style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
                Text(b['price'], style: AppTextStyles.bodyBold.copyWith(color: AppColors.textPrimary)),
              ],
            ),
            if (!isActive) ...[
              const SizedBox(height: 14),
              PrimaryButton(
                label: "Leave Feedback / فیڈ بیک",
                onPressed: () => context.push('/feedback?bid=${b["bid"]}'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
