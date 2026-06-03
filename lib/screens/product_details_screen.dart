import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart'; // <-- ADDED: Share package
import '../service/database.dart';
import '../service/cart_provider.dart';
import 'cart_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final DatabaseMethods _db = DatabaseMethods();
  int _quantity = 1;
  bool _isInWishlist = false;
  Map<String, dynamic>? _productData;

  @override
  void initState() {
    super.initState();
    _checkWishlist();
  }

  void _checkWishlist() async {
    final result = await _db.isInWishlist(widget.productId);
    if (mounted) {
      setState(() => _isInWishlist = result);
    }
  }

  // FIXED: Separate method to toggle wishlist with proper data
  Future<void> _toggleWishlist(Map<String, dynamic> productData) async {
    try {
      if (_isInWishlist) {
        await _db.removeFromWishlist(widget.productId);
        if (mounted) {
          setState(() => _isInWishlist = false);
        }
        Fluttertoast.showToast(
          msg: 'Removed from wishlist',
          backgroundColor: const Color(0xFF6366F1),
          textColor: Colors.white,
        );
      } else {
        await _db.addToWishlist(widget.productId, productData);
        if (mounted) {
          setState(() => _isInWishlist = true);
        }
        Fluttertoast.showToast(
          msg: 'Added to wishlist',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  // ==================== FIXED SHARE METHOD ====================
  void _shareProduct(Map<String, dynamic> data) {
    try {
      final name = data['name'] ?? 'Amazing Product';
      final price = (data['price'] ?? 0).toDouble();
      final description = data['description'] ?? 'Check out this amazing product!';

      final shareText = '''
$name

Price: Rs.${price.toStringAsFixed(0)}

$description

View product in LUXE app!
      '''.trim();

      Share.share(
        shareText,
        subject: 'Check out $name on LUXE!',
      );

      Fluttertoast.showToast(
        msg: 'Share sheet opened!',
        backgroundColor: const Color(0xFF6366F1),
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Share error: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
  // ===========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('Products').doc(widget.productId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data == null) {
            return const Center(child: Text('Product not found', style: TextStyle(color: Colors.white)));
          }

          _productData = data;
          final price = (data['price'] ?? 0).toDouble();
          final originalPrice = (data['originalPrice'] ?? price).toDouble();
          final discount = originalPrice > price ? ((originalPrice - price) / originalPrice * 100).toInt() : 0;

          return CustomScrollView(
            slivers: [
              _buildAppBar(data),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageCarousel(data),
                    _buildProductInfo(data, price, originalPrice, discount),
                    _buildQuantitySelector(price),
                    _buildDescription(data),
                    _buildSpecifications(data),
                    _buildReviewsSection(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomSheet: _buildBottomBar(),
    );
  }

  // FIXED: AppBar now receives data as parameter and uses _toggleWishlist method
  // FIXED: Share button now calls _shareProduct instead of just showing toast
  Widget _buildAppBar(Map<String, dynamic> data) {
    return SliverAppBar(
      floating: true,
      backgroundColor: const Color(0xFF0F0F0F),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isInWishlist ? Icons.favorite : Icons.favorite_border,
            color: _isInWishlist ? Colors.red : Colors.white,
          ),
          onPressed: () => _toggleWishlist(data),
        ),
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () => _shareProduct(data), // <-- FIXED: Now actually shares!
        ),
      ],
    );
  }

  Widget _buildImageCarousel(Map<String, dynamic> data) {
    final images = List<String>.from(data['images'] ?? [data['image'] ?? '']);

    return Container(
      height: 350,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: PageView.builder(
          itemCount: images.length,
          itemBuilder: (context, index) {
            return Container(
              color: const Color(0xFF1A1A2E),
              child: CachedNetworkImage(
                imageUrl: images[index],
                fit: BoxFit.contain,
                placeholder: (_, __) => Container(
                  color: const Color(0xFF1A1A2E),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF6366F1),
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: const Color(0xFF1A1A2E),
                  child: const Icon(Icons.image_not_supported, color: Color(0xFF6B6B8B)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductInfo(Map<String, dynamic> data, double price, double originalPrice, int discount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (discount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('$discount% OFF', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          const SizedBox(height: 12),
          Text(
            data['name'] ?? 'Product',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A7A3A), // Fixed: no grey.shade
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Text('${data['rating'] ?? 0}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const Icon(Icons.star, size: 14, color: Colors.white),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text('${data['reviewCount'] ?? 0} Reviews', style: const TextStyle(color: Color(0xFFBBBBBB))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Rs.${price.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
              ),
              const SizedBox(width: 12),
              if (originalPrice > price)
                Text(
                  'Rs.${originalPrice.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 18, color: Color(0xFF6B6B8B), decoration: TextDecoration.lineThrough),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            data['stock'] != null && data['stock'] > 0 ? 'In Stock' : 'Out of Stock',
            style: TextStyle(
              color: data['stock'] != null && data['stock'] > 0 ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector(double price) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Text('Quantity:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(width: 16),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, color: Colors.white),
                  onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                ),
                Text('$_quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () => setState(() => _quantity++),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            'Total: Rs.${(price * _quantity).toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 10),
          Text(
            data['description'] ?? 'No description available',
            style: const TextStyle(color: Color(0xFFBBBBBB), height: 1.6, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecifications(Map<String, dynamic> data) {
    final specs = Map<String, dynamic>.from(data['specifications'] ?? {});
    if (specs.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Specifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 10),
          ...specs.entries.map((entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(entry.key, style: const TextStyle(color: Color(0xFFBBBBBB))),
                ),
                Expanded(
                  flex: 3,
                  child: Text(entry.value.toString(), style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white)),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Reviews', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              TextButton(
                onPressed: () => _showAddReviewDialog(),
                child: const Text('Write a Review', style: TextStyle(color: Color(0xFF6366F1))),
              ),
            ],
          ),
          const SizedBox(height: 10),
          StreamBuilder<QuerySnapshot>(
            stream: _db.getProductReviews(widget.productId),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Text('No reviews yet', style: TextStyle(color: Color(0xFF6B6B8B)));
              }

              return Column(
                children: snapshot.data!.docs.map((review) {
                  final r = review.data() as Map<String, dynamic>;
                  final ratingVal = (r['rating'] ?? 0).toInt();
                  return Card(
                    color: const Color(0xFF1A1A2E),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: const Color(0xFF6366F1),
                                child: Text((r['userName'] ?? 'U')[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(r['userName'] ?? 'User', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                                    Row(
                                      children: List.generate(5, (i) => Icon(
                                        i < ratingVal ? Icons.star : Icons.star_border,
                                        size: 14,
                                        color: Colors.amber,
                                      )),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(r['comment'] ?? '', style: const TextStyle(color: Color(0xFFBBBBBB))),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAddReviewDialog() {
    int rating = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          title: const Text('Write a Review', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) => IconButton(
                  icon: Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () => setDialogState(() => rating = index + 1),
                )),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: commentController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Write your review...',
                  hintStyle: const TextStyle(color: Color(0xFF6B6B8B)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: const Color(0xFF0F0F0F),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B6B8B))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
              onPressed: () async {
                if (commentController.text.isEmpty) {
                  Fluttertoast.showToast(
                    msg: 'Please write a review',
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                  );
                  return;
                }
                await _db.addReview(widget.productId, {
                  'rating': rating,
                  'comment': commentController.text,
                  'userName': 'User',
                  // 'timestamp' is added by DatabaseMethods automatically
                });
                Navigator.pop(dialogContext);
                Fluttertoast.showToast(
                  msg: 'Review submitted!',
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                );
              },
              child: const Text('Submit', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(77), blurRadius: 10)],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  if (_productData != null) {
                    final cartProvider = Provider.of<CartProvider>(context, listen: false);
                    cartProvider.addToCart({'id': widget.productId, ..._productData!});
                    Fluttertoast.showToast(
                      msg: 'Added to cart',
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                    );
                  }
                },
                icon: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF6366F1)),
                label: const Text('Add to Cart', style: TextStyle(color: Color(0xFF6366F1))),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6366F1),
                  side: const BorderSide(color: Color(0xFF6366F1)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_productData != null) {
                    final cartProvider = Provider.of<CartProvider>(context, listen: false);
                    cartProvider.addToCart({'id': widget.productId, ..._productData!});
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
                  }
                },
                icon: const Icon(Icons.flash_on, color: Colors.white),
                label: const Text('Buy Now', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}