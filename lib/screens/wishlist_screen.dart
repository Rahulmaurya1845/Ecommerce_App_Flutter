// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import '../service/database.dart';
// import 'product_details_screen.dart';
//
// class WishlistScreen extends StatefulWidget {
//   const WishlistScreen({super.key});
//
//   @override
//   State<WishlistScreen> createState() => _WishlistScreenState();
// }
//
// class _WishlistScreenState extends State<WishlistScreen> {
//   final DatabaseMethods _db = DatabaseMethods();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0F0F0F),
//       appBar: AppBar(
//         title: const Text('My Wishlist'),
//         actions: [
//           TextButton(
//             onPressed: () => _clearWishlist(),
//             child: const Text('Clear All', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//       body: StreamBuilder<DocumentSnapshot>(
//         stream: _db.getWishlist(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(
//               child: CircularProgressIndicator(color: Color(0xFF6366F1)),
//             );
//           }
//
//           if (snapshot.hasError) {
//             return _buildErrorState('Error: ${snapshot.error}');
//           }
//
//           if (!snapshot.hasData || !snapshot.data!.exists) {
//             return _buildEmptyState();
//           }
//
//           final data = snapshot.data!.data() as Map<String, dynamic>?;
//           final items = data?['items'] as List<dynamic>? ?? [];
//
//           if (items.isEmpty) {
//             return _buildEmptyState();
//           }
//
//           return ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: items.length,
//             itemBuilder: (context, index) => _buildWishlistItem(items[index]),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade700),
//           const SizedBox(height: 20),
//           Text(
//             'Your wishlist is empty',
//             style: TextStyle(fontSize: 20, color: Colors.grey.shade400, fontWeight: FontWeight.w600),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Save items you love for later',
//             style: TextStyle(color: Colors.grey.shade600),
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF6366F1),
//               padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             ),
//             child: const Text('Start Shopping'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildErrorState(String error) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.error_outline, size: 60, color: Colors.red.shade400),
//           const SizedBox(height: 16),
//           Text(
//             'Something went wrong',
//             style: TextStyle(color: Colors.grey.shade400, fontSize: 18),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             error,
//             style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildWishlistItem(Map<String, dynamic> item) {
//     final productId = item['productId'] ?? '';
//     final name = item['name'] ?? 'Product';
//     final image = item['image'] ?? '';
//     final price = (item['price'] ?? 0).toDouble();
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: const Color(0xFF1A1A2E),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Row(
//         children: [
//           ClipRRect(
//             borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
//             child: CachedNetworkImage(
//               imageUrl: image,
//               width: 100,
//               height: 100,
//               fit: BoxFit.cover,
//               placeholder: (_, __) => Container(color: Colors.grey.shade800),
//               errorWidget: (_, __, ___) => Container(
//                 color: Colors.grey.shade800,
//                 child: const Icon(Icons.image_not_supported, color: Colors.grey),
//               ),
//             ),
//           ),
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(12),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     name,
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white),
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     '\$${price.toStringAsFixed(2)}',
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF6366F1),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       ElevatedButton.icon(
//                         onPressed: () => _addToCart(item),
//                         icon: const Icon(Icons.shopping_bag, size: 16),
//                         label: const Text('Add to Cart'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF6366F1),
//                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                         ),
//                       ),
//                       const Spacer(),
//                       IconButton(
//                         icon: const Icon(Icons.delete_outline, color: Colors.red),
//                         onPressed: () => _removeFromWishlist(productId),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _addToCart(Map<String, dynamic> item) {
//     Fluttertoast.showToast(
//       msg: 'Added to cart',
//       backgroundColor: Colors.green,
//       textColor: Colors.white,
//     );
//   }
//
//   void _removeFromWishlist(String productId) async {
//     await _db.removeFromWishlist(productId);
//     Fluttertoast.showToast(msg: 'Removed from wishlist');
//   }
//
//   void _clearWishlist() async {
//     final user = _auth.currentUser;
//     if (user == null) return;
//
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: const Color(0xFF1A1A2E),
//         title: const Text('Clear Wishlist?'),
//         content: const Text('Remove all items from wishlist?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             onPressed: () async {
//               await FirebaseFirestore.instance
//                   .collection('Wishlists')
//                   .doc(user.uid)
//                   .delete();
//               Navigator.pop(context);
//               Fluttertoast.showToast(msg: 'Wishlist cleared');
//             },
//             child: const Text('Clear'),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../service/database.dart';
import 'product_details_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final DatabaseMethods _db = DatabaseMethods();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    // If user not logged in, show login prompt
    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F0F0F),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F0F0F),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('My Wishlist', style: TextStyle(color: Colors.white)),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.favorite_border, size: 80, color: Color(0xFF6B6B8B)),
              const SizedBox(height: 20),
              const Text(
                'Please login first',
                style: TextStyle(fontSize: 20, color: Color(0xFFBBBBBB), fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'Login to save your favorite items',
                style: TextStyle(color: Color(0xFF6B6B8B)),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Go Back', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Wishlist', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () => _clearWishlist(),
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Wishlists')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6366F1)),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorState('Error: ${snapshot.error}');
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return _buildEmptyState();
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final items = data?['items'] as List<dynamic>? ?? [];

          if (items.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) => _buildWishlistItem(items[index]),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite_border, size: 80, color: Color(0xFF6B6B8B)),
          const SizedBox(height: 20),
          const Text(
            'Your wishlist is empty',
            style: TextStyle(fontSize: 20, color: Color(0xFFBBBBBB), fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Save items you love for later',
            style: TextStyle(color: Color(0xFF6B6B8B)),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Start Shopping', style: TextStyle(color: Colors.white)),
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
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Something went wrong',
            style: TextStyle(color: Color(0xFFBBBBBB), fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(color: Color(0xFF6B6B8B), fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistItem(Map<String, dynamic> item) {
    final productId = item['productId'] ?? '';
    final name = item['name'] ?? 'Product';
    final image = item['image'] ?? '';
    final price = (item['price'] ?? 0).toDouble();
    final originalPrice = (item['originalPrice'] ?? price).toDouble();
    final discount = originalPrice > price ? ((originalPrice - price) / originalPrice * 100).toInt() : 0;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailsScreen(productId: productId)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              // Image section with dark background
              Container(
                width: 100,
                height: 100,
                color: const Color(0xFF1A1A2E),
                child: CachedNetworkImage(
                  imageUrl: image,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: const Color(0xFF1A1A2E),
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Color(0xFF6366F1),
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: const Color(0xFF1A1A2E),
                    child: const Icon(Icons.image_not_supported, color: Color(0xFF6B6B8B)),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: const Color(0xFF1A1A2E),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            '₹${price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (originalPrice > price)
                            Text(
                              '₹${originalPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B6B8B),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          if (discount > 0)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '$discount% OFF',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _addToCart(item),
                            icon: const Icon(Icons.shopping_bag, size: 16, color: Colors.white),
                            label: const Text('Add to Cart', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => _removeFromWishlist(productId),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addToCart(Map<String, dynamic> item) {
    Fluttertoast.showToast(
      msg: 'Added to cart',
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  void _removeFromWishlist(String productId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final docRef = FirebaseFirestore.instance.collection('Wishlists').doc(user.uid);
      final doc = await docRef.get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
        items.removeWhere((item) => item['productId'] == productId);

        if (items.isEmpty) {
          await docRef.delete();
        } else {
          await docRef.update({'items': items});
        }
      }

      Fluttertoast.showToast(
        msg: 'Removed from wishlist',
        backgroundColor: const Color(0xFF6366F1),
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  void _clearWishlist() async {
    final user = _auth.currentUser;
    if (user == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Clear Wishlist?', style: TextStyle(color: Colors.white)),
        content: const Text('Remove all items from wishlist?', style: TextStyle(color: Color(0xFFBBBBBB))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B6B8B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('Wishlists')
                  .doc(user.uid)
                  .delete();
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: 'Wishlist cleared',
                backgroundColor: Colors.green,
                textColor: Colors.white,
              );
            },
            child: const Text('Clear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}