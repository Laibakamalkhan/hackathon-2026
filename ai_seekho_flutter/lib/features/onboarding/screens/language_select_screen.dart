import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_seekho_flutter/app/theme.dart';
import 'package:ai_seekho_flutter/shared/widgets/blob_background.dart';
import 'package:ai_seekho_flutter/shared/widgets/glass_card.dart';
import 'package:ai_seekho_flutter/shared/widgets/primary_button.dart';

class LanguageSelectScreen extends StatefulWidget {
  const LanguageSelectScreen({super.key});

  @override
  State<LanguageSelectScreen> createState() => _LanguageSelectScreenState();
}

class _LanguageSelectScreenState extends State<LanguageSelectScreen> {
  String? _selectedLanguage; // 'en', 'roman_urdu', 'urdu'

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
                const SizedBox(height: 30),
                const Text(
                  "Select Language",
                  style: AppTextStyles.heading1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  "زبان منتخب کریں",
                  style: AppTextStyles.urdu.copyWith(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: Column(
                    children: [
                      _buildLangCard(
                        code: 'roman_urdu',
                        title: "Roman Urdu (Aasan Urdu)",
                        subTitle: "AC kharab ho gaya hai, technician chahiye.",
                        badge: "Aasan",
                      ),
                      const SizedBox(height: 16),
                      _buildLangCard(
                        code: 'urdu',
                        title: "Urdu (اردو)",
                        subTitle: "اے سی خراب ہو گیا ہے، ٹیکنیشن کی ضرورت ہے۔",
                        badge: "Nastaliq",
                      ),
                      const SizedBox(height: 16),
                      _buildLangCard(
                        code: 'en',
                        title: "English",
                        subTitle: "The AC is broken, I need a technician.",
                        badge: "Standard",
                      ),
                    ],
                  ),
                ),
                PrimaryButton(
                  label: "Continue / آگے بڑھیں",
                  onPressed: _selectedLanguage != null
                      ? () {
                          context.push('/phone-auth');
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

  Widget _buildLangCard({
    required String code,
    required String title,
    required String subTitle,
    required String badge,
  }) {
    final bool isSelected = _selectedLanguage == code;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLanguage = code;
        });
      },
      child: GlassCard(
        color: isSelected
            ? AppColors.lavender.withOpacity(0.8)
            : Colors.white.withOpacity(0.6),
        borderColor: isSelected
            ? AppColors.lavender
            : Colors.white.withOpacity(0.4),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.bodyBold.copyWith(fontSize: 15),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.sand.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        child: Text(
                          badge,
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subTitle,
                    style: code == 'urdu'
                        ? AppTextStyles.urdu.copyWith(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          )
                        : AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.textPrimary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
