import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadBannersScreen extends StatelessWidget {
  const UploadBannersScreen({super.key});

  // 8 UNIQUE BANNER IMAGES with titles - ALL RELIABLE IMAGES
  final List<Map<String, dynamic>> banners = const [
    {
      "title": "Big Summer Sale",
      "image": "https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=800&h=400&fit=crop",
      "subtitle": "Up to 50% OFF on all products"
    },
    // {
    //   "title": "New Electronics Arrivals",
    //   "image": "https://images.unsplash.com/photo-1498049860654-af1a5c5668ba?w=800&h=400&fit=crop",
    //   "subtitle": "Latest gadgets at best prices"
    // },
    {
      "title": "Fashion Week Special",
      "image": "https://images.unsplash.com/photo-1445205170230-053b83016050?w=800&h=400&fit=crop",
      "subtitle": "Trendy styles for everyone"
    },
    {
      "title": "Home Essentials",
      "image": "https://images.unsplash.com/photo-1556228453-efd6c1ff04f6?w=800&h=400&fit=crop",
      "subtitle": "Make your home beautiful"
    },
    {
      "title": "Beauty & Care",
      "image": "https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=800&h=400&fit=crop",
      "subtitle": "Premium beauty products"
    },
    {
      "title": "Sports Mega Deal",
      "image": "https://images.unsplash.com/photo-1517649763962-0c623066013b?w=800&h=400&fit=crop",
      "subtitle": "Gear up for fitness"
    },
    // {
    //   "title": "Electronics Super Sale",
    //   "image": "https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=800&h=400&fit=crop",
    //   "subtitle": "Best deals on laptops & phones"
    // },
    // {
    //   "title": "Sports Fitness Gear",
    //   "image": "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&h=400&fit=crop",
    //   "subtitle": "Top quality fitness equipment"
    // },
  ];

  Future<void> _uploadBanners(BuildContext context) async {
    final firestore = FirebaseFirestore.instance;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Clear existing banners first
      final existing = await firestore.collection('Banners').get();
      for (var doc in existing.docs) {
        await doc.reference.delete();
      }

      // Upload all banners with batch for better performance
      WriteBatch batch = firestore.batch();
      int count = 0;

      for (var banner in banners) {
        DocumentReference ref = firestore.collection('Banners').doc();
        batch.set(ref, {
          ...banner,
          'createdAt': FieldValue.serverTimestamp(),
        });
        count++;

        // Firestore batch limit is 500
        if (count % 400 == 0) {
          await batch.commit();
          batch = firestore.batch();
        }
      }

      // Commit remaining
      await batch.commit();

      Navigator.pop(context); // Close loading

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('8 Banners uploaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: \$e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
          'Upload Banners',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.image,
              size: 80,
              color: Color(0xFF6366F1),
            ),
            const SizedBox(height: 20),
            const Text(
              'Upload Banners',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '8 unique banner images for home screen slider',
              style: TextStyle(
                color: const Color(0xFFBBBBBB),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: banners.map((banner) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF6366F1),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        banner['title'],
                        style: const TextStyle(
                          color: Color(0xFFBBBBBB),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _uploadBanners(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE94560),
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'UPLOAD ALL BANNERS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Go Back',
                style: TextStyle(color: Color(0xFF6B6B8B)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}