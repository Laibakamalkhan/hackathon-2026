import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_seekho_flutter/app/theme.dart';
import 'package:ai_seekho_flutter/shared/widgets/blob_background.dart';
import 'package:ai_seekho_flutter/shared/widgets/glass_card.dart';

class ChatHomeScreen extends StatefulWidget {
  const ChatHomeScreen({super.key});

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  final _searchController = TextEditingController();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _categories = [
    {
      "id": "ac_repair",
      "name": "AC Repair",
      "urdu": "اے سی ریپیئر",
      "icon": Icons.ac_unit,
      "hint": "AC cooling nahi kar raha, gas leak lagti hai",
      "imageUrl": "https://images.unsplash.com/photo-1621905251189-08b45d6a269e?q=80&w=400&auto=format&fit=crop",
    },
    {
      "id": "plumbing",
      "name": "Plumbing",
      "urdu": "پلمبنگ",
      "icon": Icons.water_drop,
      "hint": "Bathroom ka pipe leak ho gaya hai, emergency plumber chahiye",
      "imageUrl": "https://images.unsplash.com/photo-1585704032915-c3400ca199e7?q=80&w=400&auto=format&fit=crop",
    },
    {
      "id": "electrical",
      "name": "Electrical",
      "urdu": "الیکٹریکل",
      "icon": Icons.electric_bolt,
      "hint": "Main switch baar baar trip ho raha hai",
      "imageUrl": "https://images.unsplash.com/photo-1621905252507-b35492cc74b4?q=80&w=400&auto=format&fit=crop",
    },
    {
      "id": "cleaning",
      "name": "Cleaning",
      "urdu": "صفائی ستھرائی",
      "icon": Icons.cleaning_services,
      "hint": "Ghar ki deep cleaning karwani hai full day",
      "imageUrl": "https://images.unsplash.com/photo-1581578731548-c64695cc6952?q=80&w=400&auto=format&fit=crop",
    },
    {
      "id": "appliance",
      "name": "Appliance Fix",
      "urdu": "گھریلو سامان",
      "icon": Icons.kitchen,
      "hint": "Fridge bilkul thanda nahi kar raha",
      "imageUrl": "https://images.unsplash.com/photo-1556911220-e15b29be8c8f?q=80&w=400&auto=format&fit=crop",
    },
    {
      "id": "tutor",
      "name": "Home Tutor",
      "urdu": "ٹیوٹر",
      "icon": Icons.school,
      "hint": "Class 9th math ke liye home tutor chahiye",
      "imageUrl": "https://images.unsplash.com/photo-1434030216411-0b793f4b4173?q=80&w=400&auto=format&fit=crop",
    },
    {
      "id": "beauty",
      "name": "Beauty Salon",
      "urdu": "بیوٹی سیلون",
      "icon": Icons.face,
      "hint": "Shadi event ke liye home makeup service chahiye",
      "imageUrl": "https://images.unsplash.com/photo-1560066984-138dadb4c035?q=80&w=400&auto=format&fit=crop",
    },
    {
      "id": "carpentry",
      "name": "Carpentry",
      "urdu": "کارپینٹری",
      "icon": Icons.chair,
      "hint": "Kitchen cabinet ka door lock change karna hai",
      "imageUrl": "https://images.unsplash.com/photo-1589939705384-5185137a7f0f?q=80&w=400&auto=format&fit=crop",
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _triggerSearch(String query) {
    if (query.trim().isNotEmpty) {
      context.push('/chat-active?query=${Uri.encodeComponent(query)}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _buildBottomNav(),
      body: BlobBackground(
        child: _currentIndex == 0 ? _buildHomeBody() : _buildOtherTabPlaceholder(),
      ),
    );
  }

  Widget _buildHomeBody() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            // Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Assalam-o-Alaikum",
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const Text(
                      "AI Seekho Se Pucho",
                      style: AppTextStyles.heading2,
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => setState(() => _currentIndex = 3),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.lavender, width: 1.5),
                      color: Colors.white,
                    ),
                    child: const Icon(Icons.person, color: AppColors.textPrimary),
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),

            // Search Bar Input
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.psychology, color: AppColors.textPrimary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: _triggerSearch,
                      decoration: const InputDecoration(
                        hintText: "Apna masla roman urdu mein likhein...",
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      style: AppTextStyles.bodyBold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.textPrimary),
                    onPressed: () => _triggerSearch(_searchController.text),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Service Category Grid Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Choose Service Category",
                  style: AppTextStyles.bodyBold.copyWith(fontSize: 16),
                ),
                Text(
                  "سروسز کیٹیگریز",
                  style: AppTextStyles.urdu.copyWith(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Responsive 8-Category Grid Selection
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.only(bottom: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  return _buildCategoryCard(cat);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> cat) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _searchController.text = cat["hint"];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Query set: '${cat["name"]}'. Tap Go Arrow to execute AI match!"),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.textPrimary,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
          image: DecorationImage(
            image: NetworkImage(cat["imageUrl"]),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.1),
                Colors.black.withOpacity(0.8),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(cat["icon"], color: Colors.white, size: 20),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cat["name"],
                    style: AppTextStyles.bodyBold.copyWith(
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    cat["urdu"],
                    style: AppTextStyles.urdu.copyWith(
                      fontSize: 12, 
                      height: 1.4,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtherTabPlaceholder() {
    switch (_currentIndex) {
      case 1:
        // Directory Tab
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Text("Browse Directory", style: AppTextStyles.heading1),
                Text("تمام کیٹیگریز کی تفصیلات", style: AppTextStyles.urdu.copyWith(fontSize: 16)),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    itemCount: _categories.length,
                    separatorBuilder: (c, i) => const SizedBox(height: 12),
                    itemBuilder: (context, idx) {
                      final cat = _categories[idx];
                      return GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(cat["icon"], color: AppColors.textPrimary, size: 30),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(cat["name"], style: AppTextStyles.bodyBold),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Aasan and verified local specialists available in the area.",
                                    style: AppTextStyles.caption,
                                  ),
                                ],
                              ),
                            ),
                            Text(cat["urdu"], style: AppTextStyles.urdu.copyWith(fontSize: 13)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      case 2:
        // History Tab
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.history_edu, size: 64, color: AppColors.textSecondary),
              const SizedBox(height: 16),
              const Text("No Bookings Found", style: AppTextStyles.heading2),
              const SizedBox(height: 4),
              Text("آپ کی کوئی بکنگ ہسٹری نہیں ہے", style: AppTextStyles.urdu),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => setState(() => _currentIndex = 0),
                child: const Text("Go Home"),
              )
            ],
          ),
        );
      case 3:
      default:
        // Profile Settings
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,
                    ),
                    child: const Icon(Icons.person, size: 50, color: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(height: 16),
                const Text("Ali Ahmed", style: AppTextStyles.heading1, textAlign: TextAlign.center),
                Text("G-13 Sector, Islamabad", style: AppTextStyles.caption, textAlign: TextAlign.center),
                const SizedBox(height: 30),
                GlassCard(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.language),
                        title: const Text("Language Selection"),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                        onTap: () => context.push('/language-select'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.location_on),
                        title: const Text("Address Profiles"),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                        onTap: () => context.push('/setup-profile'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.shield),
                        title: const Text("Role Selector Switch"),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                        onTap: () => context.push('/role-selection'),
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

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.textPrimary,
        unselectedItemColor: AppColors.textSecondary.withOpacity(0.5),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
        unselectedLabelStyle: AppTextStyles.caption,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology_alt),
            label: "AI Ask",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: "Browse",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "History",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
