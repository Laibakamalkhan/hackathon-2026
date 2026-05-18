import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_seekho_flutter/app/theme.dart';
import 'package:ai_seekho_flutter/shared/widgets/blob_background.dart';
import 'package:ai_seekho_flutter/shared/widgets/glass_card.dart';

class BrowseDirectoryScreen extends StatelessWidget {
  const BrowseDirectoryScreen({super.key});

  final List<Map<String, dynamic>> _categories = const [
    {
      "title": "AC & Cooling",
      "titleUrdu": "اے سی اور کولنگ",
      "desc": "Air conditioner servicing, deep cooling fixes, gas leakage refilling.",
      "descUrdu": "اے سی سروسنگ، گیس چارجنگ اور کولنگ کے تمام مسائل کا حل۔",
      "icon": Icons.ac_unit,
      "color": Colors.blue,
      "prefill": "AC cooling diagnostic, cooling block or gas leak detection sector G-13",
    },
    {
      "title": "Plumbing",
      "titleUrdu": "پلمبنگ سروسز",
      "desc": "Pipe leakages, bathroom fittings, water pump repair, and sanitary fixtures.",
      "descUrdu": "پائپ لیکج، سینیٹری فٹنگز، موٹر مرمت اور پانی کے مسائل۔",
      "icon": Icons.water_drop,
      "color": Colors.cyan,
      "prefill": "Plumber to fix bathroom pipe leakage and tap replacement",
    },
    {
      "title": "Electrical Work",
      "titleUrdu": "بجلی کا کام",
      "desc": "Short circuit fixes, wiring restoration, fan/ups repair and socket fittings.",
      "descUrdu": "شارٹ سرکٹ مرمت، وائرنگ کی تبدیلی، اور پنکھے/یو پی ایس کی درستگی۔",
      "icon": Icons.bolt,
      "color": Colors.orange,
      "prefill": "Electrician for short circuit wiring fault and socket replacement",
    },
    {
      "title": "Carpentry",
      "titleUrdu": "لکڑی کا کام",
      "desc": "Furniture repair, door lock installation, cabinets, and premium wood fixing.",
      "descUrdu": "فرنیچر کی مرمت، دروازے کے تالے لگانا، اور لکڑی کی ڈیزائننگ۔",
      "icon": Icons.handyman,
      "color": Colors.brown,
      "prefill": "Carpenter to repair broken kitchen cabinet drawer and locks",
    },
    {
      "title": "Home Cleaning",
      "titleUrdu": "گھر کی صفائی",
      "desc": "Sofa cleaning, deep carpet vacuuming, kitchen degreasing, and disinfection.",
      "descUrdu": "صوفے اور قالین کی صفائی، کچن ڈی گریسنگ، اور سینیٹائزیشن۔",
      "icon": Icons.cleaning_services,
      "color": Colors.purple,
      "prefill": "Deep house cleaning and sofa washing specialist required",
    },
    {
      "title": "Appliance Repair",
      "titleUrdu": "گھریلو اشیاء مرمت",
      "desc": "Washing machines, microwave ovens, refrigerators, and water dispensers.",
      "descUrdu": "واشنگ مشین، مائیکرو ویو اوون، اور فریج کی فوری مرمت۔",
      "icon": Icons.kitchen,
      "color": Colors.teal,
      "prefill": "Repair specialist for Dawlance automatic washing machine spin issue",
    },
    {
      "title": "Painting Services",
      "titleUrdu": "رنگ و روغن",
      "desc": "Wall putty, premium interior emulsion, damp wall treatment, exterior weather-sheet.",
      "descUrdu": "دیواروں کی پٹی اور پینٹ، سیم کا علاج، اور بیرونی پینٹ۔",
      "icon": Icons.format_paint,
      "color": Colors.amber,
      "prefill": "Painter for room wall dampness treatment and emulsion paint coating",
    },
    {
      "title": "Tailoring & Stitching",
      "titleUrdu": "درزی اور سلائی",
      "desc": "Shalwar kameez fitting, designer cuts, alteration services, and master stitching.",
      "descUrdu": "شلوار قمیض کی سلائی، فیشن ڈیزائننگ، اور کپڑوں کی فٹنگ۔",
      "icon": Icons.content_cut,
      "color": Colors.pink,
      "prefill": "Tailor for standard Shalwar Kameez stitching and alterations",
    },
  ];

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
                    const Text(
                      "Browse Categories",
                      style: AppTextStyles.heading2,
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  "Browse standard categories and auto-generate matchmaking requests.",
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.separated(
                    itemCount: _categories.length,
                    separatorBuilder: (c, i) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      return GestureDetector(
                        onTap: () {
                          // Routes to active search pipeline with prompt prefill
                          context.push(
                            '/chat-active?query=${Uri.encodeComponent(cat["prefill"])}',
                          );
                        },
                        child: GlassCard(
                          padding: const EdgeInsets.all(18.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: cat["color"].withOpacity(0.2),
                                  border: Border.all(color: cat["color"], width: 1.5),
                                ),
                                child: Icon(cat["icon"], color: cat["color"], size: 24),
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
                                          cat["title"],
                                          style: AppTextStyles.bodyBold.copyWith(fontSize: 15),
                                        ),
                                        Text(
                                          cat["titleUrdu"],
                                          style: AppTextStyles.urdu.copyWith(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      cat["desc"],
                                      style: AppTextStyles.caption.copyWith(fontSize: 11),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      cat["descUrdu"],
                                      style: AppTextStyles.urdu.copyWith(
                                        fontSize: 10,
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
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
