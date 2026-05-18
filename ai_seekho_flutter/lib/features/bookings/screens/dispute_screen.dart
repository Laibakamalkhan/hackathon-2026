import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_seekho_flutter/app/theme.dart';
import 'package:ai_seekho_flutter/shared/widgets/blob_background.dart';
import 'package:ai_seekho_flutter/shared/widgets/glass_card.dart';
import 'package:ai_seekho_flutter/shared/widgets/primary_button.dart';

class DisputeScreen extends StatefulWidget {
  final String bookingId;
  final String? initialReason;

  const DisputeScreen({
    super.key,
    required this.bookingId,
    this.initialReason,
  });

  @override
  State<DisputeScreen> createState() => _DisputeScreenState();
}

class _DisputeScreenState extends State<DisputeScreen> {
  String _selectedCategory = "Overcharging";
  final TextEditingController _detailsController = TextEditingController();
  bool _photoUploaded = false;

  final List<String> _categories = [
    "Overcharging / زیادہ پیسے",
    "Incomplete Work / نامکمل کام",
    "Property Damage / نقصان",
    "Unprofessional Behavior / غلط رویہ"
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialReason != null) {
      _detailsController.text = widget.initialReason!;
    }
  }

  void _simulatePhotoUpload() {
    setState(() {
      _photoUploaded = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("📸 Evidence image mock attached successfully.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlobBackground(
        child: SafeArea(
          child: SingleChildScrollView(
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
                  "AI Dispute Center",
                  style: AppTextStyles.heading1,
                ),
                const SizedBox(height: 4),
                Text(
                  "اے آئی تنازعات کا مرکز",
                  style: AppTextStyles.urdu.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 20),

                // Category selector card
                const Text(
                  "Dispute Type / شکایت کی قسم",
                  style: AppTextStyles.bodyBold,
                ),
                const SizedBox(height: 8),
                GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                      items: _categories.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value.split(' / ')[0],
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Text Description box
                const Text(
                  "Write Details / تفصیلات لکھیں",
                  style: AppTextStyles.bodyBold,
                ),
                const SizedBox(height: 8),
                GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: TextField(
                    controller: _detailsController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: "Explain what went wrong in detail so our AI model can evaluate...",
                      border: InputBorder.none,
                    ),
                    style: AppTextStyles.body,
                  ),
                ),
                const SizedBox(height: 20),

                // Photo Evidence Picker mock box
                const Text(
                  "Evidence Photos / ثبوت",
                  style: AppTextStyles.bodyBold,
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _simulatePhotoUpload,
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    color: _photoUploaded
                        ? AppColors.success.withOpacity(0.2)
                        : Colors.white.withOpacity(0.4),
                    borderColor: _photoUploaded
                        ? AppColors.success
                        : Colors.white.withOpacity(0.2),
                    child: Column(
                      children: [
                        Icon(
                          _photoUploaded ? Icons.task_alt : Icons.add_a_photo,
                          size: 32,
                          color: _photoUploaded ? Colors.green : AppColors.textPrimary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _photoUploaded ? "Evidence Image Attached" : "Tap to Upload Damage / Receipt Image",
                          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                PrimaryButton(
                  label: "Submit to AI Mediation / شکایت درج کریں",
                  onPressed: () {
                    if (_detailsController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please write dispute description first.")),
                      );
                      return;
                    }
                    context.push(
                      '/dispute-resolution?id=${widget.bookingId}&category=${Uri.encodeComponent(_selectedCategory)}&details=${Uri.encodeComponent(_detailsController.text)}',
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
