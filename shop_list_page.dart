import 'package:flutter/material.dart';
import '../../models/shop.dart';
import '../../services/firestore_service.dart';
import '../../services/local_database_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/animations.dart';
import '../../widgets/shimmer_loading.dart';
import 'parts_catalog_page.dart';
import 'contact_support_page.dart';
import 'location_support_page.dart';
import 'mechanic_request_page.dart';
import 'about_us_page.dart';
import 'settings_page.dart';
import 'favorite_items_page.dart';
import 'login_page.dart';

class ShopListPage extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  ShopListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AutoParts Hub"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: () => Navigator.push(
              context,
              CustomAnimations.slideRight(LocationSupportPage()), // ← REMOVED const
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          _buildHeroHeader(context),
          _buildMechanicBanner(context),
          _buildCategories(),
          Expanded(child: _buildShopList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          CustomAnimations.scaleTransition(ContactSupportPage()), // ← REMOVED const
        ),
        label: const Text("Support"),
        icon: const Icon(Icons.support_agent),
        backgroundColor: AppTheme.accentColor,
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: AppTheme.primaryColor),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.directions_car, color: Colors.white, size: 40),
                SizedBox(height: 10),
                Text('AutoParts Hub', style: TextStyle(color: Colors.white, fontSize: 20)),
                Text('Premium Auto Parts', style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Favorites'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                CustomAnimations.slideRight(const FavoriteItemsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                CustomAnimations.slideRight(const SettingsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About Us'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                CustomAnimations.slideRight(const AboutUsPage()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () => _confirmLogout(context),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                CustomAnimations.fadeTransition(const LoginPage()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=1000&q=80'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryColor.withValues(alpha: 0.8), Colors.transparent],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text("Premium Auto Parts", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text("Quality parts for your performance needs", style: TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildMechanicBanner(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          CustomAnimations.scaleTransition(MechanicRequestPage()), // ← REMOVED const
        ),
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppTheme.accentColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Row(
            children: [
              Icon(Icons.handyman, color: Colors.white, size: 30),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Need a Mechanic?", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("Book a professional to your location now", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    final categories = [
      {"title": "Engine", "icon": Icons.settings_suggest, "color": Colors.orange},
      {"title": "Brakes", "icon": Icons.adjust, "color": Colors.red},
      {"title": "Suspension", "icon": Icons.handyman, "color": Colors.blue},
      {"title": "Electrical", "icon": Icons.electrical_services, "color": Colors.amber},
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (cat['color'] as Color).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(cat['icon'] as IconData, color: cat['color'] as Color, size: 28),
                ),
                const SizedBox(height: 5),
                Text(cat['title'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildShopList() {
    return FutureBuilder(
      future: _getShopsWithFallback(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.builder(
            itemCount: 3,
            itemBuilder: (context, index) => const ShopCardShimmer(),
          );
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No shops found"));
        }

        final shops = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: shops.length,
          itemBuilder: (context, index) {
            final shop = shops[index];
            return AnimatedContainer(
              duration: Duration(milliseconds: 300 + (index * 50)),
              curve: Curves.easeOut,
              child: Card(
                margin: const EdgeInsets.only(bottom: 20),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    CustomAnimations.slideRight(PartsCatalogPage(shopId: shop.id)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag: 'shop_${shop.id}',
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                          child: Image.network(
                            shop.imageUrl,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 160,
                                width: double.infinity,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image_not_supported, size: 50),
                              );
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shop.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Professional Parts & Service",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<List<Shop>> _getShopsWithFallback() async {
    try {
      final firestoreShops = await _firestoreService.getShops();
      if (firestoreShops.isNotEmpty) {
        return firestoreShops;
      }
    } catch (e) {
      print('Firestore error: $e');
    }

    try {
      final sqliteShops = await LocalDatabaseService.instance.getShops();
      if (sqliteShops.isNotEmpty) {
        return sqliteShops;
      }
    } catch (e) {
      print('SQLite error: $e');
    }

    return [];
  }
}