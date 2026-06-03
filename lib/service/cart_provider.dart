import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CartItem {
  final String productId;
  final String name;
  final String image;
  final double price;
  final int quantity;
  final String category;

  CartItem({
    required this.productId,
    required this.name,
    required this.image,
    required this.price,
    required this.quantity,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'image': image,
      'price': price,
      'quantity': quantity,
      'category': category,
      'addedAt': FieldValue.serverTimestamp(),
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      productId: map['productId'] ?? '',
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
      category: map['category'] ?? '',
    );
  }

  CartItem copyWith({int? quantity}) {
    return CartItem(
      productId: productId,
      name: name,
      image: image,
      price: price,
      quantity: quantity ?? this.quantity,
      category: category,
    );
  }
}

class CartProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<CartItem> _items = [];
  bool _isLoading = false;

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;

  String get _userId => _auth.currentUser?.uid ?? '';

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount => _items.fold(
    0.0,
        (sum, item) => sum + (item.price * item.quantity),
  );

  double get discount => totalAmount > 1000 ? totalAmount * 0.1 : 0;
  double get deliveryCharge => totalAmount > 500 ? 0 : 40;
  double get finalAmount => totalAmount - discount + deliveryCharge;

  Future<void> fetchCart() async {
    if (_userId.isEmpty) {
      _items = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('User')
          .doc(_userId)
          .collection('Cart')
          .get();

      _items = snapshot.docs
          .map((doc) => CartItem.fromMap(doc.data()))
          .toList();
    } catch (e) {
      _showToast('Error loading cart');
      _items = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addToCart(Map<String, dynamic> product) async {
    if (_userId.isEmpty) {
      _showToast('Please login to add items');
      return;
    }

    final String productId = product['id'] ?? '';
    if (productId.isEmpty) {
      _showToast('Invalid product');
      return;
    }

    final existingIndex = _items.indexWhere((item) => item.productId == productId);

    try {
      if (existingIndex >= 0) {
        final newQty = _items[existingIndex].quantity + 1;
        await _firestore
            .collection('User')
            .doc(_userId)
            .collection('Cart')
            .doc(productId)
            .update({'quantity': newQty});

        _items[existingIndex] = _items[existingIndex].copyWith(quantity: newQty);
        _showToast('Quantity updated in cart');
      } else {
        final cartItem = CartItem(
          productId: productId,
          name: product['name'] ?? 'Product',
          image: product['image'] ?? '',
          price: (product['price'] ?? 0).toDouble(),
          quantity: 1,
          category: product['category'] ?? '',
        );

        await _firestore
            .collection('User')
            .doc(_userId)
            .collection('Cart')
            .doc(productId)
            .set(cartItem.toMap());

        _items.add(cartItem);
        _showToast('Added to cart successfully');
      }
    } catch (e) {
      _showToast('Error adding to cart');
    }

    notifyListeners();
  }

  Future<void> removeFromCart(String productId) async {
    if (_userId.isEmpty) return;

    try {
      await _firestore
          .collection('User')
          .doc(_userId)
          .collection('Cart')
          .doc(productId)
          .delete();

      _items.removeWhere((item) => item.productId == productId);
      _showToast('Removed from cart');
      notifyListeners();
    } catch (e) {
      _showToast('Error removing item');
    }
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    if (_userId.isEmpty) return;

    if (quantity <= 0) {
      await removeFromCart(productId);
      return;
    }

    try {
      await _firestore
          .collection('User')
          .doc(_userId)
          .collection('Cart')
          .doc(productId)
          .update({'quantity': quantity});

      final index = _items.indexWhere((item) => item.productId == productId);
      if (index >= 0) {
        _items[index] = _items[index].copyWith(quantity: quantity);
      }
      notifyListeners();
    } catch (e) {
      _showToast('Error updating quantity');
    }
  }

  Future<void> clearCart() async {
    if (_userId.isEmpty) return;

    try {
      final batch = _firestore.batch();
      final cartRef = _firestore
          .collection('User')
          .doc(_userId)
          .collection('Cart');

      final snapshot = await cartRef.get();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      _items.clear();
      notifyListeners();
    } catch (e) {
      _showToast('Error clearing cart');
    }
  }

  bool isInCart(String productId) {
    return _items.any((item) => item.productId == productId);
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: const Color(0xFF6366F1),
      textColor: Colors.white,
      fontSize: 14,
    );
  }
}