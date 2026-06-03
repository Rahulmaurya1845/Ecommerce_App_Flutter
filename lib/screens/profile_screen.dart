// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import '../service/database.dart';
// import 'addresses_screen.dart';
// import 'orders_screen.dart';
// import 'wishlist_screen.dart';
// import 'notifications_screen.dart';
// import 'help_support_screen.dart';
// import 'payment_methods_screen.dart';
// import 'coupons_screen.dart';
// import 'login.dart';
//
// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;
//     final db = DatabaseMethods();
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF0F0F0F),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               _buildProfileHeader(user),
//               _buildStatsSection(db),
//               _buildMenuSection(context),
//               _buildSupportSection(context),
//               const SizedBox(height: 30),
//               _buildLogoutButton(context),
//               const SizedBox(height: 30),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildProfileHeader(User? user) {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
//       ),
//       child: Column(
//         children: [
//           CircleAvatar(
//             radius: 50,
//             backgroundColor: Colors.white.withAlpha(51),
//             backgroundImage: user?.photoURL != null
//                 ? CachedNetworkImageProvider(user!.photoURL!)
//                 : null,
//             child: user?.photoURL == null
//                 ? const Icon(Icons.person, size: 50, color: Colors.white)
//                 : null,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             user?.displayName ?? 'User',
//             style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             user?.email ?? 'No email',
//             style: TextStyle(fontSize: 14, color: Colors.white.withAlpha(204)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStatsSection(DatabaseMethods db) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: const Color(0xFF1A1A2E),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _buildStatItem(db, Icons.shopping_bag, 'Orders', db.getUserOrderCount()),
//           _buildDivider(),
//           _buildStatItem(db, Icons.favorite, 'Wishlist', db.getUserWishlistCount()),
//           _buildDivider(),
//           _buildStatItem(db, Icons.star, 'Reviews', db.getUserReviewCount()),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStatItem(DatabaseMethods db, IconData icon, String label, Stream<int> stream) {
//     return StreamBuilder<int>(
//       stream: stream,
//       builder: (context, snapshot) {
//         final count = snapshot.data ?? 0;
//         return Column(
//           children: [
//             Icon(icon, color: const Color(0xFF6366F1), size: 28),
//             const SizedBox(height: 8),
//             Text(
//               '$count',
//               style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 4),
//             Text(label, style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
//           ],
//         );
//       },
//     );
//   }
//
//   Widget _buildDivider() {
//     return Container(height: 40, width: 1, color: Colors.grey.shade800);
//   }
//
//   Widget _buildMenuSection(BuildContext context) {
//     final menuItems = [
//       {
//         'icon': Icons.shopping_bag_outlined,
//         'title': 'My Orders',
//         'subtitle': 'View order history',
//         'route': const OrdersScreen(),
//         'badge': null,
//       },
//       {
//         'icon': Icons.favorite_border,
//         'title': 'Wishlist',
//         'subtitle': 'Saved items',
//         'route': const WishlistScreen(),
//         'badge': null,
//       },
//       {
//         'icon': Icons.location_on_outlined,
//         'title': 'Addresses',
//         'subtitle': 'Manage delivery addresses',
//         'route': const AddressesScreen(),
//         'badge': null,
//       },
//       {
//         'icon': Icons.notifications_outlined,
//         'title': 'Notifications',
//         'subtitle': 'Notification preferences',
//         'route': const NotificationsScreen(),
//         'badge': DatabaseMethods().getUnreadNotificationCount(),
//       },
//       {
//         'icon': Icons.payment_outlined,
//         'title': 'Payment Methods',
//         'subtitle': 'Manage payment options',
//         'route': const PaymentMethodsScreen(),
//         'badge': null,
//       },
//       {
//         'icon': Icons.local_offer_outlined,
//         'title': 'Coupons',
//         'subtitle': 'Available coupons',
//         'route': const CouponsScreen(),
//         'badge': null,
//       },
//     ];
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 12),
//           ...menuItems.map((item) => _buildMenuTile(context, item)),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMenuTile(BuildContext context, Map<String, dynamic> item) {
//     final badgeStream = item['badge'] as Stream<int>?;
//
//     return ListTile(
//       leading: Container(
//         padding: const EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           color: const Color(0xFF6366F1).withAlpha(26),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Icon(item['icon'] as IconData, color: const Color(0xFF6366F1)),
//       ),
//       title: Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
//       subtitle: Text(item['subtitle'] as String, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
//       trailing: badgeStream != null
//           ? StreamBuilder<int>(
//         stream: badgeStream,
//         builder: (context, snapshot) {
//           final count = snapshot.data ?? 0;
//           return Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               if (count > 0)
//                 Container(
//                   margin: const EdgeInsets.only(right: 8),
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                   decoration: BoxDecoration(
//                     color: Colors.red,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Text(
//                     '$count',
//                     style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
//             ],
//           );
//         },
//       )
//           : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => item['route'] as Widget),
//         );
//       },
//     );
//   }
//
//   Widget _buildSupportSection(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(height: 20),
//           const Text('Support', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 12),
//           ListTile(
//             leading: Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: Colors.orange.withAlpha(26),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: const Icon(Icons.help_outline, color: Colors.orange),
//             ),
//             title: const Text('Help & Support', style: TextStyle(fontWeight: FontWeight.w600)),
//             subtitle: Text('FAQs, contact us', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
//             trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
//             onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen())),
//           ),
//           ListTile(
//             leading: Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: Colors.blue.withAlpha(26),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: const Icon(Icons.privacy_tip_outlined, color: Colors.blue),
//             ),
//             title: const Text('Privacy Policy', style: TextStyle(fontWeight: FontWeight.w600)),
//             subtitle: Text('Terms and conditions', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
//             trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
//             onTap: () => Fluttertoast.showToast(msg: 'Coming soon!'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildLogoutButton(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: ElevatedButton.icon(
//         onPressed: () => _showLogoutDialog(context),
//         icon: const Icon(Icons.logout, color: Colors.red),
//         label: const Text('Logout', style: TextStyle(color: Colors.red, fontSize: 16)),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.red.withAlpha(26),
//           foregroundColor: Colors.red,
//           minimumSize: const Size(double.infinity, 54),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//           elevation: 0,
//         ),
//       ),
//     );
//   }
//
//   void _showLogoutDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: const Color(0xFF1A1A2E),
//         title: const Text('Logout?'),
//         content: const Text('Are you sure you want to logout?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             onPressed: () async {
//               await FirebaseAuth.instance.signOut();
//               if (context.mounted) {
//                 Navigator.pushAndRemoveUntil(
//                   context,
//                   MaterialPageRoute(builder: (_) => Login()),
//                       (route) => false,
//                 );
//               }
//             },
//             child: const Text('Logout'),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../service/database.dart';
import 'addresses_screen.dart';
import 'orders_screen.dart';
import 'wishlist_screen.dart';
import 'notifications_screen.dart';
import 'help_support_screen.dart';
import 'payment_methods_screen.dart';
import 'coupons_screen.dart';
import 'login.dart';
import '../admin/admin_dashboard.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DatabaseMethods _db = DatabaseMethods();
  bool _isAdmin = false;
  bool _isLoadingAdmin = true;

  @override
  void initState() {
    super.initState();
    _checkAdmin();
  }

  Future<void> _checkAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      setState(() {
        _isAdmin = false;
        _isLoadingAdmin = false;
      });
      return;
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('User')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('No user document found for email: ${user.email}');
        setState(() {
          _isAdmin = false;
          _isLoadingAdmin = false;
        });
        return;
      }

      final data = querySnapshot.docs.first.data();
      print('User data: $data');
      setState(() {
        _isAdmin = data['isAdmin'] == true;
        _isLoadingAdmin = false;
      });
      print('Is Admin: $_isAdmin');
    } catch (e) {
      print('Admin check error: $e');
      setState(() {
        _isAdmin = false;
        _isLoadingAdmin = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (_isLoadingAdmin) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F0F0F),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF6366F1)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileHeader(user),
              _buildStatsSection(),
              _buildMenuSection(context),
              if (_isAdmin) _buildAdminSection(context),
              _buildSupportSection(context),
              const SizedBox(height: 30),
              _buildLogoutButton(context),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Admin',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.purple.withAlpha(26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.admin_panel_settings, color: Colors.purple),
            ),
            title: const Text(
              'Admin Dashboard',
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
            ),
            subtitle: Text(
              'Manage products, orders & users',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminDashboard()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(User? user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white.withAlpha(51),
            backgroundImage: user?.photoURL != null
                ? CachedNetworkImageProvider(user!.photoURL!)
                : null,
            child: user?.photoURL == null
                ? const Icon(Icons.person, size: 50, color: Colors.white)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            user?.displayName ?? 'User',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? 'No email',
            style: TextStyle(fontSize: 14, color: Colors.white.withAlpha(204)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.shopping_bag, 'Orders', _db.getUserOrderCount()),
          _buildDivider(),
          _buildStatItem(Icons.favorite, 'Wishlist', _db.getUserWishlistCount()),
          _buildDivider(),
          _buildStatItem(Icons.star, 'Reviews', _db.getUserReviewCount()),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, Stream<int> stream) {
    return StreamBuilder<int>(
      stream: stream,
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return Column(
          children: [
            Icon(icon, color: const Color(0xFF6366F1), size: 28),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
          ],
        );
      },
    );
  }

  Widget _buildDivider() {
    return Container(height: 40, width: 1, color: Colors.grey.shade800);
  }

  Widget _buildMenuSection(BuildContext context) {
    final menuItems = [
      {
        'icon': Icons.shopping_bag_outlined,
        'title': 'My Orders',
        'subtitle': 'View order history',
        'route': const OrdersScreen(),
        'badge': null,
      },
      {
        'icon': Icons.favorite_border,
        'title': 'Wishlist',
        'subtitle': 'Saved items',
        'route': const WishlistScreen(),
        'badge': null,
      },
      {
        'icon': Icons.location_on_outlined,
        'title': 'Addresses',
        'subtitle': 'Manage delivery addresses',
        'route': const AddressesScreen(),
        'badge': null,
      },
      {
        'icon': Icons.notifications_outlined,
        'title': 'Notifications',
        'subtitle': 'Notification preferences',
        'route': const NotificationsScreen(),
        'badge': _db.getUnreadNotificationCount(),
      },
      {
        'icon': Icons.payment_outlined,
        'title': 'Payment Methods',
        'subtitle': 'Manage payment options',
        'route': const PaymentMethodsScreen(),
        'badge': null,
      },
      {
        'icon': Icons.local_offer_outlined,
        'title': 'Coupons',
        'subtitle': 'Available coupons',
        'route': const CouponsScreen(),
        'badge': null,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          ...menuItems.map((item) => _buildMenuTile(context, item)),
        ],
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context, Map<String, dynamic> item) {
    final badgeStream = item['badge'] as Stream<int>?;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF6366F1).withAlpha(26),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(item['icon'] as IconData, color: const Color(0xFF6366F1)),
      ),
      title: Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
      subtitle: Text(item['subtitle'] as String, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
      trailing: badgeStream != null
          ? StreamBuilder<int>(
        stream: badgeStream,
        builder: (context, snapshot) {
          final count = snapshot.data ?? 0;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (count > 0)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          );
        },
      )
          : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => item['route'] as Widget),
        );
      },
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text('Support', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withAlpha(26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.help_outline, color: Colors.orange),
            ),
            title: const Text('Help & Support', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
            subtitle: Text('FAQs, contact us', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen())),
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.privacy_tip_outlined, color: Colors.blue),
            ),
            title: const Text('Privacy Policy', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
            subtitle: Text('Terms and conditions', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            onTap: () => Fluttertoast.showToast(msg: 'Coming soon!'),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutDialog(context),
        icon: const Icon(Icons.logout, color: Colors.red),
        label: const Text('Logout', style: TextStyle(color: Colors.red, fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.withAlpha(26),
          foregroundColor: Colors.red,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Logout?', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to logout?', style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => Login()),
                      (route) => false,
                );
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}