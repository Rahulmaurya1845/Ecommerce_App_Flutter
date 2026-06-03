import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'admin_add_product_screen.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text('Manage Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminAddProductScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF1A1A2E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Products List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('Products').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)));
                }

                var products = snapshot.data!.docs;

                // Filter by search
                if (_searchQuery.isNotEmpty) {
                  products = products.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = (data['name'] ?? '').toString().toLowerCase();
                    final category = (data['category'] ?? '').toString().toLowerCase();
                    return name.contains(_searchQuery) || category.contains(_searchQuery);
                  }).toList();
                }

                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade700),
                        const SizedBox(height: 16),
                        Text('No products found', style: TextStyle(color: Colors.grey.shade400, fontSize: 18)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: products.length,
                  itemBuilder: (context, index) => _buildProductCard(products[index]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6366F1),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminAddProductScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProductCard(DocumentSnapshot product) {
    final data = product.data() as Map<String, dynamic>;
    final name = data['name'] ?? 'No Name';
    final price = (data['price'] ?? 0).toDouble();
    final originalPrice = (data['originalPrice'] ?? price).toDouble();
    final stock = data['stock'] ?? 0;
    final image = data['image'] ?? '';
    final category = data['category'] ?? 'General';
    final isActive = data['isActive'] ?? true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: image,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: Colors.grey.shade800),
              errorWidget: (_, __, ___) => Container(
                color: Colors.grey.shade800,
                child: const Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(category, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Rs.${price.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
                    ),
                    const SizedBox(width: 8),
                    if (originalPrice > price)
                      Text(
                        'Rs.${originalPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: stock > 0 ? Colors.green.withAlpha(26) : Colors.red.withAlpha(26),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        stock > 0 ? 'In Stock: $stock' : 'Out of Stock',
                        style: TextStyle(
                          color: stock > 0 ? Colors.green : Colors.red,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (!isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.withAlpha(26),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Hidden',
                          style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFF6366F1)),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminAddProductScreen(productId: product.id, productData: data),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _showDeleteDialog(product.id, name),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String productId, String productName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Delete Product?', style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to delete "$productName"?', style: const TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await _firestore.collection('Products').doc(productId).delete();
              Fluttertoast.showToast(
                msg: 'Product deleted',
                backgroundColor: Colors.green,
                textColor: Colors.white,
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}