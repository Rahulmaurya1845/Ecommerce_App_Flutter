import 'package:flutter/material.dart';
import 'category_products_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  final List<Map<String, dynamic>> categories = const [
    {'name': 'Electronics', 'icon': Icons.devices, 'color': Colors.blue, 'image': 'https://images.unsplash.com/photo-1498049860654-af1a5c5668ba?w=400&h=400&fit=crop'},
    {'name': 'Fashion', 'icon': Icons.checkroom, 'color': Colors.pink, 'image': 'https://images.unsplash.com/photo-1445205170230-053b83016050?w=400&h=400&fit=crop'},
    {'name': 'Home', 'icon': Icons.home, 'color': Colors.orange, 'image': 'https://images.unsplash.com/photo-1556228453-efd6c1ff04f6?w=400&h=400&fit=crop'},
    {'name': 'Beauty', 'icon': Icons.spa, 'color': Colors.purple, 'image': 'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=400&h=400&fit=crop'},
    {'name': 'Sports', 'icon': Icons.sports, 'color': Colors.green, 'image': 'https://images.unsplash.com/photo-1517649763962-0c623066013b?w=400&h=400&fit=crop'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Categories',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CategoryProductsScreen(category: category['name']),
              ),
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFF1A1A2E),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Dark background
                    Container(color: const Color(0xFF1A1A2E)),
                    // Category image
                    Image.network(
                      category['image'],
                      fit: BoxFit.cover,
                      opacity: const AlwaysStoppedAnimation(0.4),
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: category['color'].withAlpha(51),
                      ),
                    ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            category['color'].withAlpha(200),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(30),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              category['icon'],
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category['name'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap to explore',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(180),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(30),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}