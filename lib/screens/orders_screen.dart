
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../service/database.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final DatabaseMethods _db = DatabaseMethods();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==================== ADDED: Tab filter ====================
  String _selectedFilter = 'All'; // All, Active, Cancelled, Delivered

  final List<String> _filters = ['All', 'Active', 'Cancelled', 'Delivered'];
  // ===========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text('My Orders'),
        actions: [
          // ==================== ADDED: Filter dropdown ====================
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onSelected: (value) {
              setState(() => _selectedFilter = value);
            },
            itemBuilder: (context) => _filters.map((filter) {
              return PopupMenuItem(
                value: filter,
                child: Row(
                  children: [
                    Icon(
                      filter == _selectedFilter ? Icons.check_circle : Icons.circle_outlined,
                      color: filter == _selectedFilter ? const Color(0xFF6366F1) : Colors.grey,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(filter, style: const TextStyle(color: Colors.white)),
                  ],
                ),
              );
            }).toList(),
            color: const Color(0xFF1A1A2E),
          ),
          // ==============================================================
        ],
      ),
      body: StreamBuilder<User?>(
        stream: _auth.authStateChanges(),
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6366F1)),
            );
          }

          final user = authSnapshot.data;
          if (user == null) {
            return _buildAuthRequiredState();
          }

          return StreamBuilder<QuerySnapshot>(
            stream: _db.getOrders(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF6366F1)),
                );
              }

              if (snapshot.hasError) {
                final error = snapshot.error.toString();
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 60, color: Colors.red.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading orders',
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          error,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => setState(() {}),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data == null) {
                return _buildEmptyState();
              }

              final allOrders = snapshot.data!.docs;
              if (allOrders.isEmpty) {
                return _buildEmptyState();
              }

              // Sort orders locally by orderDate descending (newest first)
              allOrders.sort((a, b) {
                final aData = a.data() as Map<String, dynamic>?;
                final bData = b.data() as Map<String, dynamic>?;
                final aDate = aData?['orderDate'] as Timestamp?;
                final bDate = bData?['orderDate'] as Timestamp?;

                if (aDate == null && bDate == null) return 0;
                if (aDate == null) return 1;
                if (bDate == null) return -1;
                return bDate.compareTo(aDate); // Descending
              });

              // ==================== ADDED: Filter orders by status ====================
              final orders = _filterOrders(allOrders);
              // ========================================================================

              if (orders.isEmpty) {
                return _buildEmptyFilterState(_selectedFilter);
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                itemBuilder: (context, index) => _buildOrderCard(context, orders[index]),
              );
            },
          );
        },
      ),
    );
  }

  // ==================== ADDED: Filter logic ====================
  List<DocumentSnapshot> _filterOrders(List<DocumentSnapshot> allOrders) {
    if (_selectedFilter == 'All') return allOrders;

    return allOrders.where((order) {
      final data = order.data() as Map<String, dynamic>? ?? {};
      final status = (data['orderStatus'] ?? '').toString().toLowerCase();

      switch (_selectedFilter) {
        case 'Active':
          return status != 'cancelled' && status != 'delivered';
        case 'Cancelled':
          return status == 'cancelled';
        case 'Delivered':
          return status == 'delivered';
        default:
          return true;
      }
    }).toList();
  }
  // ===========================================================

  // ==================== ADDED: Empty state for filter ====================
  Widget _buildEmptyFilterState(String filter) {
    IconData icon;
    String title;
    String subtitle;

    switch (filter) {
      case 'Active':
        icon = Icons.pending_actions;
        title = 'No active orders';
        subtitle = 'You have no pending or processing orders';
        break;
      case 'Cancelled':
        icon = Icons.cancel_outlined;
        title = 'No cancelled orders';
        subtitle = 'You have not cancelled any orders yet';
        break;
      case 'Delivered':
        icon = Icons.check_circle_outline;
        title = 'No delivered orders';
        subtitle = 'Your orders are still on the way';
        break;
      default:
        icon = Icons.shopping_bag_outlined;
        title = 'No orders yet';
        subtitle = 'Start shopping to see your orders here';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.shade700),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(fontSize: 20, color: Colors.grey.shade400, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
  // =====================================================================

  Widget _buildAuthRequiredState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_circle_outlined, size: 80, color: Colors.grey.shade700),
          const SizedBox(height: 20),
          Text(
            'Please Login',
            style: TextStyle(fontSize: 20, color: Colors.grey.shade400, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Login to view your orders',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Go to Login'),
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
          Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey.shade700),
          const SizedBox(height: 20),
          Text(
            'No orders yet',
            style: TextStyle(fontSize: 20, color: Colors.grey.shade400, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Start shopping to see your orders here',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/home'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Start Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext ctx, DocumentSnapshot order) {
    final data = order.data() as Map<String, dynamic>? ?? {};
    final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
    final status = data['orderStatus'] ?? 'Processing';
    final orderDate = data['orderDate'] as Timestamp?;
    final totalAmount = (data['totalAmount'] ?? 0).toDouble();
    final orderId = data['orderId'] ?? order.id;

    Color statusColor;
    IconData statusIcon;
    switch (status.toString().toLowerCase()) {
      case 'delivered':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'shipped':
        statusColor = Colors.blue;
        statusIcon = Icons.local_shipping;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(26),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(statusIcon, color: statusColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #' + orderId.substring(0, orderId.length > 8 ? 8 : orderId.length),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        orderDate != null
                            ? DateFormat('dd MMM yyyy, hh:mm a').format(orderDate.toDate())
                            : 'Date not available',
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.toString(),
                    style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          ...items.take(2).map((item) {
            final itemQty = item['quantity'] ?? 1;
            final itemPrice = (item['price'] ?? 0).toDouble();
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: item['image'] ?? '',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: Colors.grey.shade800),
                  errorWidget: (_, __, ___) => Container(
                    color: Colors.grey.shade800,
                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
                ),
              ),
              title: Text(
                item['name'] ?? 'Product',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              subtitle: Text(
                'Qty: ' + itemQty.toString(),
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
              trailing: Text(
                '\$' + (itemPrice * itemQty).toStringAsFixed(2),
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
              ),
            );
          }),
          if (items.length > 2)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '+' + (items.length - 2).toString() + ' more items',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ),
          const Divider(color: Colors.grey, height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Amount', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                    Text(
                      '\$' + totalAmount.toStringAsFixed(2),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // ==================== FIXED: Cancel button logic ====================
                    // Show cancel button for orders that are NOT cancelled or delivered
                    if (status.toString().toLowerCase() != 'cancelled' &&
                        status.toString().toLowerCase() != 'delivered')
                      OutlinedButton(
                        onPressed: () => _showCancelDialog(ctx, order.id, data),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Cancel'),
                      ),
                    // ===================================================================
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => _showOrderDetails(ctx, order),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Details'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== FIXED: Cancel dialog with proper handling ====================
  void _showCancelDialog(BuildContext ctx, String orderId, Map<String, dynamic> orderData) {
    showDialog(
      context: ctx,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Cancel Order?', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to cancel this order? This action cannot be undone.', style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('No', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await DatabaseMethods().cancelOrder(orderId);
                Fluttertoast.showToast(
                  msg: 'Order cancelled successfully',
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                );
              } catch (e) {
                Fluttertoast.showToast(
                  msg: 'Error: $e',
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                );
              }
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
  // ===================================================================================

  void _showOrderDetails(BuildContext ctx, DocumentSnapshot order) {
    final data = order.data() as Map<String, dynamic>? ?? {};
    final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
    final trackingUpdates = List<Map<String, dynamic>>.from(data['trackingUpdates'] ?? []);
    final deliveryAddress = data['deliveryAddress'] as Map<String, dynamic>?;

    showModalBottomSheet(
      context: ctx,
      backgroundColor: const Color(0xFF1A1A2E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade700,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Order Details', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 20),
                if (trackingUpdates.isNotEmpty) ...[
                  const Text('Tracking', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 12),
                  ...trackingUpdates.asMap().entries.map((entry) {
                    final isLast = entry.key == trackingUpdates.length - 1;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: isLast ? const Color(0xFF6366F1) : Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            if (!isLast)
                              Container(width: 2, height: 40, color: Colors.grey.shade700),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.value['status'] ?? '',
                                style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                              ),
                              Text(
                                entry.value['location'] ?? '',
                                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 20),
                ],
                if (deliveryAddress != null) ...[
                  const Text('Delivery Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F0F0F),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(deliveryAddress['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        Text(deliveryAddress['phone'] ?? '', style: TextStyle(color: Colors.grey.shade400)),
                        const SizedBox(height: 4),
                        Text(deliveryAddress['address'] ?? '', style: TextStyle(color: Colors.grey.shade400)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                const Text('Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 10),
                ...items.map((item) {
                  final itemQty = item['quantity'] ?? 1;
                  final itemPrice = (item['price'] ?? 0).toDouble();
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: item['image'] ?? '',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: Colors.grey.shade800),
                      ),
                    ),
                    title: Text(item['name'] ?? '', style: const TextStyle(color: Colors.white)),
                    subtitle: Text('Qty: ' + itemQty.toString(), style: TextStyle(color: Colors.grey.shade400)),
                    trailing: Text('\$' + (itemPrice * itemQty).toStringAsFixed(2), style: const TextStyle(color: Colors.white)),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}