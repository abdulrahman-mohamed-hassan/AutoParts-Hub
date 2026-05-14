import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/part_item.dart';
import '../../services/local_database_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/animated_list_item.dart';
import '../../widgets/shimmer_loading.dart';
import '../../utils/animations.dart';
import 'part_details_page.dart';

class PartsCatalogPage extends StatefulWidget {
  final String shopId;
  const PartsCatalogPage({super.key, required this.shopId});

  @override
  State<PartsCatalogPage> createState() => _PartsCatalogPageState();
}

class _PartsCatalogPageState extends State<PartsCatalogPage> {
  final List<String> _categories = ["All", "Engine", "Brakes", "Electrical"];
  List<PartItem> _filteredParts = [];
  List<PartItem> _allParts = [];
  bool _isLoading = true;
  String _selectedCategory = "All";

  @override
  void initState() {
    super.initState();
    _fetchParts();
  }

  Future<void> _fetchParts() async {
    setState(() => _isLoading = true);

    List<PartItem> allParts = [];

    try {
      QuerySnapshot partsSnapshot = await FirebaseFirestore.instance.collection('parts').get();
      allParts = partsSnapshot.docs.map((doc) {
        return PartItem(
          id: doc.id,
          shopId: doc['shopId'] ?? '',
          name: doc['name'] ?? '',
          price: (doc['price'] ?? 0.0).toDouble(),
          description: doc['description'] ?? '',
          imageUrl: doc['imageUrl'] ?? '',
          category: doc['category'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('Error getting parts: $e');
    }

    if (allParts.isEmpty) {
      try {
        allParts = await LocalDatabaseService.instance.getParts(widget.shopId);
      } catch (e) {
        print('SQLite error: $e');
      }
    }

    setState(() {
      _allParts = allParts;
      _filteredParts = allParts;
      _isLoading = false;
    });
  }

  void _filterParts(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == "All") {
        _filteredParts = _allParts;
      } else {
        _filteredParts = _allParts.where((p) => p.category == category).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Parts Catalog"),
        centerTitle: true,
      ),
      body: _isLoading
          ? ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) => const ProductCardShimmer(),
            )
          : _filteredParts.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text("No parts found", style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Animated Categories Row
                    Container(
                      height: 50,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final isSelected = _selectedCategory == category;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            child: GestureDetector(
                              onTap: () => _filterParts(category),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppTheme.primaryColor : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.black87,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Animated Parts List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredParts.length,
                        itemBuilder: (context, index) {
                          final part = _filteredParts[index];
                          return AnimatedListItem(
                            index: index,
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    CustomAnimations.slideRight(PartDetailsPage(part: part)),
                                  );
                                },
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(12),
                                  leading: Hero(
                                    tag: 'part_${part.id}',
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        part.imageUrl,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: 60,
                                            height: 60,
                                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                            child: Icon(Icons.image_not_supported, size: 30, color: AppTheme.primaryColor),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    part.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: Text(
                                    part.category,
                                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                  ),
                                  trailing: TweenAnimationBuilder(
                                    tween: Tween<double>(begin: 0, end: part.price),
                                    duration: const Duration(milliseconds: 400),
                                    builder: (context, double value, child) {
                                      return Text(
                                        "\$${value.toStringAsFixed(2)}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: AppTheme.accentColor,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}