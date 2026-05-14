import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shop.dart';
import '../models/part_item.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== SHOPS ====================
  
  Future<List<Shop>> getShops() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('shops').get();
      return snapshot.docs.map((doc) {
        return Shop(
          id: doc.id,
          name: doc['name'] ?? '',
          imageUrl: doc['imageUrl'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('Error getting shops: $e');
      return [];
    }
  }

  Future<void> addShop(String name, String imageUrl) async {
    try {
      await _firestore.collection('shops').add({
        'name': name,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding shop: $e');
    }
  }

  // ==================== PARTS ====================
  
  Future<List<PartItem>> getParts(String shopId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('parts')
          .where('shopId', isEqualTo: shopId)
          .get();
      return snapshot.docs.map((doc) {
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
      return [];
    }
  }

  Future<void> addPart(PartItem part) async {
    try {
      await _firestore.collection('parts').add(part.toJson());
    } catch (e) {
      print('Error adding part: $e');
    }
  }

  // ==================== CART ====================
  
  Future<void> addToCart(String userId, PartItem part, int quantity) async {
    try {
      QuerySnapshot existing = await _firestore
          .collection('carts')
          .where('userId', isEqualTo: userId)
          .where('partId', isEqualTo: part.id)
          .get();
      
      if (existing.docs.isNotEmpty) {
        String docId = existing.docs.first.id;
        int currentQty = existing.docs.first['quantity'] ?? 1;
        await _firestore.collection('carts').doc(docId).update({
          'quantity': currentQty + quantity,
        });
      } else {
        await _firestore.collection('carts').add({
          'userId': userId,
          'partId': part.id,
          'partName': part.name,
          'price': part.price,
          'imageUrl': part.imageUrl,
          'quantity': quantity,
          'addedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error adding to cart: $e');
    }
  }

  Stream<List<CartItem>> getCartItems(String userId) {
    return _firestore
        .collection('carts')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CartItem(
          id: doc.id,
          partId: doc['partId'] ?? '',
          name: doc['partName'] ?? '',
          price: (doc['price'] ?? 0.0).toDouble(),
          imageUrl: doc['imageUrl'] ?? '',
          quantity: doc['quantity'] ?? 1,
        );
      }).toList();
    });
  }

  Future<void> removeFromCart(String cartItemId) async {
    try {
      await _firestore.collection('carts').doc(cartItemId).delete();
    } catch (e) {
      print('Error removing from cart: $e');
    }
  }

  Future<void> updateCartQuantity(String cartItemId, int quantity) async {
    try {
      if (quantity <= 0) {
        await removeFromCart(cartItemId);
      } else {
        await _firestore.collection('carts').doc(cartItemId).update({
          'quantity': quantity,
        });
      }
    } catch (e) {
      print('Error updating quantity: $e');
    }
  }

  Future<void> clearCart(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('carts')
          .where('userId', isEqualTo: userId)
          .get();
      
      for (var doc in snapshot.docs) {
        await _firestore.collection('carts').doc(doc.id).delete();
      }
    } catch (e) {
      print('Error clearing cart: $e');
    }
  }

  // ==================== FAVORITES ====================
  
  Future<void> addToFavorites(String userId, PartItem part) async {
    try {
      QuerySnapshot existing = await _firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .where('partId', isEqualTo: part.id)
          .get();
      
      if (existing.docs.isEmpty) {
        await _firestore.collection('favorites').add({
          'userId': userId,
          'partId': part.id,
          'partName': part.name,
          'price': part.price,
          'imageUrl': part.imageUrl,
          'category': part.category,
          'addedAt': FieldValue.serverTimestamp(),
        });
        print('Added to favorites: ${part.name}');
      }
    } catch (e) {
      print('Error adding to favorites: $e');
    }
  }

  Future<void> removeFromFavorites(String userId, String partId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .where('partId', isEqualTo: partId)
          .get();
      
      for (var doc in snapshot.docs) {
        await _firestore.collection('favorites').doc(doc.id).delete();
      }
      print('Removed from favorites');
    } catch (e) {
      print('Error removing from favorites: $e');
    }
  }

  Future<bool> isFavorite(String userId, String partId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .where('partId', isEqualTo: partId)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking favorite: $e');
      return false;
    }
  }

  Stream<List<PartItem>> getFavoritesStream(String userId) {
    return _firestore
        .collection('favorites')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return PartItem(
          id: doc['partId'] ?? '',
          shopId: '',
          name: doc['partName'] ?? '',
          price: (doc['price'] ?? 0.0).toDouble(),
          description: '',
          imageUrl: doc['imageUrl'] ?? '',
          category: doc['category'] ?? '',
        );
      }).toList();
    });
  }

  // ==================== ORDERS ====================
  
  Future<void> placeOrder(String userId, List<CartItem> items, double total, String paymentMethod, String address) async {
    try {
      await _firestore.collection('orders').add({
        'userId': userId,
        'items': items.map((item) => {
          'partId': item.partId,
          'name': item.name,
          'price': item.price,
          'quantity': item.quantity,
        }).toList(),
        'totalAmount': total,
        'paymentMethod': paymentMethod,
        'address': address,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      await clearCart(userId);
    } catch (e) {
      print('Error placing order: $e');
    }
  }

  // ==================== INITIAL DATA ====================
  
  Future<void> initializeSampleData() async {
    QuerySnapshot shopCheck = await _firestore.collection('shops').limit(1).get();
    if (shopCheck.docs.isNotEmpty) return;

    List<Shop> shops = [
      Shop(id: 's1', name: 'Elite Engine Parts', imageUrl: 'https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=500&q=80'),
      Shop(id: 's2', name: 'Brake & Suspension Pro', imageUrl: 'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?w=500&q=80'),
      Shop(id: 's3', name: 'Professional Mechanic Hub', imageUrl: 'https://images.unsplash.com/photo-1487754180451-c456f719a1fc?w=500&q=80'),
    ];

    for (var shop in shops) {
      await _firestore.collection('shops').add({
        'name': shop.name,
        'imageUrl': shop.imageUrl,
      });
    }

    List<PartItem> parts = [
      PartItem(id: 'p1', shopId: 's1', name: 'Brembo Brake Pads', price: 120.0, description: 'High-performance ceramic brake pads', imageUrl: 'https://images.unsplash.com/photo-1517524008697-84bbe3c3fd98?w=500&q=80', category: 'Brakes'),
      PartItem(id: 'p2', shopId: 's1', name: 'Castrol Edge 5W-30', price: 45.0, description: 'Fully synthetic engine oil', imageUrl: 'https://images.unsplash.com/photo-1620939511593-3ef7682976be?w=500&q=80', category: 'Engine'),
      PartItem(id: 'p3', shopId: 's2', name: 'Bosch Spark Plugs', price: 15.0, description: 'Double Iridium spark plugs', imageUrl: 'https://images.unsplash.com/photo-1589148625905-045330835f11?w=500&q=80', category: 'Electrical'),
    ];

    for (var part in parts) {
      await _firestore.collection('parts').add({
        'shopId': part.shopId,
        'name': part.name,
        'price': part.price,
        'description': part.description,
        'imageUrl': part.imageUrl,
        'category': part.category,
      });
    }
  }
}

// Cart Item Model
class CartItem {
  final String id;
  final String partId;
  final String name;
  final double price;
  final String imageUrl;
  final int quantity;

  CartItem({
    required this.id,
    required this.partId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.quantity,
  });
}