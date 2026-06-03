
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin_products_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_users_screen.dart';
import 'upload_products_screen.dart';
import 'upload_banners_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isAdmin = false;
  bool _isLoading = true;

  // Cached stats data
  Map<String, dynamic> _statsData = {};
  bool _statsLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAdmin();
  }

  Future<void> _checkAdmin() async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      setState(() {
        _isAdmin = false;
        _isLoading = false;
      });
      return;
    }

    try {
      final querySnapshot = await _firestore
          .collection('User')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('No admin document found for email: ${user.email}');
        setState(() {
          _isAdmin = false;
          _isLoading = false;
        });
        return;
      }

      final data = querySnapshot.docs.first.data();
      final isAdmin = data['isAdmin'] == true;

      setState(() {
        _isAdmin = isAdmin;
        _isLoading = false;
      });

      if (isAdmin) {
        _loadStats();
      }
    } catch (e) {
      print('Admin check error: $e');
      setState(() {
        _isAdmin = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadStats() async {
    try {
      final ordersSnapshot = await _firestore.collection('Orders').get();
      final productsSnapshot = await _firestore.collection('Products').get();
      final usersSnapshot = await _firestore.collection('User').get();

      double totalRevenue = 0;
      for (var doc in ordersSnapshot.docs) {
        final data = doc.data();
        totalRevenue += (data['totalAmount'] ?? 0).toDouble();
      }

      setState(() {
        _statsData = {
          'totalOrders': ordersSnapshot.docs.length,
          'totalProducts': productsSnapshot.docs.length,
          'totalUsers': usersSnapshot.docs.length,
          'totalRevenue': totalRevenue,
        };
        _statsLoading = false;
      });
    } catch (e) {
      print('Stats load error: $e');
      setState(() {
        _statsLoading = false;
      });
    }
  }

  Future<void> _refreshStats() async {
    setState(() => _statsLoading = true);
    await _loadStats();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F0F0F),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF6366F1))),
      );
    }

    if (!_isAdmin) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F0F0F),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F0F0F),
          elevation: 0,
          title: const Text('Access Denied', style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block, size: 80, color: Colors.red.shade400),
              const SizedBox(height: 20),
              const Text(
                'Admin Access Only',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                'You do not have permission to access this area.',
                style: TextStyle(color: Colors.grey.shade400),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                ),
                child: const Text('Go Back'),
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
        title: const Text('Admin Dashboard', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshStats,
            tooltip: 'Refresh Stats',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _auth.signOut(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshStats,
        color: const Color(0xFF6366F1),
        backgroundColor: const Color(0xFF1A1A2E),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatsCards(),
              const SizedBox(height: 24),
              const Text(
                'Quick Actions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              _buildQuickActions(),
              const SizedBox(height: 24),
              // ==================== ADDED: Upload Section ====================
              const Text(
                'Upload Data',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              _buildUploadActions(),
              // ==============================================================
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    if (_statsLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator(color: Color(0xFF6366F1))),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatCard(
          'Total Orders',
          (_statsData['totalOrders'] ?? 0).toString(),
          Icons.shopping_bag,
          Colors.blue,
        ),
        _buildStatCard(
          'Products',
          (_statsData['totalProducts'] ?? 0).toString(),
          Icons.inventory,
          Colors.green,
        ),
        _buildStatCard(
          'Users',
          (_statsData['totalUsers'] ?? 0).toString(),
          Icons.people,
          Colors.orange,
        ),
        _buildStatCard(
          'Revenue',
          'Rs.${(_statsData['totalRevenue'] ?? 0).toStringAsFixed(0)}',
          Icons.currency_rupee,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {
        'title': 'Manage Products',
        'subtitle': 'Add, edit, delete products',
        'icon': Icons.inventory_2,
        'color': Colors.green,
        'screen': const AdminProductsScreen(),
      },
      {
        'title': 'Manage Orders',
        'subtitle': 'View & update order status',
        'icon': Icons.local_shipping,
        'color': Colors.blue,
        'screen': const AdminOrdersScreen(),
      },
      {
        'title': 'View Users',
        'subtitle': 'See all registered users',
        'icon': Icons.people_alt,
        'color': Colors.orange,
        'screen': const AdminUsersScreen(),
      },
    ];

    return Column(
      children: actions.map((action) {
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => action['screen'] as Widget),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (action['color'] as Color).withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(action['icon'] as IconData, color: action['color'] as Color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action['title'] as String,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        action['subtitle'] as String,
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ==================== ADDED: Upload Actions Section ====================
  Widget _buildUploadActions() {
    final uploadActions = [
      {
        'title': 'Upload Products',
        'subtitle': 'Upload 100 demo products to store',
        'icon': Icons.cloud_upload,
        'color': const Color(0xFFE94560),
        'screen': const UploadProductsScreen(),
      },
      {
        'title': 'Upload Banners',
        'subtitle': 'Upload home screen banner images',
        'icon': Icons.image,
        'color': const Color(0xFF6366F1),
        'screen': const UploadBannersScreen(),
      },
    ];

    return Column(
      children: uploadActions.map((action) {
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => action['screen'] as Widget),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: (action['color'] as Color).withAlpha(51),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (action['color'] as Color).withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(action['icon'] as IconData, color: action['color'] as Color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action['title'] as String,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        action['subtitle'] as String,
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
// ========================================================================
}