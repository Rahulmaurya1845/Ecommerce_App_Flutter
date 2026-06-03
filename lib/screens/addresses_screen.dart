import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../service/address_provider.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<AddressProvider>(context, listen: false).fetchAddresses();
  }

  @override
  Widget build(BuildContext context) {
    final addressProvider = Provider.of<AddressProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text('My Addresses'),
        actions: [
          TextButton.icon(
            onPressed: () => _showAddAddressDialog(context),
            icon: const Icon(Icons.add, color: Color(0xFF6366F1)),
            label: const Text('Add New', style: TextStyle(color: Color(0xFF6366F1))),
          ),
        ],
      ),
      body: addressProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
          : addressProvider.addresses.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: addressProvider.addresses.length,
        itemBuilder: (context, index) => _buildAddressCard(addressProvider, index),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined, size: 80, color: Colors.grey.shade700),
          const SizedBox(height: 20),
          Text(
            'No addresses saved',
            style: TextStyle(fontSize: 20, color: Colors.grey.shade400, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a delivery address to get started',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddAddressDialog(context),
            icon: const Icon(Icons.add_location_alt),
            label: const Text('Add Address'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(AddressProvider provider, int index) {
    final address = provider.addresses[index];
    final isSelected = provider.selectedAddress?.id == address.id;

    return GestureDetector(
      onTap: () => provider.selectAddress(address),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (address.isDefault)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withAlpha(51),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'DEFAULT',
                      style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                const Spacer(),
                if (isSelected)
                  const Icon(Icons.check_circle, color: Color(0xFF6366F1)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              address.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              address.phone,
              style: TextStyle(color: Colors.grey.shade400),
            ),
            const SizedBox(height: 8),
            Text(
              address.address,
              style: TextStyle(color: Colors.grey.shade400, height: 1.5),
            ),
            Text(
              '${address.city}, ${address.state} - ${address.pincode}',
              style: TextStyle(color: Colors.grey.shade400),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showEditAddressDialog(context, address),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6366F1),
                    side: const BorderSide(color: Color(0xFF6366F1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () => _showDeleteDialog(context, provider, address.id),
                  icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                  label: const Text('Delete', style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAddressDialog(BuildContext context) {
    _showAddressDialog(context, null);
  }

  void _showEditAddressDialog(BuildContext context, Address address) {
    _showAddressDialog(context, address);
  }

  void _showAddressDialog(BuildContext context, Address? existingAddress) {
    final nameController = TextEditingController(text: existingAddress?.name ?? '');
    final phoneController = TextEditingController(text: existingAddress?.phone ?? '');
    final addressController = TextEditingController(text: existingAddress?.address ?? '');
    final cityController = TextEditingController(text: existingAddress?.city ?? '');
    final stateController = TextEditingController(text: existingAddress?.state ?? '');
    final pincodeController = TextEditingController(text: existingAddress?.pincode ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(existingAddress == null ? 'Add Address' : 'Edit Address', style: const TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(nameController, 'Full Name', Icons.person),
              _buildTextField(phoneController, 'Phone Number', Icons.phone, keyboardType: TextInputType.phone),
              _buildTextField(addressController, 'Full Address', Icons.home),
              _buildTextField(cityController, 'City', Icons.location_city),
              _buildTextField(stateController, 'State', Icons.map),
              _buildTextField(pincodeController, 'Pincode', Icons.pin_drop, keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  phoneController.text.isEmpty ||
                  addressController.text.isEmpty ||
                  cityController.text.isEmpty ||
                  stateController.text.isEmpty ||
                  pincodeController.text.isEmpty) {
                Fluttertoast.showToast(msg: 'Please fill all required fields');
                return;
              }

              final newAddress = Address(
                id: existingAddress?.id ?? '',
                name: nameController.text,
                phone: phoneController.text,
                address: addressController.text,
                city: cityController.text,
                state: stateController.text,
                pincode: pincodeController.text,
                isDefault: existingAddress?.isDefault ?? false,
              );

              final provider = Provider.of<AddressProvider>(context, listen: false);
              if (existingAddress == null) {
                await provider.addAddress(newAddress);
              } else {
                await provider.updateAddress(existingAddress.id, newAddress);
              }

              Navigator.pop(dialogContext);
            },
            child: Text(existingAddress == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: Icon(icon, color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFF0F0F0F),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, AddressProvider provider, String addressId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Delete Address?', style: TextStyle(color: Colors.white)),
        content: const Text('This action cannot be undone.', style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              provider.deleteAddress(addressId);
              Navigator.pop(dialogContext);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}