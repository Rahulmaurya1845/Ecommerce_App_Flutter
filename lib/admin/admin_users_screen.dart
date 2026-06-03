
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),
        elevation: 0,
        title: const Text('All Users', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // ==================== FIXED: Use 'User' collection (not 'Users') ====================
      // ==================== FIXED: No orderBy to avoid index error =========================
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('User').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Users stream error: ${snapshot.error}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading users',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6366F1)),
            );
          }

          final users = snapshot.data?.docs ?? [];

          if (users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 80, color: Colors.grey.shade700),
                  const SizedBox(height: 16),
                  Text('No users found', style: TextStyle(color: Colors.grey.shade400, fontSize: 18)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) => _buildUserCard(users[index]),
          );
        },
      ),
    );
  }

  Widget _buildUserCard(DocumentSnapshot user) {
    final data = user.data() as Map<String, dynamic>? ?? {};
    final name = data['name'] ?? data['displayName'] ?? 'Unknown';
    final email = data['email'] ?? 'No Email';
    final phone = data['phone'] ?? 'No Phone';
    final createdAt = data['createdAt'];
    final isAdmin = data['isAdmin'] == true;

    DateTime? joinDate;
    if (createdAt is Timestamp) {
      joinDate = createdAt.toDate();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: isAdmin ? Colors.purple : const Color(0xFF6366F1),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isAdmin)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.purple.withAlpha(26),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'ADMIN',
                          style: TextStyle(color: Colors.purple, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(email, style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                const SizedBox(height: 2),
                Text(phone, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                const SizedBox(height: 4),
                if (joinDate != null)
                  Text(
                    'Joined: ${DateFormat('dd MMM yyyy').format(joinDate)}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}