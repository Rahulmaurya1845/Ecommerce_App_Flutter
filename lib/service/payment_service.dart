
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'cart_provider.dart';
import 'address_provider.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Function(String orderId)? onPaymentSuccess;
  Function(String error)? onPaymentError;

  // NO RAZORPAY - All payments are simulated for testing

  String _getEstimatedDelivery() {
    final date = DateTime.now().add(const Duration(days: 5));
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showToast(String message, Color bgColor) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: bgColor,
      textColor: Colors.white,
      fontSize: 16,
    );
  }

  // ==================== FIXED: Unified order placement ====================
  // Both COD and online payments use this same method now
  Future<String?> placeOrder({
    required List<CartItem> cartItems,
    required double totalAmount,
    required Address? address,
    required String paymentMethod,
    bool isSimulated = false,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      _showToast('Please login to place order', Colors.red);
      return null;
    }

    try {
      final orderId = _firestore.collection('Orders').doc().id;
      final now = Timestamp.now();

      // Determine payment status based on method
      String paymentStatus;
      String orderStatus;

      switch (paymentMethod.toLowerCase()) {
        case 'cod':
        case 'cash on delivery':
          paymentStatus = 'pending';
          orderStatus = 'Processing';
          break;
        case 'card':
        case 'credit/debit card':
        case 'credit card':
        case 'debit card':
        case 'upi':
        case 'netbanking':
        case 'net banking':
          paymentStatus = 'completed';
          orderStatus = 'Processing';
          break;
        default:
          paymentStatus = 'completed';
          orderStatus = 'Processing';
      }

      // ==================== FIXED: Use DateTime.now() instead of FieldValue.serverTimestamp()
      // This matches DatabaseMethods and avoids index/query conflicts
      final orderData = {
        'orderId': orderId,
        'userId': userId,
        'items': cartItems.map((item) => {
          'productId': item.productId,
          'name': item.name,
          'image': item.image,
          'price': item.price,
          'quantity': item.quantity,
          'category': item.category,
        }).toList(),
        'totalAmount': totalAmount,
        'paymentMethod': paymentMethod,
        'paymentStatus': paymentStatus,
        'orderStatus': orderStatus,
        'deliveryAddress': address != null ? {
          'name': address.name,
          'phone': address.phone,
          'address': '${address.address}, ${address.city}, ${address.state} - ${address.pincode}',
        } : {},
        'orderDate': DateTime.now(), // FIXED: Use DateTime instead of FieldValue
        'estimatedDelivery': _getEstimatedDelivery(),
        'trackingUpdates': [
          {
            'status': 'Order Placed',
            'time': now,
            'location': 'Warehouse',
          }
        ],
      };

      await _firestore.collection('Orders').doc(orderId).set(orderData);

      // ==================== FIXED: Notification also uses DateTime ====================
      await _firestore.collection('Notifications').add({
        'userId': userId,
        'title': 'Order Placed Successfully!',
        'body': 'Your order #${orderId.substring(0, orderId.length > 8 ? 8 : orderId.length)} has been placed. Total: \$${totalAmount.toStringAsFixed(2)}',
        'type': 'order',
        'orderId': orderId,
        'timestamp': DateTime.now(), // FIXED: Use DateTime instead of FieldValue
        'read': false,
      });

      _showToast('Order placed successfully!', Colors.green);
      return orderId;
    } catch (e) {
      _showToast('Error placing order: $e', Colors.red);
      return null;
    }
  }

  // ==================== FIXED: simulatePaymentAndPlaceOrder now calls placeOrder ====================
  Future<String?> simulatePaymentAndPlaceOrder({
    required List<CartItem> cartItems,
    required double totalAmount,
    required Address? address,
    required String paymentMethod,
  }) async {
    return placeOrder(
      cartItems: cartItems,
      totalAmount: totalAmount,
      address: address,
      paymentMethod: paymentMethod,
      isSimulated: true,
    );
  }

  // Dispose method - empty but exists so checkout_screen can call it
  void dispose() {
    // Nothing to dispose since Razorpay is removed
  }
}