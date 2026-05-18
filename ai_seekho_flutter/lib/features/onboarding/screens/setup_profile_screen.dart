import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_seekho_flutter/app/theme.dart';
import 'package:ai_seekho_flutter/shared/widgets/blob_background.dart';
import 'package:ai_seekho_flutter/shared/widgets/glass_card.dart';
import 'package:ai_seekho_flutter/shared/widgets/primary_button.dart';

class SetupProfileScreen extends StatefulWidget {
  const SetupProfileScreen({super.key});

  @override
  State<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();

  String? _selectedCity;
  String? _selectedArea;
  bool _isLoading = false;

  final Map<String, List<String>> _cityAreasMap = {
    "Islamabad": [
      "F-6 Sector",
      "F-7 Sector",
      "F-8 Sector",
      "F-10 Sector",
      "F-11 Sector",
      "G-6 Sector",
      "G-7 Sector",
      "G-8 Sector",
      "G-9 Sector",
      "G-10 Sector",
      "G-11 Sector",
      "G-13 Sector",
      "G-14 Sector",
      "E-11 Sector",
      "I-8 Sector",
      "I-9 Sector",
      "I-10 Sector",
      "DHA Phase 1 & 2",
      "Bahria Town Phase 1-8",
      "Bani Gala",
      "Gulberg Greens",
      "B-17 Sector",
      "Sohan",
    ],
    "Rawalpindi": [
      "Saddar",
      "Satellite Town",
      "Commercial Market",
      "Chaklala Scheme III",
      "Chaklala Cantt",
      "Westridge (1, 2, 3)",
      "Peshawar Road",
      "Adyala Road",
      "Gulraiz Housing Scheme",
      "Bahria Town Phase 1-8",
      "DHA Phase 1 & 2",
      "Askari (1-14)",
      "Tench Bhata",
      "Double Road",
      "Shamsabad",
    ],
    "Lahore": [
      "Gulberg I, II, III",
      "DHA Phase 1-8",
      "DHA Phase 9 Prism",
      "Johar Town",
      "Model Town",
      "Lahore Cantt",
      "Bahria Town",
      "Faisal Town",
      "Garden Town",
      "WAPDA Town",
      "Samanabad",
      "Allama Iqbal Town",
      "Valencia Town",
      "Askari (1-11)",
      "Shadman",
      "DHA Rahbar",
      "Cavalry Ground",
    ],
    "Karachi": [
      "Clifton (Blocks 1-9)",
      "DHA Phase 1-8",
      "Gulshan-e-Iqbal (Blocks 1-20)",
      "Gulistan-e-Jauhar (Blocks 1-20)",
      "North Nazimabad (Blocks A-N)",
      "Bahadurabad",
      "KDA Scheme 1",
      "PECHS (Block 2 & 6)",
      "Federal B Area",
      "Nazimabad",
      "Saddar",
      "Malir Cantt",
      "Askari 4 & 5",
      "Garden East & West",
      "Defence View",
      "Tariq Road",
      "Scheme 33",
      "Karsaz",
      "Korangi",
    ],
  };

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submitProfile() {
    if (_nameController.text.isNotEmpty &&
        _selectedCity != null &&
        _selectedArea != null &&
        _addressController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          context.go('/home');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final areas = _selectedCity != null ? _cityAreasMap[_selectedCity]! : <String>[];
    final isFormValid = _nameController.text.isNotEmpty &&
        _selectedCity != null &&
        _selectedArea != null &&
        _addressController.text.isNotEmpty;

    return Scaffold(
      body: BlobBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                const Text(
                  "Setup Profile",
                  style: AppTextStyles.heading1,
                ),
                const SizedBox(height: 4),
                Text(
                  "پروفائل سیٹ اپ کریں",
                  style: AppTextStyles.urdu.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  "Help us understand your location to dispatch nearby service providers accurately.",
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 24),
                GlassCard(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name Input
                      Text(
                        "FULL NAME / مکمل نام",
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nameController,
                        onChanged: (_) => setState(() {}),
                        decoration: _inputDecoration("E.g. Ali Ahmed"),
                        style: AppTextStyles.bodyBold,
                      ),
                      const SizedBox(height: 20),

                      // City Dropdown Selection
                      Text(
                        "SELECT CITY / شہر منتخب کریں",
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDropdownContainer(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCity,
                            dropdownColor: Colors.white,
                            style: AppTextStyles.bodyBold.copyWith(color: AppColors.textPrimary),
                            icon: const Icon(Icons.arrow_drop_down, color: AppColors.textPrimary),
                            hint: const Text(
                              "Select your city",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            isExpanded: true,
                            items: _cityAreasMap.keys.map((String city) {
                              return DropdownMenuItem<String>(
                                value: city,
                                child: Text(
                                  city,
                                  style: AppTextStyles.bodyBold.copyWith(color: AppColors.textPrimary),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newCity) {
                              setState(() {
                                _selectedCity = newCity;
                                _selectedArea = null; // Reset area
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Cascading Area Dropdown Selection
                      Text(
                        "SELECT AREA / علاقہ منتخب کریں",
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDropdownContainer(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedArea,
                            dropdownColor: Colors.white,
                            style: AppTextStyles.bodyBold.copyWith(color: AppColors.textPrimary),
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: _selectedCity == null
                                  ? AppColors.textSecondary.withOpacity(0.5)
                                  : AppColors.textPrimary,
                            ),
                            hint: Text(
                              _selectedCity == null
                                  ? "Please select city first"
                                  : "Select your area",
                              style: TextStyle(
                                color: _selectedCity == null
                                    ? AppColors.textSecondary.withOpacity(0.5)
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            isExpanded: true,
                            disabledHint: Text(
                              "Please select city first",
                              style: TextStyle(color: AppColors.textSecondary.withOpacity(0.5)),
                            ),
                            items: areas.map((String area) {
                              return DropdownMenuItem<String>(
                                value: area,
                                child: Text(
                                  area,
                                  style: AppTextStyles.bodyBold.copyWith(color: AppColors.textPrimary),
                                ),
                              );
                            }).toList(),
                            onChanged: _selectedCity == null
                                ? null
                                : (String? newArea) {
                                    setState(() {
                                      _selectedArea = newArea;
                                    });
                                  },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Full Street Address Input
                      Text(
                        "STREET ADDRESS / گلی کا پتہ",
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _addressController,
                        onChanged: (_) => setState(() {}),
                        maxLines: 2,
                        decoration: _inputDecoration(
                          "E.g. House 45, Street 2, Sector G-13/2",
                        ),
                        style: AppTextStyles.bodyBold.copyWith(color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                PrimaryButton(
                  label: "Save & Continue / محفوظ کریں",
                  isLoading: _isLoading,
                  onPressed: isFormValid ? _submitProfile : null,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.input),
        border: Border.all(
          color: AppColors.textSecondary.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: child,
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodyBold.copyWith(
        color: AppColors.textSecondary.withOpacity(0.6),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
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
        borderSide: const BorderSide(color: AppColors.lavender, width: 2.2),
      ),
    );
  }
}
