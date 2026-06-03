import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../service/cart_provider.dart';
import '../service/address_provider.dart';
import '../service/payment_service.dart';
import 'addresses_screen.dart';
import 'orders_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPayment = 'card';
  bool _isProcessing = false;
  late PaymentService _paymentService;

  @override
  void initState() {
    super.initState();
    _paymentService = PaymentService();
    _paymentService.onPaymentSuccess = (orderId) {
      _onPaymentSuccess(orderId);
    };
    _paymentService.onPaymentError = (error) {
      setState(() => _isProcessing = false);
      Fluttertoast.showToast(msg: 'Payment failed: $error', backgroundColor: Colors.red);
    };

    Provider.of<AddressProvider>(context, listen: false).fetchAddresses();
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }

  void _onPaymentSuccess(String orderId) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    await cartProvider.clearCart();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const OrdersScreen()),
            (route) => route.isFirst,
      );
      Fluttertoast.showToast(
        msg: 'Order placed successfully!',
        backgroundColor: Colors.green,
        gravity: ToastGravity.CENTER,
      );
    }
    setState(() => _isProcessing = false);
  }

  Future<void> _placeOrder() async {
    setState(() => _isProcessing = true);

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final addressProvider = Provider.of<AddressProvider>(context, listen: false);

    if (addressProvider.selectedAddress == null) {
      Fluttertoast.showToast(msg: 'Please select a delivery address');
      setState(() => _isProcessing = false);
      return;
    }

    if (cartProvider.items.isEmpty) {
      Fluttertoast.showToast(msg: 'Cart is empty');
      setState(() => _isProcessing = false);
      return;
    }

    String paymentMethod;
    switch (_selectedPayment) {
      case 'card':
        paymentMethod = 'Credit/Debit Card';
        break;
      case 'upi':
        paymentMethod = 'UPI';
        break;
      case 'netbanking':
        paymentMethod = 'Net Banking';
        break;
      case 'cod':
        paymentMethod = 'Cash on Delivery';
        break;
      default:
        paymentMethod = 'Online Payment';
    }

    String? orderId;

    if (_selectedPayment == 'cod') {
      // COD - use placeOrder directly
      orderId = await _paymentService.placeOrder(
        cartItems: cartProvider.items,
        totalAmount: cartProvider.finalAmount,
        address: addressProvider.selectedAddress,
        paymentMethod: paymentMethod,
      );
    } else {
      // ALL other methods - simulate payment (NO RAZORPAY)
      orderId = await _paymentService.simulatePaymentAndPlaceOrder(
        cartItems: cartProvider.items,
        totalAmount: cartProvider.finalAmount,
        address: addressProvider.selectedAddress,
        paymentMethod: paymentMethod,
      );
    }

    if (orderId != null && mounted) {
      await cartProvider.clearCart();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const OrdersScreen()),
            (route) => route.isFirst,
      );
      Fluttertoast.showToast(
        msg: 'Order placed! Payment: $paymentMethod',
        backgroundColor: Colors.green,
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_LONG,
      );
    }

    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final addressProvider = Provider.of<AddressProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(title: const Text('Checkout')),
      body: _isProcessing
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF6366F1)),
            SizedBox(height: 20),
            Text('Processing your order...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Delivery Address'),
            _buildAddressCard(addressProvider),
            const SizedBox(height: 24),
            _buildSectionTitle('Order Summary'),
            _buildOrderSummary(cartProvider),
            const SizedBox(height: 24),
            _buildSectionTitle('Payment Method'),
            _buildPaymentMethods(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: _buildPlaceOrderButton(cartProvider),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildAddressCard(AddressProvider addressProvider) {
    if (addressProvider.addresses.isEmpty) {
      return GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressesScreen())),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF6366F1), style: BorderStyle.solid),
          ),
          child: const Row(
            children: [
              Icon(Icons.add_location_alt, color: Color(0xFF6366F1)),
              SizedBox(width: 12),
              Text('Add Delivery Address', style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.w600)),
              Spacer(),
              Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF6366F1)),
            ],
          ),
        ),
      );
    }

    final address = addressProvider.selectedAddress ?? addressProvider.addresses.first;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (address.isDefault)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(51),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('DEFAULT', style: TextStyle(color: Colors.green, fontSize: 10)),
                ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressesScreen())),
                child: const Text('Change', style: TextStyle(color: Color(0xFF6366F1))),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(address.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
          const SizedBox(height: 4),
          Text(address.phone, style: TextStyle(color: Colors.grey.shade400)),
          const SizedBox(height: 8),
          Text(
            '${address.address}, ${address.city}, ${address.state} - ${address.pincode}',
            style: TextStyle(color: Colors.grey.shade400, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          ...cartProvider.items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    '${item.name} x${item.quantity}',
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ],
            ),
          )),
          const Divider(color: Colors.grey, height: 24),
          _buildSummaryRow('Subtotal', cartProvider.totalAmount),
          _buildSummaryRow('Discount', -cartProvider.discount, isDiscount: true),
          _buildSummaryRow('Delivery', cartProvider.deliveryCharge),
          const Divider(color: Colors.grey, height: 24),
          _buildSummaryRow('Total Amount', cartProvider.finalAmount, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isDiscount = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? Colors.green : (isTotal ? Colors.white : Colors.grey.shade400),
            ),
          ),
          Text(
            '\$${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isDiscount ? Colors.green : (isTotal ? const Color(0xFF6366F1) : Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    final methods = [
      {'id': 'card', 'name': 'Credit/Debit Card (Simulated)', 'icon': Icons.credit_card, 'color': Colors.blue},
      {'id': 'upi', 'name': 'UPI - Google Pay, PhonePe (Simulated)', 'icon': Icons.account_balance_wallet, 'color': Colors.purple},
      {'id': 'netbanking', 'name': 'Net Banking (Simulated)', 'icon': Icons.account_balance, 'color': Colors.orange},
      {'id': 'cod', 'name': 'Cash on Delivery', 'icon': Icons.money, 'color': Colors.green},
    ];

    return Column(
      children: methods.map((method) {
        final isSelected = _selectedPayment == method['id'];
        return GestureDetector(
          onTap: () => setState(() => _selectedPayment = method['id'] as String),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? const Color(0xFF6366F1) : Colors.grey.shade800,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
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
                const SizedBox(width: 16),
                Icon(method['icon'] as IconData, color: isSelected ? const Color(0xFF6366F1) : Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    method['name'] as String,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.grey.shade400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlaceOrderButton(CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(77), blurRadius: 10)],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total:', style: TextStyle(color: Colors.grey.shade400)),
                    Text(
                      '\$${cartProvider.finalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: _placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Place Order', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}