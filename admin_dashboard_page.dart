import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';
import '../../models/part_item.dart';
import '../../utils/app_theme.dart';
import '../user/login_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final _shopNameController = TextEditingController();
  final _shopImageUrlController = TextEditingController();
  final _partNameController = TextEditingController();
  final _partPriceController = TextEditingController();
  final _partDescriptionController = TextEditingController();
  final _partImageUrlController = TextEditingController();
  final _partCategoryController = TextEditingController();
  String? _selectedShopId;
  List<Map<String, dynamic>> _shops = [];

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _fetchShops();
  }

  Future<void> _fetchShops() async {
    final shops = await _firestoreService.getShops();
    if (mounted) {
      setState(() {
        _shops = shops.map((s) => {
          'id': s.id,
          'name': s.name,
          'imageUrl': s.imageUrl,
        }).toList();
      });
    }
  }

  Future<void> _addShop() async {
    final name = _shopNameController.text.trim();
    final imageUrl = _shopImageUrlController.text.trim();

    if (name.isEmpty || imageUrl.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields')),
        );
      }
      return;
    }

    await _firestoreService.addShop(name, imageUrl);

    _shopNameController.clear();
    _shopImageUrlController.clear();
    _fetchShops();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shop added successfully!')),
      );
    }
  }

  Future<void> _addPart() async {
    final shopId = _selectedShopId;
    final name = _partNameController.text.trim();
    final price = double.tryParse(_partPriceController.text) ?? 0;
    final description = _partDescriptionController.text.trim();
    final imageUrl = _partImageUrlController.text.trim();
    final category = _partCategoryController.text.trim();

    if (shopId == null || name.isEmpty || description.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields')),
        );
      }
      return;
    }

    final partItem = PartItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      shopId: shopId,
      name: name,
      price: price,
      description: description,
      imageUrl: imageUrl,
      category: category,
    );

    await _firestoreService.addPart(partItem);

    _partNameController.clear();
    _partPriceController.clear();
    _partDescriptionController.clear();
    _partCategoryController.clear();
    _partImageUrlController.clear();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Part added successfully!')),
      );
    }
  }

  Future<void> _logout() async {
    // Show confirmation dialog
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();
      
      if (mounted) {
        // Navigate to login page and clear history
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        actions: [
          // Logout button in AppBar
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader("Add New Part Shop"),
            _buildTextField(_shopNameController, 'Shop Name', Icons.store),
            _buildTextField(_shopImageUrlController, 'Shop Image URL', Icons.image),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addShop,
                child: const Text('Add Shop'),
              ),
            ),
            const Divider(height: 40),
            _buildHeader("Add New Car Part"),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Select Shop'),
              value: _selectedShopId,
              items: _shops.map((s) => DropdownMenuItem(
                value: s['id'] as String,
                child: Text(s['name'] as String),
              )).toList(),
              onChanged: (v) {
                if (mounted) {
                  setState(() {
                    _selectedShopId = v;
                  });
                }
              },
            ),
            const SizedBox(height: 10),
            _buildTextField(_partNameController, 'Part Name', Icons.build),
            _buildTextField(_partPriceController, 'Price', Icons.attach_money),
            _buildTextField(_partDescriptionController, 'Description', Icons.description),
            _buildTextField(_partCategoryController, 'Category', Icons.category),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addPart,
                child: const Text('Add Part'),
              ),
            ),
            const Divider(height: 40),
            _buildHeader("Existing Shops"),
            ..._shops.map((s) => ListTile(
              leading: Icon(Icons.store, color: AppTheme.primaryColor),
              title: Text(s['name'] as String),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _shopImageUrlController.dispose();
    _partNameController.dispose();
    _partPriceController.dispose();
    _partDescriptionController.dispose();
    _partImageUrlController.dispose();
    _partCategoryController.dispose();
    super.dispose();
  }
}