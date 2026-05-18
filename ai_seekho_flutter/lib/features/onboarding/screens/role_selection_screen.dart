import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_seekho_flutter/app/theme.dart';
import 'package:ai_seekho_flutter/shared/widgets/blob_background.dart';
import 'package:ai_seekho_flutter/shared/widgets/glass_card.dart';
import 'package:ai_seekho_flutter/shared/widgets/primary_button.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole; // 'seeker' or 'provider'

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
                  "Choose Your Role",
                  style: AppTextStyles.heading1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  "اپنا کردار منتخب کریں",
                  style: AppTextStyles.urdu.copyWith(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "Are you here to hire professionals or offer your local service expertise?",
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: Column(
                    children: [
                      _buildRoleCard(
                        role: 'seeker',
                        title: "Service Seeker",
                        urduTitle: "سروس تلاش کنندہ",
                        description: "I want to search and book vetted local service technicians.",
                        icon: Icons.person_search,
                      ),
                      const SizedBox(height: 20),
                      _buildRoleCard(
                        role: 'provider',
                        title: "Service Provider",
                        urduTitle: "سروس فراہم کنندہ",
                        description: "I want to register as a local specialist and complete jobs.",
                        icon: Icons.handyman,
                      ),
                    ],
                  ),
                ),
                PrimaryButton(
                  label: "Continue / آگے بڑھیں",
                  onPressed: _selectedRole != null
                      ? () {
                          if (_selectedRole == 'seeker') {
                            context.push('/language-select');
                          } else {
                            // Direct provider users to the Provider Onboarding flow or dashboard
                            context.go('/provider-dashboard');
                          }
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

  Widget _buildRoleCard({
    required String role,
    required String title,
    required String urduTitle,
    required String description,
    required IconData icon,
  }) {
    final bool isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: GlassCard(
        color: isSelected
            ? AppColors.lavender.withOpacity(0.8)
            : Colors.white.withOpacity(0.6),
        borderColor: isSelected
            ? AppColors.lavender
            : Colors.white.withOpacity(0.4),
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? Colors.white.withOpacity(0.7)
                    : AppColors.lavender.withOpacity(0.2),
              ),
              child: Icon(
                icon,
                color: AppColors.textPrimary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.bodyBold.copyWith(fontSize: 16),
                      ),
                      Text(
                        urduTitle,
                        style: AppTextStyles.urdu.copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
