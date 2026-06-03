import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';
import '../service/database.dart';
import 'product_details_screen.dart';

class CategoryProductsScreen extends StatelessWidget {
  final String category;
  const CategoryProductsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseMethods();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          category,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        // CRITICAL: Wrap entire body in dark container to prevent ANY white leaking
        color: const Color(0xFF0F0F0F),
        child: StreamBuilder<QuerySnapshot>(
          stream: db.getProductsByCategory(category),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildShimmerGrid();
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.inventory_2_outlined, size: 64, color: Color(0xFF6B6B8B)),
                    const SizedBox(height: 16),
                    Text(
                      'No products in $category',
                      style: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            final products = snapshot.data!.docs;

            // CRITICAL FIX: Use Container with dark color as GridView parent
            // This ensures spacing areas are dark, not white
            return Container(
              color: const Color(0xFF0F0F0F),
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) => _buildProductCard(context, products[index]),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, DocumentSnapshot product) {
    final data = product.data() as Map<String, dynamic>? ?? {};
    final price = (data['price'] ?? 0).toDouble();
    final originalPrice = (data['originalPrice'] ?? price).toDouble();
    final discount = originalPrice > price ? ((originalPrice - price) / originalPrice * 100).toInt() : 0;
    final rating = (data['rating'] ?? 0).toString();
    final reviewCount = (data['reviewCount'] ?? 0).toString();
    final imageUrl = data['image'] ?? '';
    final productName = data['name'] ?? 'Product';
    final productCategory = data['category'] ?? 'General';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailsScreen(productId: product.id)),
      ),
      // CRITICAL FIX: Use Material widget with explicit dark color
      // Material handles elevation and clipping better than Container
      child: Material(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Container(
          color: const Color(0xFF1A1A2E),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // IMAGE SECTION - wrapped in dark container with NO ClipRRect gap
              Container(
                height: 120,
                width: double.infinity,
                color: const Color(0xFF1A1A2E),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Dark background behind image
                    Container(color: const Color(0xFF1A1A2E)),
                    Image.network(
                      imageUrl,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      // CRITICAL: Add filter quality and color filter to prevent white flash
                      filterQuality: FilterQuality.medium,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: const Color(0xFF1A1A2E),
                          child: const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Color(0xFF6366F1),
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFF1A1A2E),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.image_not_supported, color: Color(0xFF6B6B8B), size: 32),
                            const SizedBox(height: 4),
                            Text(
                              productName,
                              style: const TextStyle(color: Color(0xFF6B6B8B), fontSize: 10),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (discount > 0)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$discount% OFF',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(179),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.star, size: 12, color: Colors.amber.shade600),
                            const SizedBox(width: 2),
                            Text(
                              rating,
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // TEXT SECTION - explicit dark background, no gaps
              Container(
                color: const Color(0xFF1A1A2E),
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(productCategory).withAlpha(51),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        productCategory,
                        style: TextStyle(
                          fontSize: 10,
                          color: _getCategoryColor(productCategory),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.white),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          '₹${price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF6366F1),
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (originalPrice > price)
                          Text(
                            '₹${originalPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF6B6B8B),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(Icons.star, size: 12, color: Colors.amber.shade600),
                        const SizedBox(width: 4),
                        Text(
                          rating,
                          style: const TextStyle(fontSize: 11, color: Color(0xFFBBBBBB)),
                        ),
                        Text(
                          ' ($reviewCount)',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF6B6B8B)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Electronics':
        return Colors.blue;
      case 'Fashion':
        return Colors.pink;
      case 'Home':
        return Colors.orange;
      case 'Beauty':
        return Colors.purple;
      case 'Sports':
        return Colors.green;
      default:
        return const Color(0xFF6366F1);
    }
  }

  Widget _buildShimmerGrid() {
    return Container(
      color: const Color(0xFF0F0F0F),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFF1A1A2E),
        highlightColor: const Color(0xFF2A2A3E),
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.72,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: 6,
          itemBuilder: (_, __) => Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}