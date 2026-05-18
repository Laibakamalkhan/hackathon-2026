import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_seekho_flutter/app/theme.dart';
import 'package:ai_seekho_flutter/shared/widgets/blob_background.dart';
import 'package:ai_seekho_flutter/shared/widgets/glass_card.dart';
import 'package:ai_seekho_flutter/shared/widgets/primary_button.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  bool _isValid = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _validatePhone(String val) {
    // Basic validation for Pakistani mobile formats e.g. 3001234567 (10 digits)
    setState(() {
      _isValid = val.length == 10 && RegExp(r'^[3][0-9]{9}$').hasMatch(val);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlobBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
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
                  "Enter Phone Number",
                  style: AppTextStyles.heading1,
                ),
                const SizedBox(height: 4),
                Text(
                  "اپنا فون نمبر درج کریں",
                  style: AppTextStyles.urdu.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  "We will send you a 6-digit OTP code to verify your account.",
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 36),
                GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "MOBILE NUMBER / فون نمبر",
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.lavender.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(AppRadius.input),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
                            child: Text(
                              "+92",
                              style: AppTextStyles.bodyBold.copyWith(fontSize: 16),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              onChanged: _validatePhone,
                              decoration: InputDecoration(
                                hintText: "3001234567",
                                hintStyle: AppTextStyles.bodyBold.copyWith(
                                  color: AppColors.textSecondary.withOpacity(0.6),
                                ),
                                counterText: "",
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 15,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.input),
                                  borderSide: BorderSide(
                                    color: AppColors.textSecondary.withOpacity(0.4),
                                    width: 1.5,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.input),
                                  borderSide: BorderSide(
                                    color: AppColors.textSecondary.withOpacity(0.4),
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.input),
                                  borderSide: const BorderSide(
                                    color: AppColors.lavender,
                                    width: 2.2,
                                  ),
                                ),
                              ),
                              style: AppTextStyles.bodyBold.copyWith(
                                fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                PrimaryButton(
                  label: "Send OTP / او ٹی پی بھیجیں",
                  onPressed: _isValid
                      ? () {
                          context.push('/otp-verify?phone=+92${_phoneController.text}');
                        }
                      : null,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
