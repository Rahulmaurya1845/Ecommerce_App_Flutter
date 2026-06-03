import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../service/database.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final DatabaseMethods _db = DatabaseMethods();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F0F0F),
        appBar: AppBar(title: const Text('Notifications')),
        body: _buildLoginRequired(),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          StreamBuilder<int>(
            stream: _db.getUnreadNotificationCount(),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              if (count == 0) return const SizedBox.shrink();
              return Center(
                child: Container(
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
              );
            },
          ),
          TextButton(
            onPressed: () => _markAllRead(context),
            child: const Text('Mark all read', style: TextStyle(color: Color(0xFF6366F1))),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db.getNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6366F1)),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorState('Error: ${snapshot.error}');
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          final notifications = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) => _buildNotificationCard(notifications[index]),
          );
        },
      ),
    );
  }

  Widget _buildLoginRequired() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.login_outlined, size: 80, color: Colors.grey.shade700),
          const SizedBox(height: 20),
          Text(
            'Please login first',
            style: TextStyle(fontSize: 20, color: Colors.grey.shade400, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Login to see your notifications',
            style: TextStyle(color: Colors.grey.shade600),
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
          Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey.shade700),
          const SizedBox(height: 20),
          Text(
            'No notifications yet',
            style: TextStyle(fontSize: 20, color: Colors.grey.shade400, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'We will notify you about offers, orders, and updates',
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => setState(() {}),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(DocumentSnapshot notification) {
    final data = notification.data() as Map<String, dynamic>? ?? {};
    final isRead = data['read'] ?? false;
    final type = data['type'] ?? 'general';
    final timestamp = data['timestamp'] as Timestamp?;
    final title = data['title'] ?? 'Notification';
    final body = data['body'] ?? '';
    final orderId = data['orderId'] ?? '';

    IconData icon;
    Color iconColor;
    switch (type.toString()) {
      case 'order':
        icon = Icons.shopping_bag;
        iconColor = Colors.blue;
        break;
      case 'offer':
        icon = Icons.local_offer;
        iconColor = Colors.orange;
        break;
      case 'delivery':
        icon = Icons.local_shipping;
        iconColor = Colors.green;
        break;
      case 'payment':
        icon = Icons.payment;
        iconColor = Colors.purple;
        break;
      case 'promo':
        icon = Icons.celebration;
        iconColor = Colors.pink;
        break;
      default:
        icon = Icons.notifications;
        iconColor = const Color(0xFF6366F1);
    }

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.red.shade900,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _deleteNotification(notification.id),
      child: GestureDetector(
        onTap: () {
          if (!isRead) {
            _db.markNotificationRead(notification.id);
          }
          // Navigate based on type
          if (orderId.isNotEmpty && type == 'order') {
            Navigator.pushNamed(context, '/order-details', arguments: orderId);
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isRead ? Colors.transparent : const Color(0xFF6366F1).withAlpha(77),
              width: isRead ? 0 : 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(51),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF6366F1),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      body,
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          _getTimeAgo(timestamp),
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                        ),
                        if (orderId.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withAlpha(51),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Order #${orderId.substring(0, orderId.length > 6 ? 6 : orderId.length)}',
                              style: const TextStyle(
                                color: Color(0xFF6366F1),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
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

  String _getTimeAgo(Timestamp? timestamp) {
    if (timestamp == null) return 'Just now';
    final dateTime = timestamp.toDate();
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _markAllRead(BuildContext context) async {
    try {
      await _db.markAllNotificationsRead();
      Fluttertoast.showToast(
        msg: 'All notifications marked as read',
        backgroundColor: const Color(0xFF6366F1),
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error: $e',
        backgroundColor: Colors.red,
      );
    }
  }

  void _deleteNotification(String notificationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Notifications')
          .doc(notificationId)
          .delete();
      Fluttertoast.showToast(msg: 'Notification deleted');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error deleting: $e');
    }
  }
}