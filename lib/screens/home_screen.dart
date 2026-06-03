import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:badges/badges.dart' as badges;
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../service/database.dart';
import '../service/cart_provider.dart';
import 'cart_screen.dart';
import 'product_details_screen.dart';
import 'notifications_screen.dart';
import 'search_screen.dart';
import 'wishlist_screen.dart';
import 'profile_screen.dart';
import 'orders_screen.dart';
import 'category_products_screen.dart';
import 'categories_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final DatabaseMethods _db = DatabaseMethods();
  int _bannerIndex = 0;
  int _selectedCategory = 0;
  String _selectedCategoryName = 'All';
  late AnimationController _animationController;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.apps, 'color': Color(0xFF6366F1)},
    {'name': 'Electronics', 'icon': Icons.devices, 'color': Colors.blue},
    {'name': 'Fashion', 'icon': Icons.checkroom, 'color': Colors.pink},
    {'name': 'Home', 'icon': Icons.home, 'color': Colors.orange},
    {'name': 'Beauty', 'icon': Icons.spa, 'color': Colors.purple},
    {'name': 'Sports', 'icon': Icons.sports, 'color': Colors.green},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartProvider>(context, listen: false).fetchCart();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(child: _buildSearchBar()),
            SliverToBoxAdapter(child: _buildBannerSlider()),
            SliverToBoxAdapter(child: _buildCategoryChips()),
            SliverToBoxAdapter(child: _buildSectionTitle('Trending Now', Icons.trending_up)),
            _buildProductSliverGrid(isTrending: true),
            SliverToBoxAdapter(child: _buildSectionTitle('Featured Products', Icons.star)),
            _buildProductSliverGrid(isFeatured: true),
            SliverToBoxAdapter(child: _buildSectionTitle('All Products', Icons.grid_view)),
            _buildProductSliverGrid(),
            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildAppBar() {
    final cartCount = context.watch<CartProvider>().itemCount;

    return SliverAppBar(
      floating: true,
      backgroundColor: const Color(0xFF0F0F0F),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'LUXE',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistScreen())),
          ),
          badges.Badge(
            badgeContent: Text(
              '\$cartCount',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            showBadge: cartCount > 0,
            child: IconButton(
              icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2A2A3E)),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Color(0xFF6B6B8B)),
            const SizedBox(width: 12),
            Text(
              'Search products, brands...',
              style: TextStyle(color: const Color(0xFF6B6B8B), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // FIXED BANNER SLIDER - Fetches from Firestore Banners collection with better error handling
  Widget _buildBannerSlider() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Banners')
          .orderBy('createdAt', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        // Show shimmer while loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmerBanner();
        }

        if (snapshot.hasError) {
          return Container(
            height: 180,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    'Error loading banners',
                    style: TextStyle(color: const Color(0xFFBBBBBB), fontSize: 14),
                  ),
                ],
              ),
            ),
          );
        }

        final banners = snapshot.data?.docs ?? [];

        // If no banners uploaded yet, show upload prompt
        if (banners.isEmpty) {
          return Container(
            height: 180,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2A2A3E)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.image_not_supported, color: Color(0xFF6B6B8B), size: 48),
                const SizedBox(height: 12),
                const Text(
                  'No banners uploaded yet',
                  style: TextStyle(color: Color(0xFFBBBBBB), fontSize: 14),
                ),
                const SizedBox(height: 8),
                const Text(
                  'No banners available',
                  style: TextStyle(color: Color(0xFF6366F1), fontSize: 14),
                ),
              ],
            ),
          );
        }

        return StatefulBuilder(
          builder: (context, setBannerState) {
            return Column(
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: 180,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    viewportFraction: 0.92,
                    autoPlayInterval: const Duration(seconds: 4),
                    autoPlayAnimationDuration: const Duration(milliseconds: 800),
                    onPageChanged: (index, _) => setBannerState(() => _bannerIndex = index),
                  ),
                  items: banners.map((banner) {
                    final bannerData = banner.data() as Map<String, dynamic>? ?? {};
                    final imageUrl = bannerData['image']?.toString() ?? '';
                    final title = bannerData['title']?.toString() ?? '';
                    final subtitle = bannerData['subtitle']?.toString() ?? '';

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color(0xFF1A1A2E),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Dark background behind image
                            Container(color: const Color(0xFF1A1A2E)),
                            // Image with proper error handling
                            imageUrl.isNotEmpty
                                ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.medium,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: const Color(0xFF1A1A2E),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: const Color(0xFF6366F1),
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: const Color(0xFF1A1A2E),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.image_not_supported, color: Color(0xFF6B6B8B), size: 40),
                                    const SizedBox(height: 8),
                                    Text(
                                      title.isNotEmpty ? title : 'Banner',
                                      style: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            )
                                : Container(
                              color: const Color(0xFF1A1A2E),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.image_not_supported, color: Color(0xFF6B6B8B), size: 40),
                                  const SizedBox(height: 8),
                                  Text(
                                    title.isNotEmpty ? title : 'No Image',
                                    style: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            // Gradient overlay for text readability
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withAlpha(230),
                                    Colors.black.withAlpha(100),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            // Banner text content
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    subtitle,
                                    style: const TextStyle(
                                      color: Color(0xFFBBBBBB),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                AnimatedSmoothIndicator(
                  activeIndex: _bannerIndex,
                  count: banners.length,
                  effect: const WormEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    activeDotColor: Color(0xFF6366F1),
                    dotColor: Color(0xFF6B6B8B),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryChips() {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategory == index;
          final category = _categories[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = index;
                _selectedCategoryName = category['name'];
              });
              if (category['name'] != 'All') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CategoryProductsScreen(category: category['name']),
                  ),
                );
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(colors: [category['color'], category['color'].withAlpha(200)])
                    : null,
                color: isSelected ? null : const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? Colors.transparent : const Color(0xFF2A2A3E),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    category['icon'],
                    color: isSelected ? Colors.white : category['color'],
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category['name'],
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFFBBBBBB),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF6366F1), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: () {},
            child: const Text('See All', style: TextStyle(color: Color(0xFF6366F1))),
          ),
        ],
      ),
    );
  }

  Widget _buildProductSliverGrid({bool isFeatured = false, bool isTrending = false}) {
    Stream<QuerySnapshot> stream;
    if (isFeatured) {
      stream = _db.getFeaturedProducts();
    } else if (isTrending) {
      stream = _db.getTrendingProducts();
    } else {
      stream = _selectedCategoryName == 'All' ? _db.getProducts() : _db.getProductsByCategory(_selectedCategoryName);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmerSliverGrid();
        }

        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text('Error: \${snapshot.error}', style: const TextStyle(color: Colors.red)),
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('No products found', style: TextStyle(color: Color(0xFF6B6B8B))),
              ),
            ),
          );
        }

        final products = snapshot.data!.docs;
        if (products.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('No products found', style: TextStyle(color: Color(0xFF6B6B8B))),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildProductCard(products[index]),
              childCount: products.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductCard(DocumentSnapshot product) {
    final data = product.data() as Map<String, dynamic>? ?? {};
    final price = (data['price'] ?? 0).toDouble();
    final originalPrice = (data['originalPrice'] ?? price).toDouble();
    final discount = originalPrice > price ? ((originalPrice - price) / originalPrice * 100).toInt() : 0;
    final rating = (data['rating'] ?? 0).toString();
    final reviewCount = (data['reviewCount'] ?? 0).toString();
    final imageUrl = data['image'] ?? '';
    final productName = data['name'] ?? 'Product';
    final category = data['category'] ?? 'General';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailsScreen(productId: product.id)),
      ),
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
              Container(
                height: 120,
                width: double.infinity,
                color: const Color(0xFF1A1A2E),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(color: const Color(0xFF1A1A2E)),
                    Image.network(
                      imageUrl,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
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
                            '\$discount% OFF',
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
                        color: _getCategoryColor(category).withAlpha(51),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 10,
                          color: _getCategoryColor(category),
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
                          '₹\${price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF6366F1),
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (originalPrice > price)
                          Text(
                            '₹\${originalPrice.toStringAsFixed(0)}',
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
                          ' (\$reviewCount)',
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

  Widget _buildShimmerBanner() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF1A1A2E),
      highlightColor: const Color(0xFF2A2A3E),
      child: Container(
        height: 180,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildShimmerSliverGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) => Shimmer.fromColors(
            baseColor: const Color(0xFF1A1A2E),
            highlightColor: const Color(0xFF2A2A3E),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          childCount: 4,
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(77), blurRadius: 10)],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF6366F1),
        unselectedItemColor: const Color(0xFF6B6B8B),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Categories'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          if (index == 1) Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesScreen()));
          if (index == 2) Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen()));
          if (index == 3) Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
        },
      ),
    );
  }
}