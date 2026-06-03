import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../service/payment_service.dart';
import '../service/cart_provider.dart';
import '../service/address_provider.dart';
import 'package:provider/provider.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  String _selectedMethod = 'card';
  final List<Map<String, dynamic>> _savedCards = [];
  bool _showAddCard = false;
  bool _isProcessing = false;

  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  // Get display name for payment method
  String _getPaymentMethodName(String method) {
    switch (method) {
      case 'card':
        return 'Credit/Debit Card';
      case 'upi':
        return 'UPI';
      case 'netbanking':
        return 'Net Banking';
      case 'cod':
        return 'Cash on Delivery';
      default:
        return method.toUpperCase();
    }
  }

  // Get color for payment method
  Color _getPaymentColor(String method) {
    switch (method) {
      case 'card':
        return Colors.blue.shade700;
      case 'upi':
        return Colors.purple.shade700;
      case 'netbanking':
        return Colors.orange.shade700;
      case 'cod':
        return Colors.green.shade700;
      default:
        return const Color(0xFF6366F1);
    }
  }

  // Get icon for payment method
  IconData _getPaymentIcon(String method) {
    switch (method) {
      case 'card':
        return Icons.credit_card;
      case 'upi':
        return Icons.account_balance_wallet;
      case 'netbanking':
        return Icons.account_balance;
      case 'cod':
        return Icons.money;
      default:
        return Icons.payment;
    }
  }

  // ALL methods use simulation - NO RAZORPAY
  void _processPayment() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final addressProvider = Provider.of<AddressProvider>(context, listen: false);

    if (cartProvider.items.isEmpty) {
      Fluttertoast.showToast(msg: 'Cart is empty');
      return;
    }

    if (addressProvider.selectedAddress == null) {
      Fluttertoast.showToast(msg: 'Please select a delivery address');
      return;
    }

    setState(() => _isProcessing = true);

    // Show processing dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Color(0xFF6366F1)),
            const SizedBox(height: 16),
            Text(
              'Processing ${_getPaymentMethodName(_selectedMethod)}...',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ],
        ),
      ),
    );

    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 2));

    // Close processing dialog
    if (mounted) Navigator.pop(context);

    final paymentService = PaymentService();
    String? orderId;

    if (_selectedMethod == 'cod') {
      // COD - no payment simulation needed
      orderId = await paymentService.placeOrder(
        cartItems: cartProvider.items,
        totalAmount: cartProvider.totalAmount,
        address: addressProvider.selectedAddress,
        paymentMethod: 'Cash on Delivery',
      );
    } else {
      // ALL other methods - simulate payment (NO RAZORPAY)
      orderId = await paymentService.simulatePaymentAndPlaceOrder(
        cartItems: cartProvider.items,
        totalAmount: cartProvider.totalAmount,
        address: addressProvider.selectedAddress,
        paymentMethod: _getPaymentMethodName(_selectedMethod),
      );
    }

    setState(() => _isProcessing = false);

    if (orderId != null && mounted) {
      _showOrderSuccessDialog(orderId);
    }
  }

  void _showOrderSuccessDialog(String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('Order Placed!', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your order #${orderId.substring(0, orderId.length > 8 ? 8 : orderId.length)} has been placed successfully.',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F0F),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Payment Method: ',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      Text(
                        _getPaymentMethodName(_selectedMethod),
                        style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text(
                        'Status: ',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      Text(
                        _selectedMethod == 'cod' ? 'Pending (COD)' : 'Completed (Simulated)',
                        style: TextStyle(
                          color: _selectedMethod == 'cod' ? Colors.orange : Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamedAndRemoveUntil(context, '/orders', (route) => false);
            },
            child: const Text('View Orders', style: TextStyle(color: Color(0xFF6366F1))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
            },
            child: const Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(title: const Text('Payment Methods')),
      body: _showAddCard ? _buildAddCardForm() : _buildPaymentMethodsList(),
    );
  }

  Widget _buildPaymentMethodsList() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Payment Method',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'All payments are simulated for testing - No real money deducted',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
          const SizedBox(height: 20),
          _buildPaymentCard(
            'card',
            'Credit / Debit Card',
            'Visa, Mastercard, RuPay, Amex (Simulated)',
            Icons.credit_card,
            Colors.blue,
          ),
          _buildPaymentCard(
            'upi',
            'UPI',
            'Google Pay, PhonePe, Paytm, BHIM (Simulated)',
            Icons.account_balance_wallet,
            Colors.purple,
          ),
          _buildPaymentCard(
            'netbanking',
            'Net Banking',
            'SBI, HDFC, ICICI, Axis, All Banks (Simulated)',
            Icons.account_balance,
            Colors.orange,
          ),
          _buildPaymentCard(
            'cod',
            'Cash on Delivery',
            'Pay when you receive',
            Icons.money,
            Colors.green,
          ),
          const SizedBox(height: 24),
          if (_savedCards.isNotEmpty) ...[
            const Text(
              'Saved Cards',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            ..._savedCards.map((card) => _buildSavedCardItem(card)),
            const SizedBox(height: 16),
          ],
          const Spacer(),
          if (_isProcessing)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircularProgressIndicator(color: Color(0xFF6366F1)),
                    SizedBox(height: 12),
                    Text('Processing...', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            )
          else ...[
            _buildMainActionButton(),
            const SizedBox(height: 12),
            _buildAddNewButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildMainActionButton() {
    String buttonText;
    Color color = _getPaymentColor(_selectedMethod);

    if (_selectedMethod == 'cod') {
      buttonText = 'Place Order (Cash on Delivery)';
    } else {
      buttonText = 'Pay with ${_getPaymentMethodName(_selectedMethod)} (Simulated)';
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _processPayment,
        icon: Icon(_getPaymentIcon(_selectedMethod), size: 24),
        label: Text(
          buttonText,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildPaymentCard(
      String id,
      String title,
      String subtitle,
      IconData icon,
      Color color,
      ) {
    final isSelected = _selectedMethod == id;

    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF6366F1) : Colors.grey.shade800,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: const Color(0xFF6366F1).withAlpha(40),
              blurRadius: 8,
              spreadRadius: 1,
            )
          ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF6366F1) : Colors.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Container(
                margin: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF6366F1),
                ),
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedCardItem(Map<String, dynamic> card) {
    final cardNumber = card['number'] ?? '0000';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.credit_card, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card['holder'] ?? 'Card',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  '**** **** **** $cardNumber',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white70),
            onPressed: () {
              setState(() {
                _savedCards.remove(card);
              });
              Fluttertoast.showToast(msg: 'Card removed');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddCardForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => setState(() => _showAddCard = false),
              ),
              const Text(
                'Add New Card',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildTextField('Card Number', _cardNumberController, Icons.credit_card, maxLength: 19),
          const SizedBox(height: 16),
          _buildTextField('Card Holder Name', _cardHolderController, Icons.person),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField('MM/YY', _expiryController, Icons.calendar_today, maxLength: 5)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField('CVV', _cvvController, Icons.lock, maxLength: 3, obscure: true)),
            ],
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _saveCard,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Save Card', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon,
      {int? maxLength, bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      maxLength: maxLength,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade400),
        prefixIcon: Icon(icon, color: Colors.grey.shade500),
        filled: true,
        fillColor: const Color(0xFF1A1A2E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6366F1)),
        ),
        counterText: '',
      ),
    );
  }

  void _saveCard() {
    if (_cardNumberController.text.isEmpty || _cardHolderController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Please fill all fields');
      return;
    }

    final cleanedNumber = _cardNumberController.text.replaceAll(' ', '');
    final last4 = cleanedNumber.length >= 4
        ? cleanedNumber.substring(cleanedNumber.length - 4)
        : '0000';

    setState(() {
      _savedCards.add({
        'number': last4,
        'holder': _cardHolderController.text,
        'expiry': _expiryController.text,
      });
      _showAddCard = false;
      _cardNumberController.clear();
      _cardHolderController.clear();
      _expiryController.clear();
      _cvvController.clear();
    });

    Fluttertoast.showToast(
      msg: 'Card saved successfully',
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  Widget _buildAddNewButton() {
    return ElevatedButton.icon(
      onPressed: () => setState(() => _showAddCard = true),
      icon: const Icon(Icons.add),
      label: const Text('Add New Payment Method'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6366F1),
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}