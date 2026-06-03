import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Processing', 'Shipped', 'Delivered', 'Cancelled'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text('Manage Orders'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onSelected: (value) => setState(() => _selectedFilter = value),
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
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('Orders').orderBy('orderDate', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)));
          }

          var orders = snapshot.data!.docs;

          if (_selectedFilter != 'All') {
            orders = orders.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final status = (data['orderStatus'] ?? '').toString();
              return status.toLowerCase() == _selectedFilter.toLowerCase();
            }).toList();
          }

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_shipping_outlined, size: 80, color: Colors.grey.shade700),
                  const SizedBox(height: 16),
                  Text('No orders found', style: TextStyle(color: Colors.grey.shade400, fontSize: 18)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) => _buildOrderCard(orders[index]),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(DocumentSnapshot order) {
    final data = order.data() as Map<String, dynamic>;
    final orderId = data['orderId'] ?? order.id;
    final status = data['orderStatus'] ?? 'Processing';
    final orderDate = data['orderDate'] as Timestamp?;
    final totalAmount = (data['totalAmount'] ?? 0).toDouble();
    final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
    final userId = data['userId'] ?? 'Unknown';
    final paymentMethod = data['paymentMethod'] ?? 'Unknown';

    Color statusColor;
    switch (status.toString().toLowerCase()) {
      case 'delivered':
        statusColor = Colors.green;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      case 'shipped':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${orderId.substring(0, orderId.length > 8 ? 8 : orderId.length)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
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
          const SizedBox(height: 8),
          Text(
            orderDate != null
                ? DateFormat('dd MMM yyyy, hh:mm a').format(orderDate.toDate())
                : 'Date not available',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text('User: $userId', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
          Text('Payment: $paymentMethod', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
          const SizedBox(height: 12),
          Text('Items:', style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          ...items.take(3).map((item) => Text(
            '- ${item['name']} x${item['quantity']}',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          )),
          if (items.length > 3)
            Text('+${items.length - 3} more items', style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
          const Divider(color: Colors.grey, height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: Rs.${totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF6366F1)),
              ),
              if (status.toString().toLowerCase() != 'cancelled' &&
                  status.toString().toLowerCase() != 'delivered')
                ElevatedButton(
                  onPressed: () => _showUpdateStatusDialog(order.id, status.toString()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Update Status', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showUpdateStatusDialog(String orderId, String currentStatus) {
    final statuses = ['Processing', 'Shipped', 'Out for Delivery', 'Delivered'];
    String selectedStatus = currentStatus;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          title: const Text('Update Order Status', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: statuses.map((status) {
              return RadioListTile<String>(
                title: Text(status, style: const TextStyle(color: Colors.white)),
                value: status,
                groupValue: selectedStatus,
                onChanged: (value) => setState(() => selectedStatus = value!),
                activeColor: const Color(0xFF6366F1),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await _firestore.collection('Orders').doc(orderId).update({
                    'orderStatus': selectedStatus,
                    'trackingUpdates': FieldValue.arrayUnion([{
                      'status': selectedStatus,
                      'time': Timestamp.now(),
                      'location': 'Updated by Admin',
                    }]),
                  });

                  // Send notification to user
                  final orderDoc = await _firestore.collection('Orders').doc(orderId).get();
                  final orderData = orderDoc.data() as Map<String, dynamic>;
                  final userId = orderData['userId'];

                  if (userId != null) {
                    await _firestore.collection('Notifications').add({
                      'userId': userId,
                      'title': 'Order Update',
                      'body': 'Your order status has been updated to: $selectedStatus',
                      'type': 'order',
                      'orderId': orderId,
                      'timestamp': DateTime.now(),
                      'read': false,
                    });
                  }

                  Fluttertoast.showToast(
                    msg: 'Status updated to $selectedStatus',
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
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}