

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // Helper to get current timestamp
  DateTime _now() => DateTime.now();

  // ==================== BANNERS ====================
  Stream<QuerySnapshot> getBanners() {
    return _firestore
        .collection('Banners')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  // ==================== PRODUCTS ====================
  Stream<QuerySnapshot> getProducts() {
    return _firestore.collection('Products').snapshots();
  }

  Stream<QuerySnapshot> getFeaturedProducts() {
    return _firestore.collection('Products').limit(10).snapshots();
  }

  Stream<QuerySnapshot> getTrendingProducts() {
    return _firestore.collection('Products').limit(10).snapshots();
  }

  Stream<QuerySnapshot> getProductsByCategory(String category) {
    return _firestore
        .collection('Products')
        .where('category', isEqualTo: category)
        .snapshots();
  }

  Future<DocumentSnapshot> getProduct(String productId) {
    return _firestore.collection('Products').doc(productId).get();
  }

  Future<QuerySnapshot> searchProducts(String query) async {
    return await _firestore
        .collection('Products')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff')
        .get();
  }

  // ==================== CATEGORIES ====================
  Stream<QuerySnapshot> getCategories() {
    return _firestore.collection('Categories').orderBy('order').snapshots();
  }

  // ==================== USERS ====================
  Future<void> addUser(String userId, Map<String, dynamic> userInfo) async {
    await _firestore.collection('User').doc(userId).set(userInfo, SetOptions(merge: true));
  }

  Future<void> updateUser(String userId, Map<String, dynamic> userInfo) async {
    await _firestore.collection('User').doc(userId).update(userInfo);
  }

  Stream<DocumentSnapshot> getUser(String userId) {
    return _firestore.collection('User').doc(userId).snapshots();
  }

  Stream<DocumentSnapshot> getUserProfile() {
    final userId = _userId;
    if (userId == null) return Stream.empty();
    return _firestore.collection('User').doc(userId).snapshots();
  }

  // ==================== ADDRESSES ====================
  Stream<QuerySnapshot> getUserAddresses() {
    final userId = _userId;
    if (userId == null) return Stream.empty();
    return _firestore
        .collection('User')
        .doc(userId)
        .collection('Addresses')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> addAddress(Map<String, dynamic> addressData) async {
    final userId = _userId;
    if (userId == null) return;
    await _firestore
        .collection('User')
        .doc(userId)
        .collection('Addresses')
        .add({
      ...addressData,
      'createdAt': _now(),
    });
  }

  Future<void> updateAddress(String addressId, Map<String, dynamic> addressData) async {
    final userId = _userId;
    if (userId == null) return;
    await _firestore
        .collection('User')
        .doc(userId)
        .collection('Addresses')
        .doc(addressId)
        .update(addressData);
  }

  Future<void> deleteAddress(String addressId) async {
    final userId = _userId;
    if (userId == null) return;
    await _firestore
        .collection('User')
        .doc(userId)
        .collection('Addresses')
        .doc(addressId)
        .delete();
  }

  // ==================== ORDERS ====================
  // ==================== FIXED: Better error handling and fallback ====================
  Stream<QuerySnapshot> getOrders() {
    final userId = _userId;
    if (userId == null) return Stream.empty();

    try {
      return _firestore
          .collection('Orders')
          .where('userId', isEqualTo: userId)
          .orderBy('orderDate', descending: true)
          .snapshots();
    } catch (e) {
      // Fallback: if index error, return without ordering
      return _firestore
          .collection('Orders')
          .where('userId', isEqualTo: userId)
          .snapshots();
    }
  }

  Stream<QuerySnapshot> getUserOrders() {
    return getOrders();
  }

  Future<DocumentSnapshot> getOrder(String orderId) {
    return _firestore.collection('Orders').doc(orderId).get();
  }

  // ==================== FIXED: cancelOrder with notification + validation ====================
  Future<void> cancelOrder(String orderId) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not logged in');

    // Get order details first for the notification
    final orderDoc = await _firestore.collection('Orders').doc(orderId).get();
    if (!orderDoc.exists) throw Exception('Order not found');

    final orderData = orderDoc.data() as Map<String, dynamic>;
    final currentStatus = (orderData['orderStatus'] ?? '').toString().toLowerCase();

    // Prevent cancelling already cancelled or delivered orders
    if (currentStatus == 'cancelled') {
      throw Exception('Order is already cancelled');
    }
    if (currentStatus == 'delivered') {
      throw Exception('Cannot cancel a delivered order');
    }

    final batch = _firestore.batch();

    // 1. Update order status to cancelled
    final orderRef = _firestore.collection('Orders').doc(orderId);
    batch.update(orderRef, {
      'orderStatus': 'Cancelled',
      'cancelledAt': _now(),
      'cancelledBy': userId,
    });

    // 2. Add cancellation notification
    final notificationRef = _firestore.collection('Notifications').doc();
    batch.set(notificationRef, {
      'userId': userId,
      'title': 'Order Cancelled',
      'body': 'Your order #${orderId.substring(0, orderId.length > 8 ? 8 : orderId.length)} has been cancelled successfully.',
      'type': 'order',
      'orderId': orderId,
      'read': false,
      'timestamp': _now(),
    });

    await batch.commit();
  }

  // ==================== CART ====================
  Stream<DocumentSnapshot> getCart() {
    final userId = _userId;
    if (userId == null) return Stream.empty();
    return _firestore.collection('Carts').doc(userId).snapshots();
  }

  Future<void> updateCart(Map<String, dynamic> cartData) async {
    final userId = _userId;
    if (userId == null) return;
    await _firestore.collection('Carts').doc(userId).set({
      ...cartData,
      'updatedAt': _now(),
    }, SetOptions(merge: true));
  }

  Future<void> clearCart() async {
    final userId = _userId;
    if (userId == null) return;
    await _firestore.collection('Carts').doc(userId).delete();
  }

  // ==================== WISHLIST ====================
  Stream<DocumentSnapshot> getWishlist() {
    final userId = _userId;
    if (userId == null) return Stream.empty();
    return _firestore.collection('Wishlists').doc(userId).snapshots();
  }

  Future<bool> isInWishlist(String productId) async {
    final userId = _userId;
    if (userId == null) return false;
    final doc = await _firestore.collection('Wishlists').doc(userId).get();
    if (!doc.exists) return false;
    final data = doc.data() as Map<String, dynamic>?;
    final items = data?['items'] as List<dynamic>?;
    if (items == null) return false;
    return items.any((item) => item['productId'] == productId);
  }

  Future<void> addToWishlist(String productId, Map<String, dynamic> productData) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not logged in');

    final isAlreadyAdded = await isInWishlist(productId);
    if (isAlreadyAdded) return;

    await _firestore.collection('Wishlists').doc(userId).set({
      'items': FieldValue.arrayUnion([{
        'productId': productId,
        'name': productData['name'] ?? 'Product',
        'image': productData['image'] ?? '',
        'price': productData['price'] ?? 0,
        'originalPrice': productData['originalPrice'] ?? productData['price'] ?? 0,
        'category': productData['category'] ?? 'General',
        'rating': productData['rating'] ?? 0,
        'reviewCount': productData['reviewCount'] ?? 0,
        'addedAt': _now(),
      }])
    }, SetOptions(merge: true));
  }

  Future<void> removeFromWishlist(String productId) async {
    final userId = _userId;
    if (userId == null) return;
    final doc = await _firestore.collection('Wishlists').doc(userId).get();
    if (!doc.exists) return;
    final data = doc.data() as Map<String, dynamic>;
    final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
    items.removeWhere((item) => item['productId'] == productId);

    if (items.isEmpty) {
      await _firestore.collection('Wishlists').doc(userId).delete();
    } else {
      await _firestore.collection('Wishlists').doc(userId).update({'items': items});
    }
  }

  // ==================== REVIEWS ====================
  Stream<QuerySnapshot> getProductReviews(String productId) {
    return _firestore
        .collection('Reviews')
        .where('productId', isEqualTo: productId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> addReview(String productId, Map<String, dynamic> reviewData) async {
    final userId = _userId;
    if (userId == null) return;
    await _firestore.collection('Reviews').add({
      ...reviewData,
      'productId': productId,
      'userId': userId,
      'createdAt': _now(),
    });
  }

  // ==================== NOTIFICATIONS ====================
  Stream<QuerySnapshot> getNotifications() {
    final userId = _userId;
    if (userId == null) return Stream.empty();
    return _firestore
        .collection('Notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> markNotificationRead(String notificationId) async {
    await _firestore.collection('Notifications').doc(notificationId).update({'read': true});
  }

  Future<void> markAllNotificationsRead() async {
    final userId = _userId;
    if (userId == null) return;
    final batch = _firestore.batch();
    final query = await _firestore
        .collection('Notifications')
        .where('userId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .get();
    for (var doc in query.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }

  Stream<int> getUnreadNotificationCount() {
    final userId = _userId;
    if (userId == null) return Stream.value(0);
    return _firestore
        .collection('Notifications')
        .where('userId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // ==================== COUPONS ====================
  Stream<QuerySnapshot> getActiveCoupons() {
    return _firestore
        .collection('Coupons')
        .where('isActive', isEqualTo: true)
        .where('expiryDate', isGreaterThan: Timestamp.now())
        .orderBy('expiryDate')
        .snapshots();
  }

  Future<DocumentSnapshot?> getCouponByCode(String code) async {
    final query = await _firestore
        .collection('Coupons')
        .where('code', isEqualTo: code.toUpperCase())
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) return query.docs.first;
    return null;
  }

  Future<void> applyCouponToUser(String couponCode) async {
    final userId = _userId;
    if (userId == null) return;
    await _firestore.collection('User').doc(userId).update({
      'appliedCoupon': couponCode.toUpperCase(),
      'couponAppliedAt': _now(),
    });
  }

  // ==================== USER STATS ====================
  Stream<int> getUserOrderCount() {
    final userId = _userId;
    if (userId == null) return Stream.value(0);
    return _firestore
        .collection('Orders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> getUserWishlistCount() {
    final userId = _userId;
    if (userId == null) return Stream.value(0);
    return _firestore
        .collection('Wishlists')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return 0;
      final data = snapshot.data() as Map<String, dynamic>?;
      final items = data?['items'] as List<dynamic>?;
      return items?.length ?? 0;
    });
  }

  Stream<int> getUserReviewCount() {
    final userId = _userId;
    if (userId == null) return Stream.value(0);
    return _firestore
        .collection('Reviews')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}