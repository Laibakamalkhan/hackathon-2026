import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_seekho_flutter/app/theme.dart';
import 'package:ai_seekho_flutter/shared/widgets/blob_background.dart';
import 'package:ai_seekho_flutter/shared/widgets/glass_card.dart';
import 'package:ai_seekho_flutter/shared/widgets/primary_button.dart';

class ProviderRankingScreen extends StatefulWidget {
  final String service;
  final List<dynamic>? matchedProviders;

  const ProviderRankingScreen({super.key, required this.service, this.matchedProviders});

  @override
  State<ProviderRankingScreen> createState() => _ProviderRankingScreenState();
}

class _ProviderRankingScreenState extends State<ProviderRankingScreen> {
  late List<Map<String, dynamic>> _providers;

  @override
  void initState() {
    super.initState();
    if (widget.matchedProviders != null && widget.matchedProviders!.isNotEmpty) {
      _providers = widget.matchedProviders!.map((e) {
        final prov = Map<String, dynamic>.from(e);
        prov["expanded"] = false; // Add expanded state for UI
        return prov;
      }).toList();
    } else {
      _providers = _getProvidersForService(widget.service);
    }
  }

  List<Map<String, dynamic>> _getProvidersForService(String service) {
    final s = service.toLowerCase();
    
    if (s.contains('plumb') || s.contains('pipe') || s.contains('water')) {
      return [
        {
          "pid": "P-10",
          "name": "Nawaz Plumbing Services",
          "specialty": "Master Plumber & Leak Detection",
          "rating": 4.9,
          "jobs": 312,
          "distance": "1.5 km",
          "price": "PKR 800",
          "expanded": false,
          "whyChosen": "Nawaz has the highest success rate in fixing internal leaks without breaking tiles. He is currently 1.5km away and can arrive in 15 minutes.",
          "whyChosenUrdu": "نواز ٹائلز توڑے بغیر اندرونی رساو کو ٹھیک کرنے میں ماہر ہے۔ وہ اس وقت 1.5 کلومیٹر دور ہے اور 15 منٹ میں پہنچ سکتا ہے۔",
        },
        {
          "pid": "P-11",
          "name": "Rizwan Sanitary",
          "specialty": "General Plumber",
          "rating": 4.6,
          "jobs": 140,
          "distance": "3.2 km",
          "price": "PKR 600",
          "expanded": false,
          "whyChosen": "Rizwan offers the most economical rates for standard pipe leaks and blockages.",
          "whyChosenUrdu": "رضوان پائپ لیک اور بلاکیج کے لیے سب سے سستے ریٹ پیش کرتا ہے۔",
        },
      ];
    } else if (s.contains('electric') || s.contains('wire') || s.contains('switch')) {
      return [
        {
          "pid": "P-20",
          "name": "Tariq Electricians",
          "specialty": "Certified Senior Electrician",
          "rating": 4.8,
          "jobs": 420,
          "distance": "2.1 km",
          "price": "PKR 1,000",
          "expanded": false,
          "whyChosen": "Tariq is WAPDA certified and specializes in mainboard tripping issues with a 100% safety record.",
          "whyChosenUrdu": "طارق واپڈا سے تصدیق شدہ ہے اور مین بورڈ ٹرپنگ کے مسائل حل کرنے میں 100% محفوظ ریکارڈ رکھتا ہے۔",
        },
      ];
    } else if (s.contains('clean')) {
      return [
        {
          "pid": "P-30",
          "name": "Shine Masters",
          "specialty": "Deep Cleaning Experts",
          "rating": 4.7,
          "jobs": 89,
          "distance": "4.0 km",
          "price": "PKR 2,500",
          "expanded": false,
          "whyChosen": "Top rated for full house deep cleaning using safe, eco-friendly chemicals.",
          "whyChosenUrdu": "محفوظ اور ماحول دوست کیمیکلز کا استعمال کرتے ہوئے مکمل گھر کی ڈیپ کلیننگ کے لیے بہترین ریٹنگ۔",
        },
      ];
    }
    
    // Default fallback to AC / Generic providers
    return [
      {
        "pid": "P-01",
        "name": "Kamran Khan",
        "specialty": "AC Specialist / Refrigeration",
        "rating": 4.9,
        "jobs": 142,
        "distance": "1.2 km",
        "price": "PKR 1,200",
        "expanded": false,
        "whyChosen": "Kamran is a master technician. In Sector G-13, he holds the fastest response rate (12 minutes) and has completed 34 cooling jobs with a 0% cancellation risk. His base quote is optimal for deep gas leaks.",
        "whyChosenUrdu": "کامران ایک بہترین ٹیکنیشن ہے۔ سیکٹر G-13 میں، اس کا رسپانس ریٹ سب سے تیز (12 منٹ) ہے اور اس نے 0٪ کینسلیشن رسک کے ساتھ 34 کولنگ کے کام مکمل کیے ہیں۔",
      },
      {
        "pid": "P-02",
        "name": "Muhammad Asif",
        "specialty": "AC Repair & General Electric",
        "rating": 4.7,
        "jobs": 98,
        "distance": "2.5 km",
        "price": "PKR 1,000",
        "expanded": false,
        "whyChosen": "Asif offers a highly competitive base rate. He resides near Kashmir Highway, meaning travel times are minimal (18 minutes). He is fully certified for Dawlance/Haier inverter maintenance.",
        "whyChosenUrdu": "آصف انتہائی مناسب ریٹ پیش کرتا ہے۔ وہ کشمیر ہائی وے کے قریب رہتا ہے، جس کا مطلب ہے کہ سفر کا وقت بہت کم (18 منٹ) ہے۔ وہ انورٹر مینٹیننس کے لیے مکمل طور پر تصدیق شدہ ہے۔",
      },
      {
        "pid": "P-03",
        "name": "Sajid Mahmood",
        "specialty": "HVAC Senior Electrician",
        "rating": 4.8,
        "jobs": 210,
        "distance": "3.8 km",
        "price": "PKR 1,500",
        "expanded": false,
        "whyChosen": "Sajid is a veteran HVAC technician with 8 years of experience. He is chosen for high-complexity diagnostics. His higher price is offset by an extensive 60-day repair service warranty.",
        "whyChosenUrdu": "ساجد 8 سالہ تجربہ کار ایچ وی اے سی ٹیکنیشن ہے۔ وہ پیچیدہ کاموں کے لیے بہترین انتخاب ہے۔ اس کے زیادہ ریٹ کے ساتھ 60 دن کی مرمت کی وارنٹی ملتی ہے۔",
      },
    ];
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
                  "AI Matched Specialists",
                  style: AppTextStyles.heading1,
                ),
                const SizedBox(height: 4),
                Text(
                  "اے آئی کے منتخب کردہ ماہرین",
                  style: AppTextStyles.urdu.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 12),
                Text(
                  "Our system selected and ranked these local providers based on credentials, proximity, and past ratings.",
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.separated(
                    itemCount: _providers.length,
                    separatorBuilder: (c, i) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final prov = _providers[index];
                      return _buildProviderCard(prov, index);
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

  Widget _buildProviderCard(Map<String, dynamic> prov, int index) {
    final bool isExpanded = prov["expanded"] ?? false;
    final bool isBestMatch = index == 0;

    // Null-safe fallbacks for backend data
    final String name = prov["name"]?.toString() ?? "Local Specialist";
    final String pid = prov["pid"]?.toString() ?? "P-00";
    final String specialty = prov["specialty"]?.toString() ?? "General Service";
    final String rating = prov["rating"]?.toString() ?? "N/A";
    final String jobs = prov["jobs"]?.toString() ?? "0";
    final String distance = prov["distance"]?.toString() ?? "Unknown";
    final String price = prov["price"]?.toString() ?? "Ask for Price";
    final String whyChosen = prov["whyChosen"]?.toString() ?? "AI found this provider highly suitable for your needs based on our matching algorithm.";
    final String whyChosenUrdu = prov["whyChosenUrdu"]?.toString() ?? "اے آئی نے آپ کی ضرورت کے مطابق اس ماہر کو منتخب کیا ہے۔";

    return GlassCard(
      padding: const EdgeInsets.all(18.0),
      borderColor: isBestMatch ? AppColors.lavender : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isBestMatch) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.lavender.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome, color: AppColors.textPrimary, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      "BEST MATCH — AI RECOMMENDED / بہترین انتخاب",
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 0.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                ),
                child: const Icon(Icons.handyman, color: AppColors.textPrimary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          name,
                          style: AppTextStyles.bodyBold.copyWith(fontSize: 16),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: isBestMatch 
                                ? AppColors.lavender
                                : AppColors.success.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text(
                            isBestMatch ? "Rank #1" : "Rank #${index + 1}",
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      specialty,
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          "$rating ($jobs jobs)",
                          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.location_on, color: AppColors.textSecondary, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          distance,
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ],
                ),
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
                "Estimated Cost:",
                style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                price,
                style: AppTextStyles.bodyBold.copyWith(color: AppColors.textPrimary, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Reasoning Details Button on ALL Matched Provider Cards
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lavender.withOpacity(0.4),
              foregroundColor: AppColors.textPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.lavender.withOpacity(0.6)),
              ),
            ),
            icon: Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.psychology,
              size: 16,
            ),
            label: Text(
              isExpanded ? "Hide Reasoning / تفصیلات چھپائیں" : "🤖 AI ne kyun chuna?",
              style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              setState(() {
                _providers[index]["expanded"] = !isExpanded;
              });
            },
          ),
          
          // Expandable Reasoning details accordion content
          if (isExpanded) ...[
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    whyChosen,
                    style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary, height: 1.4),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    whyChosenUrdu,
                    style: AppTextStyles.urdu.copyWith(fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 12),
          
          // Book Provider Button
          PrimaryButton(
            label: "Proceed to Booking / آگے بڑھیں",
            onPressed: () {
              context.push(
                '/price-breakdown?name=${Uri.encodeComponent(name)}&price=${Uri.encodeComponent(price)}&pid=${Uri.encodeComponent(pid)}&service=${Uri.encodeComponent(widget.service)}',
              );
            },
          ),
        ],
      ),
    );
  }
}
