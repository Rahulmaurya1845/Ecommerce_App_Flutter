import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(title: const Text('Help & Support')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildContactSection(),
            const SizedBox(height: 24),
            _buildFAQSection(),
            const SizedBox(height: 24),
            _buildReportIssueButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How can we help you?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Find answers to common questions or contact our support team',
            style: TextStyle(color: Colors.white.withAlpha(204), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Contact Us', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildContactTile(
          Icons.email_outlined,
          'Email Support',
          'support@luxestore.com',
          Colors.blue,
              () => _launchEmail('support@luxestore.com'),
        ),
        _buildContactTile(
          Icons.phone_outlined,
          'Call Us',
          '+91 1800-123-4567',
          Colors.green,
              () => _launchPhone('+9118001234567'),
        ),
        _buildContactTile(
          Icons.chat_bubble_outline,
          'Live Chat',
          'Available 24/7',
          Colors.orange,
              () => Fluttertoast.showToast(msg: 'Live chat coming soon!'),
        ),
      ],
    );
  }

  Widget _buildContactTile(IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildFAQSection() {
    final faqs = [
      {
        'question': 'How do I track my order?',
        'answer': 'You can track your order in the "My Orders" section. Click on any order to see real-time tracking updates.',
      },
      {
        'question': 'What is the return policy?',
        'answer': 'We offer a 7-day return policy for all products. Items must be in original condition with tags attached.',
      },
      {
        'question': 'How do I cancel my order?',
        'answer': 'You can cancel your order from the "My Orders" section within 24 hours of placing it.',
      },
      {
        'question': 'What payment methods are accepted?',
        'answer': 'We accept Credit/Debit cards, UPI, Net Banking, and Cash on Delivery.',
      },
      {
        'question': 'How long does delivery take?',
        'answer': 'Standard delivery takes 3-5 business days. Express delivery is available for select locations.',
      },
      {
        'question': 'Is Cash on Delivery available?',
        'answer': 'Yes, COD is available for orders below 5000. A small fee may apply.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Frequently Asked Questions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...faqs.map((faq) => _buildFAQItem(faq['question']!, faq['answer']!)),
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      iconColor: const Color(0xFF6366F1),
      collapsedIconColor: Colors.grey,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            answer,
            style: TextStyle(color: Colors.grey.shade400, height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildReportIssueButton() {
    return ElevatedButton.icon(
      onPressed: () => _showReportDialog(),
      icon: const Icon(Icons.report_problem_outlined),
      label: const Text('Report an Issue'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.withAlpha(26),
        foregroundColor: Colors.red,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
    );
  }

  void _showReportDialog() {
    final issueController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Report an Issue'),
        content: TextField(
          controller: issueController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Describe your issue...',
            filled: true,
            fillColor: const Color(0xFF0F0F0F),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
            onPressed: () {
              Fluttertoast.showToast(msg: 'Issue reported! We will get back to you soon.');
              Navigator.pop(ctx);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri.parse('mailto:' + email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Fluttertoast.showToast(msg: 'Could not open email app');
    }
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri.parse('tel:' + phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Fluttertoast.showToast(msg: 'Could not open phone app');
    }
  }
}