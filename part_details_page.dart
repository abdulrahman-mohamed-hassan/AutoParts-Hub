import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/part_item.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';
import 'shopping_cart_page.dart';

class PartDetailsPage extends StatefulWidget {
  final PartItem part;
  const PartDetailsPage({super.key, required this.part});

  @override
  State<PartDetailsPage> createState() => _PartDetailsPageState();
}

class _PartDetailsPageState extends State<PartDetailsPage>
    with SingleTickerProviderStateMixin {
  int quantity = 1;
  bool _isFavorite = false;
  final FirestoreService _firestoreService = FirestoreService();
  late AnimationController _heartAnimationController;
  late Animation<double> _heartScaleAnimation;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
    _heartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _heartScaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _heartAnimationController, curve: Curves.elasticOut),
    );
  }

  Future<void> _checkIfFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final isFav = await _firestoreService.isFavorite(user.uid, widget.part.id);
      if (mounted) {
        setState(() {
          _isFavorite = isFav;
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to add favorites')),
      );
      return;
    }

    // Play heart animation
    _heartAnimationController.forward().then((_) => _heartAnimationController.reverse());

    setState(() {
      _isFavorite = !_isFavorite;
    });

    if (_isFavorite) {
      await _firestoreService.addToFavorites(user.uid, widget.part);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.part.name} added to favorites')),
      );
    } else {
      await _firestoreService.removeFromFavorites(user.uid, widget.part.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.part.name} removed from favorites')),
      );
    }
  }

  @override
  void dispose() {
    _heartAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.part.name),
        centerTitle: true,
        actions: [
          ScaleTransition(
            scale: _heartScaleAnimation,
            child: IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  key: ValueKey(_isFavorite),
                  color: _isFavorite ? Colors.red : Colors.white,
                  size: 28,
                ),
              ),
              onPressed: _toggleFavorite,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'part_${widget.part.id}',
              child: Container(
                height: 250,
                width: double.infinity,
                color: AppTheme.primaryColor.withValues(alpha: 0.05),
                child: Image.network(
                  widget.part.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_not_supported, size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text(
                            widget.part.name,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.part.name, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                  const SizedBox(height: 10),
                  Text(widget.part.category, style: TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  const Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(widget.part.description, style: TextStyle(color: Colors.grey[700], height: 1.5)),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: widget.part.price),
                        duration: const Duration(milliseconds: 500),
                        builder: (context, double value, child) {
                          return Text(
                            "\$${value.toStringAsFixed(2)}",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.accentColor),
                          );
                        },
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => setState(() { if (quantity > 1) quantity--; }),
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              quantity.toString(),
                              key: ValueKey(quantity),
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () => setState(() => quantity++),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        List<PartItem> cartItems = List.generate(quantity, (_) => widget.part);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShoppingCartPage(cartItems: cartItems),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("ADD TO CART", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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