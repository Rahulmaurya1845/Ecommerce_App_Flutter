import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AdminAddProductScreen extends StatefulWidget {
  final String? productId;
  final Map<String, dynamic>? productData;

  const AdminAddProductScreen({super.key, this.productId, this.productData});

  @override
  State<AdminAddProductScreen> createState() => _AdminAddProductScreenState();
}

class _AdminAddProductScreenState extends State<AdminAddProductScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _originalPriceController;
  late TextEditingController _stockController;
  late TextEditingController _imageController;
  late TextEditingController _categoryController;
  late TextEditingController _ratingController;
  late TextEditingController _reviewCountController;

  bool _isActive = true;
  bool _isLoading = false;
  bool get _isEditing => widget.productId != null;

  @override
  void initState() {
    super.initState();
    final data = widget.productData;
    _nameController = TextEditingController(text: data?['name'] ?? '');
    _descriptionController = TextEditingController(text: data?['description'] ?? '');
    _priceController = TextEditingController(text: data?['price']?.toString() ?? '');
    _originalPriceController = TextEditingController(text: data?['originalPrice']?.toString() ?? '');
    _stockController = TextEditingController(text: data?['stock']?.toString() ?? '');
    _imageController = TextEditingController(text: data?['image'] ?? '');
    _categoryController = TextEditingController(text: data?['category'] ?? '');
    _ratingController = TextEditingController(text: data?['rating']?.toString() ?? '0');
    _reviewCountController = TextEditingController(text: data?['reviewCount']?.toString() ?? '0');
    if (data != null) _isActive = data['isActive'] ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _stockController.dispose();
    _imageController.dispose();
    _categoryController.dispose();
    _ratingController.dispose();
    _reviewCountController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final productData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'originalPrice': double.parse(_originalPriceController.text.trim()),
        'stock': int.parse(_stockController.text.trim()),
        'image': _imageController.text.trim(),
        'category': _categoryController.text.trim(),
        'rating': double.parse(_ratingController.text.trim()),
        'reviewCount': int.parse(_reviewCountController.text.trim()),
        'isActive': _isActive,
        'updatedAt': DateTime.now(),
      };

      if (_isEditing) {
        await _firestore.collection('Products').doc(widget.productId).update(productData);
        Fluttertoast.showToast(msg: 'Product updated!', backgroundColor: Colors.green);
      } else {
        productData['createdAt'] = DateTime.now();
        await _firestore.collection('Products').add(productData);
        Fluttertoast.showToast(msg: 'Product added!', backgroundColor: Colors.green);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: $e', backgroundColor: Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Product' : 'Add Product'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('Product Name', _nameController, Icons.label, required: true),
              const SizedBox(height: 16),
              _buildTextField('Description', _descriptionController, Icons.description, maxLines: 3),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField('Price (Rs.)', _priceController, Icons.currency_rupee, keyboardType: TextInputType.number, required: true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField('Original Price', _originalPriceController, Icons.currency_rupee, keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField('Stock', _stockController, Icons.inventory, keyboardType: TextInputType.number, required: true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField('Category', _categoryController, Icons.category, required: true)),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField('Image URL', _imageController, Icons.image, required: true),
              const SizedBox(height: 16),
              if (_imageController.text.isNotEmpty)
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(_imageController.text),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField('Rating (0-5)', _ratingController, Icons.star, keyboardType: TextInputType.number)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField('Review Count', _reviewCountController, Icons.reviews, keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Active', style: TextStyle(color: Colors.white)),
                subtitle: Text('Show this product in store', style: TextStyle(color: Colors.grey.shade500)),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
                activeColor: const Color(0xFF6366F1),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    _isEditing ? 'Update Product' : 'Add Product',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller,
      IconData icon, {
        int maxLines = 1,
        TextInputType keyboardType = TextInputType.text,
        bool required = false,
      }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      validator: required
          ? (value) {
        if (value == null || value.trim().isEmpty) {
          return 'This field is required';
        }
        return null;
      }
          : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade400),
        prefixIcon: Icon(icon, color: Colors.grey.shade500),
        filled: true,
        fillColor: const Color(0xFF1A1A2E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6366F1)),
        ),
      ),
    );
  }
}