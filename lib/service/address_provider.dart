import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Address {
  final String id;
  final String name;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final bool isDefault;

  Address({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    this.isDefault = false,
  });

  factory Address.fromMap(Map<String, dynamic> map, String id) {
    return Address(
      id: id,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      pincode: map['pincode'] ?? '',
      isDefault: map['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'isDefault': isDefault,
    };
  }
}

class AddressProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Address> _addresses = [];
  Address? _selectedAddress;
  bool _isLoading = false;

  List<Address> get addresses => _addresses;
  Address? get selectedAddress => _selectedAddress;
  bool get isLoading => _isLoading;

  String get _userId => _auth.currentUser?.uid ?? '';

  Future<void> fetchAddresses() async {
    if (_userId.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('User')
          .doc(_userId)
          .collection('Addresses')
          .get();

      _addresses = snapshot.docs
          .map((doc) => Address.fromMap(doc.data(), doc.id))
          .toList();

      final defaultAddress = _addresses.where((a) => a.isDefault).toList();
      if (defaultAddress.isNotEmpty) {
        _selectedAddress = defaultAddress.first;
      } else if (_addresses.isNotEmpty) {
        _selectedAddress = _addresses.first;
      }
    } catch (e) {
      _addresses = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addAddress(Address address) async {
    if (_userId.isEmpty) return;

    try {
      await _firestore
          .collection('User')
          .doc(_userId)
          .collection('Addresses')
          .add(address.toMap());

      await fetchAddresses();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateAddress(String id, Address address) async {
    if (_userId.isEmpty) return;

    try {
      await _firestore
          .collection('User')
          .doc(_userId)
          .collection('Addresses')
          .doc(id)
          .update(address.toMap());

      await fetchAddresses();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteAddress(String id) async {
    if (_userId.isEmpty) return;

    try {
      await _firestore
          .collection('User')
          .doc(_userId)
          .collection('Addresses')
          .doc(id)
          .delete();

      await fetchAddresses();
    } catch (e) {
      // Handle error
    }
  }

  void selectAddress(Address address) {
    _selectedAddress = address;
    notifyListeners();
  }
}