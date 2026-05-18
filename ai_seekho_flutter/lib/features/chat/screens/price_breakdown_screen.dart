import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_seekho_flutter/app/theme.dart';
import 'package:ai_seekho_flutter/shared/widgets/blob_background.dart';
import 'package:ai_seekho_flutter/shared/widgets/glass_card.dart';
import 'package:ai_seekho_flutter/shared/widgets/primary_button.dart';

import 'package:ai_seekho_flutter/core/network/api_service.dart';
import 'package:ai_seekho_flutter/core/network/models.dart';

class PriceBreakdownScreen extends StatefulWidget {
  final String providerName;
  final String basePrice;
  final String providerId;
  final String serviceType;

  const PriceBreakdownScreen({
    super.key,
    required this.providerName,
    required this.basePrice,
    required this.providerId,
    required this.serviceType,
  });

  @override
  State<PriceBreakdownScreen> createState() => _PriceBreakdownScreenState();
}

class _PriceBreakdownScreenState extends State<PriceBreakdownScreen> {
  int _baseRate = 1000;
  final int _visitFee = 200;
  final int _travelFee = 150;
  int _urgencyPremium = 150;
  int _discount = 0;
  String? _selectedAlternative; // 'later_today', 'tomorrow', null
  bool _isBooking = false;
  void initState() {
    super.initState();
    // Parse base price if possible
    final parsed = int.tryParse(widget.basePrice.replaceAll(RegExp(r'[^0-9]'), ''));
    if (parsed != null) {
      _baseRate = parsed;
    }
  }

  int get _total => _baseRate + _visitFee + _travelFee + _urgencyPremium - _discount;

  void _applyAlternative(String type) {
    setState(() {
      if (_selectedAlternative == type) {
        // Toggle off
        _selectedAlternative = null;
        _discount = 0;
        _urgencyPremium = 150; // Restore urgency premium
      } else {
        _selectedAlternative = type;
        if (type == 'later_today') {
          _discount = 150;
          _urgencyPremium = 0; // Off-peak has no urgency premium
        } else if (type == 'tomorrow') {
          _discount = 250;
          _urgencyPremium = 0; // Next-day has zero urgency premium
        }
      }
    });
  }

  Future<void> _submitBooking() async {
    setState(() {
      _isBooking = true;
    });

    try {
      final req = BookingCreateRequest(
        userId: "U-789", // Mock logged-in user
        providerId: widget.providerId,
        serviceType: widget.serviceType,
        scheduledTime: _selectedAlternative == 'tomorrow' ? 'Tomorrow Morning' : 'Today',
        locationAddress: "G-13, Islamabad",
        lat: 33.649,
        lng: 72.973,
        priceQuote: {
          "base_fee": _baseRate,
          "visit_fee": _visitFee,
          "travel_fee": _travelFee,
          "urgency_premium": _urgencyPremium,
          "discount": _discount,
          "total": _total
        },
        intentRaw: "N/A",
        intentParsed: {},
      );

      final response = await apiService.createBooking(req);
      
      if (mounted) {
        context.push(
          '/booking-confirmed?provider=${Uri.encodeComponent(widget.providerName)}&total=PKR $_total',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Booking Failed: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBooking = false;
        });
      }
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
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                    onPressed: () => context.pop(),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Transparent Price Audit",
                  style: AppTextStyles.heading1,
                ),
                const SizedBox(height: 4),
                Text(
                  "قیمت کی مکمل تفصیلات",
                  style: AppTextStyles.urdu.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 20),

                // Main Receipt Glass Card
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "SERVICE RECEIPT / رسید",
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      _buildReceiptRow("Base Diagnostic Fee", "PKR $_baseRate"),
                      const SizedBox(height: 10),
                      _buildReceiptRow("Standard Visit Fee", "PKR $_visitFee"),
                      const SizedBox(height: 10),
                      _buildReceiptRow("Travel/Fuel Allowance", "PKR $_travelFee"),
                      const SizedBox(height: 10),
                      _buildReceiptRow("Urgency / Ujlat Premium", "PKR $_urgencyPremium"),
                      if (_discount > 0) ...[
                        const SizedBox(height: 10),
                        _buildReceiptRow("Flex-Schedule Discount", "-PKR $_discount", isDiscount: true),
                      ],
                      const SizedBox(height: 16),
                      Divider(color: Colors.white.withOpacity(0.4), thickness: 1.5),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Payable / کل قیمت",
                            style: AppTextStyles.bodyBold.copyWith(fontSize: 16),
                          ),
                          Text(
                            "PKR $_total",
                            style: AppTextStyles.heading2.copyWith(color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Interactive Cheaper Alternatives Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "💡 AI Price-Saver Options",
                      style: AppTextStyles.bodyBold.copyWith(fontSize: 15),
                    ),
                    Text(
                      "بچت آفرز",
                      style: AppTextStyles.urdu.copyWith(fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Interactive Alternative list
                _buildAlternativeOption(
                  type: 'later_today',
                  title: "Schedule 2 Hours Later (Off-Peak)",
                  description: "Remove Urgency premium + Save PKR 150",
                  saving: "Save PKR 300 total",
                ),
                const SizedBox(height: 12),
                _buildAlternativeOption(
                  type: 'tomorrow',
                  title: "Schedule Tomorrow Morning",
                  description: "Next-day dispatcher discount applied",
                  saving: "Save PKR 400 total",
                ),

                const Spacer(),
                PrimaryButton(
                  label: _isBooking ? "Confirming..." : "Confirm & Book / بکنگ کنفرم کریں",
                  onPressed: _isBooking ? () {} : _submitBooking,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String title, String val, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
        Text(
          val,
          style: AppTextStyles.bodyBold.copyWith(
            fontSize: 13,
            color: isDiscount ? Colors.green[700] : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildAlternativeOption({
    required String type,
    required String title,
    required String description,
    required String saving,
  }) {
    final bool isSelected = _selectedAlternative == type;

    return GestureDetector(
      onTap: () => _applyAlternative(type),
      child: GlassCard(
        color: isSelected
            ? AppColors.success.withOpacity(0.5)
            : Colors.white.withOpacity(0.5),
        borderColor: isSelected
            ? AppColors.success
            : Colors.white.withOpacity(0.3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.schedule_send,
              color: isSelected ? Colors.green[800] : AppColors.textPrimary,
              size: 24,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyBold.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: AppTextStyles.caption.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.green[800]!.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                saving,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  color: Colors.green[800],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
