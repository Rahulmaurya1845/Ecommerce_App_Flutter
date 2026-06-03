import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../service/database.dart';

class Coupon {
  final String code;
  final String description;
  final String discount;
  final double minOrder;
  final DateTime expiryDate;
  final bool isUsed;
  final String? discountType; // 'percentage', 'fixed', 'free_delivery'
  final double? discountValue;

  Coupon({
    required this.code,
    required this.description,
    required this.discount,
    required this.minOrder,
    required this.expiryDate,
    this.isUsed = false,
    this.discountType,
    this.discountValue,
  });

  factory Coupon.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Coupon(
      code: data['code'] ?? '',
      description: data['description'] ?? '',
      discount: data['discount'] ?? '',
      minOrder: (data['minOrder'] ?? 0).toDouble(),
      expiryDate: (data['expiryDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isUsed: data['isUsed'] ?? false,
      discountType: data['discountType'],
      discountValue: data['discountValue']?.toDouble(),
    );
  }
}

class CouponsScreen extends StatefulWidget {
  const CouponsScreen({super.key});

  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  final DatabaseMethods _db = DatabaseMethods();
  final TextEditingController _couponController = TextEditingController();
  String? _appliedCoupon;
  bool _isLoading = false;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text('Coupons & Offers'),
      ),
      body: Column(
        children: [
          _buildCouponInput(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _db.getActiveCoupons(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF6366F1)),
                  );
                }

                if (snapshot.hasError) {
                  return _buildErrorState('Error: ${snapshot.error}');
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                final coupons = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: coupons.length,
                  itemBuilder: (context, index) => _buildCouponCard(
                    Coupon.fromFirestore(coupons[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _couponController,
              style: const TextStyle(color: Colors.white),
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'Enter coupon code',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: const Icon(Icons.local_offer, color: Color(0xFF6366F1)),
                filled: true,
                fillColor: const Color(0xFF0F0F0F),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _isLoading ? null : _applyCoupon,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : const Text('Apply', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_offer_outlined, size: 80, color: Colors.grey.shade700),
          const SizedBox(height: 20),
          Text(
            'No active coupons',
            style: TextStyle(fontSize: 20, color: Colors.grey.shade400, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new offers',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCouponCard(Coupon coupon) {
    final isExpired = DateTime.now().isAfter(coupon.expiryDate);
    final daysLeft = coupon.expiryDate.difference(DateTime.now()).inDays;
    final isApplied = _appliedCoupon == coupon.code;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isApplied
              ? const Color(0xFF6366F1)
              : Colors.grey.shade800,
          width: isApplied ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  coupon.code,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    coupon.discount,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coupon.description,
                  style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.shopping_bag_outlined, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Text(
                      'Min order: \$${coupon.minOrder.toStringAsFixed(0)}',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: isExpired ? Colors.red : (daysLeft <= 3 ? Colors.orange : Colors.grey.shade500),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isExpired
                          ? 'Expired'
                          : (daysLeft <= 3 ? 'Expires in $daysLeft days' : 'Valid till ${coupon.expiryDate.day}/${coupon.expiryDate.month}/${coupon.expiryDate.year}'),
                      style: TextStyle(
                        color: isExpired ? Colors.red : (daysLeft <= 3 ? Colors.orange : Colors.grey.shade500),
                        fontSize: 12,
                        fontWeight: daysLeft <= 3 ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isExpired || isApplied
                        ? null
                        : () => _copyCoupon(coupon.code),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isApplied
                          ? Colors.green
                          : const Color(0xFF6366F1),
                      disabledBackgroundColor: Colors.grey.shade800,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      isApplied ? 'Applied' : 'Copy Code',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _applyCoupon() async {
    final code = _couponController.text.trim().toUpperCase();
    if (code.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter a coupon code');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final couponDoc = await _db.getCouponByCode(code);

      if (couponDoc == null) {
        Fluttertoast.showToast(msg: 'Invalid coupon code');
        setState(() => _isLoading = false);
        return;
      }

      final data = couponDoc.data() as Map<String, dynamic>;
      final expiryDate = (data['expiryDate'] as Timestamp?)?.toDate() ?? DateTime.now();

      if (DateTime.now().isAfter(expiryDate)) {
        Fluttertoast.showToast(msg: 'This coupon has expired');
        setState(() => _isLoading = false);
        return;
      }

      await _db.applyCouponToUser(code);

      setState(() {
        _appliedCoupon = code;
        _isLoading = false;
      });

      Fluttertoast.showToast(
        msg: 'Coupon $code applied!',
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      _couponController.clear();
    } catch (e) {
      setState(() => _isLoading = false);
      Fluttertoast.showToast(
        msg: 'Error: $e',
        backgroundColor: Colors.red,
      );
    }
  }

  void _copyCoupon(String code) {
    setState(() {
      _appliedCoupon = code;
    });

    Fluttertoast.showToast(
      msg: 'Coupon $code copied!',
      backgroundColor: const Color(0xFF6366F1),
      textColor: Colors.white,
    );
  }
}