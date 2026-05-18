import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ai_seekho_flutter/app/theme.dart';
import 'package:ai_seekho_flutter/shared/widgets/blob_background.dart';
import 'package:ai_seekho_flutter/shared/widgets/glass_card.dart';
import 'package:ai_seekho_flutter/shared/widgets/primary_button.dart';

class BookingDetailScreen extends StatefulWidget {
  final String bookingId;
  final String providerName;
  final String price;

  const BookingDetailScreen({
    super.key,
    required this.bookingId,
    required this.providerName,
    required this.price,
  });

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  final String _providerPhone = "+923001234567";

  Future<void> _makeCall() async {
    final Uri url = Uri.parse("tel:$_providerPhone");
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not launch phone dialer.")),
        );
      }
    } catch (e) {
      // Fallback SnackBar for simulated environments
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Simulated call to Kamran Khan at $_providerPhone")),
      );
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
                      onPressed: () => context.pop(),
                    ),
                    Text(
                      "Booking #${widget.bookingId}",
                      style: AppTextStyles.bodyBold.copyWith(fontSize: 16),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 20),

                // Technician Details Card
                GlassCard(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.primaryGradient,
                        ),
                        child: const Icon(Icons.handyman, color: AppColors.textPrimary, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.providerName,
                              style: AppTextStyles.bodyBold.copyWith(fontSize: 16),
                            ),
                            Text(
                              "AC Specialist • G-13 Islamabad",
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Wires up the Call and Chat actions beautifully
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.6),
                          foregroundColor: AppColors.textPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.white.withOpacity(0.4)),
                          ),
                        ),
                        icon: const Icon(Icons.phone_in_talk, size: 20),
                        label: const Text("Call / کال کریں", style: AppTextStyles.bodyBold),
                        onPressed: _makeCall,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lavender.withOpacity(0.6),
                          foregroundColor: AppColors.textPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: AppColors.lavender.withOpacity(0.4)),
                          ),
                        ),
                        icon: const Icon(Icons.chat_bubble_outline, size: 20),
                        label: const Text("Chat / چیٹ کریں", style: AppTextStyles.bodyBold),
                        onPressed: () {
                          // Routes safely to the new real-time BookingChatScreen
                          context.push(
                            '/booking-chat?id=${widget.bookingId}&name=${Uri.encodeComponent(widget.providerName)}',
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Tracking Timeline Card
                Expanded(
                  child: GlassCard(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "JOB TIMELINE / ٹریکنگ",
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView(
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _buildTimelineRow("Job Dispatched", "AI verified and matching provider assigned.", true, false),
                              _buildTimelineRow("Specialist Traveling", "Kamran is in route (1.2 km remaining).", true, false),
                              _buildTimelineRow("Arrived at Location", "Technician arrived at Sector G-13/2.", false, true),
                              _buildTimelineRow("Repair In-Progress", "Fixing condenser unit.", false, false),
                              _buildTimelineRow("Work Finalization", "Final inspection & testing.", false, false),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                PrimaryButton(
                  label: "Mark Job Complete / کام مکمل ہو گیا",
                  onPressed: () {
                    // Navigate to feedback rating screen
                    context.push('/feedback?bid=${widget.bookingId}');
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineRow(String title, String desc, bool isDone, bool isCurrent) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone
                    ? Colors.green
                    : isCurrent
                        ? AppColors.lavender
                        : AppColors.textSecondary.withOpacity(0.3),
                border: Border.all(
                  color: isCurrent ? AppColors.textPrimary : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: isDone
                  ? const Icon(Icons.check, size: 10, color: Colors.white)
                  : null,
            ),
            Container(
              width: 2,
              height: 38,
              color: isDone ? Colors.green : AppColors.textSecondary.withOpacity(0.3),
            ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyBold.copyWith(
                  fontSize: 13,
                  color: isDone || isCurrent ? AppColors.textPrimary : AppColors.textSecondary.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 11,
                  color: isDone || isCurrent ? AppColors.textSecondary : AppColors.textSecondary.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
