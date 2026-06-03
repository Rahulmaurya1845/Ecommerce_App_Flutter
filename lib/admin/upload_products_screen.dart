import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadProductsScreen extends StatelessWidget {
  const UploadProductsScreen({super.key});

  // UNIQUE IMAGES - DECREASED PRICES for better look
  final List<Map<String, dynamic>> products = const [
    // ==================== ELECTRONICS (20) - LOWER PRICES ====================
    {"name": "boAt Airdopes 141", "price": 899, "originalPrice": 2490, "image": "https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=400&h=400&fit=crop", "category": "Electronics", "rating": 4.3, "reviewCount": 128},
    {"name": "OnePlus Nord Buds 2", "price": 1799, "originalPrice": 2999, "image": "https://images.unsplash.com/photo-1606220588913-b3aacb4d2f46?w=400&h=400&fit=crop", "category": "Electronics", "rating": 4.5, "reviewCount": 89},
    {"name": "realme Buds Air 3", "price": 2499, "originalPrice": 3999, "image": "https://images.unsplash.com/photo-1583394838336-acd977736f90?w=400&h=400&fit=crop", "category": "Electronics", "rating": 4.2, "reviewCount": 156},
    {"name": "JBL Tune 760NC", "price": 3499, "originalPrice": 5999, "image": "https://images.unsplash.com/photo-1484704849700-f032a568e944?w=400&h=400&fit=crop", "category": "Electronics", "rating": 4.4, "reviewCount": 203},
    {"name": "Sony WH-CH520", "price": 2999, "originalPrice": 4999, "image": "https://images.unsplash.com/photo-1546435770-a3e426bf472b?w=400&h=400&fit=crop", "category": "Electronics", "rating": 4.6, "reviewCount": 312},
    {"name": "Samsung Galaxy M14", "price": 8499, "originalPrice": 11999, "image": "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400&h=400&fit=crop", "category": "Electronics", "rating": 4.1, "reviewCount": 445},
    {"name": "Redmi 12 5G", "price": 7999, "originalPrice": 10999, "image": "https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=400&h=400&fit=crop", "category": "Electronics", "rating": 4.0, "reviewCount": 378},
    {"name": "realme narzo 60x", "price": 8999, "originalPrice": 11999, "image": "https://images.unsplash.com/photo-1565849904461-04a58ad377e0?w=400&h=400&fit=crop", "category": "Electronics", "rating": 4.2, "reviewCount": 267},
    {"name": "Noise ColorFit Pulse 2", "price": 999, "originalPrice": 1999, "image": "https://images.unsplash.com/photo-1579586337278-3befd40fd17a?w=400&h=400&fit=crop", "category": "Electronics", "rating": 4.1, "reviewCount": 892},
    {"name": "Fire-Boltt Ninja 3", "price": 899, "originalPrice": 1499, "image": "https://images.unsplash.com/photo-1508685096489-7aacd43bd3b1?w=400&h=400&fit=crop", "category": "Electronics", "rating": 4.0, "reviewCount": 567},
    {"name": "HP 15s Laptop", "price": 28999, "originalPrice": 34999, "image": "https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=400&h=400&fit=crop", "category": "Electronics", "rating": 4.4, "reviewCount": 234},
    {"name": "Lenovo IdeaPad Slim 3", "price": 25999, "originalPrice": 32999, "image": "https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=400&h=400&fit=crop", "category": "Electronics", "rating": 4.3, "reviewCount": 189},
    {"name": "Canon EOS 1500D", "price": 24999, "originalPrice": 29999, "image": "https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=400&h=400&fit=crop", "category": "Electronics", "rating": 4.5, "reviewCount": 156},
    {"name": "Logitech B170 Mouse", "price": 399, "originalPrice": 695, "image": "https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400&h=400&fit=crop", "category": "Electronics", "rating": 4.3, "reviewCount": 2341},
    {"name": "Portronics Konnect Cable", "price": 149, "originalPrice": 299, "image": "https://images.unsplash.com/photo-1625772452859-1c03d5bf1133?w=400&h=400&fit=crop", "category": "Electronics", "rating": 4.1, "reviewCount": 876},
    {"name": "SanDisk Ultra 128GB", "price": 499, "originalPrice": 899, "image": "https://images.unsplash.com/photo-1597872252165-4827a235d7bb?w=400&h=400&fit=crop", "category": "Electronics", "rating": 4.4, "reviewCount": 1234},
    {"name": "Mi Power Bank 3i", "price": 999, "originalPrice": 1499, "image": "https://images.unsplash.com/photo-1609592424303-7f1cb2a4d7a6?w=400&h=400&fit=crop", "category": "Electronics", "rating": 4.2, "reviewCount": 3456},
    {"name": "Ambrane 10000mAh", "price": 499, "originalPrice": 899, "image": "https://images.unsplash.com/photo-1615526675159-e248c3021d3f?w=400&h=400&fit=crop", "category": "Electronics", "rating": 4.0, "reviewCount": 2134},
    {"name": "Zebronics Zeb-Juke Speaker", "price": 499, "originalPrice": 799, "image": "https://images.unsplash.com/photo-1545454675-3531b543be5d?w=400&h=400&fit=crop", "category": "Electronics", "rating": 3.9, "reviewCount": 567},
    {"name": "Philips Trimmer BT3211", "price": 999, "originalPrice": 1495, "image": "https://images.unsplash.com/photo-1621607512214-68297480165f?w=400&h=400&fit=crop", "category": "Electronics", "rating": 4.3, "reviewCount": 1890},

    // ==================== FASHION (20) - LOWER PRICES ====================
    {"name": "Puma Running Shoes", "price": 1499, "originalPrice": 2499, "image": "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&h=400&fit=crop", "category": "Fashion", "rating": 4.4, "reviewCount": 234},
    {"name": "Adidas Originals T-Shirt", "price": 999, "originalPrice": 1499, "image": "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&h=400&fit=crop", "category": "Fashion", "rating": 4.5, "reviewCount": 567},
    {"name": "Levi's 511 Slim Fit Jeans", "price": 1499, "originalPrice": 2499, "image": "https://images.unsplash.com/photo-1542272617-08f086302542?w=400&h=400&fit=crop", "category": "Fashion", "rating": 4.3, "reviewCount": 445},
    {"name": "US Polo Assn. Shirt", "price": 1199, "originalPrice": 1999, "image": "https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=400&h=400&fit=crop", "category": "Fashion", "rating": 4.2, "reviewCount": 678},
    {"name": "Ray-Ban Aviator Sunglasses", "price": 2999, "originalPrice": 4999, "image": "https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=400&h=400&fit=crop", "category": "Fashion", "rating": 4.6, "reviewCount": 345},
    {"name": "Fastrack Reflex Watch", "price": 1299, "originalPrice": 1995, "image": "https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400&h=400&fit=crop", "category": "Fashion", "rating": 4.1, "reviewCount": 789},
    {"name": "Wildcraft Backpack", "price": 999, "originalPrice": 1499, "image": "https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400&h=400&fit=crop", "category": "Fashion", "rating": 4.4, "reviewCount": 567},
    {"name": "Skybags Trolley Bag", "price": 1999, "originalPrice": 2999, "image": "https://images.unsplash.com/photo-1565026057447-bc90a3dceb87?w=400&h=400&fit=crop", "category": "Fashion", "rating": 4.3, "reviewCount": 234},
    {"name": "Nike Air Max Shoes", "price": 3499, "originalPrice": 4999, "image": "https://images.unsplash.com/photo-1600185365926-3a2ce3cdb9eb?w=400&h=400&fit=crop", "category": "Fashion", "rating": 4.5, "reviewCount": 890},
    {"name": "Campus Casual Shoes", "price": 699, "originalPrice": 999, "image": "https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=400&h=400&fit=crop", "category": "Fashion", "rating": 4.0, "reviewCount": 1234},
    {"name": "Van Heusen Formal Shirt", "price": 999, "originalPrice": 1499, "image": "https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=400&h=400&fit=crop", "category": "Fashion", "rating": 4.3, "reviewCount": 456},
    {"name": "Peter England Blazer", "price": 2499, "originalPrice": 3999, "image": "https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=400&h=400&fit=crop", "category": "Fashion", "rating": 4.4, "reviewCount": 234},
    {"name": "Bata Formal Shoes", "price": 899, "originalPrice": 1499, "image": "https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=400&h=400&fit=crop", "category": "Fashion", "rating": 4.2, "reviewCount": 678},
    {"name": "Lavie Handbag", "price": 999, "originalPrice": 1499, "image": "https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=400&h=400&fit=crop", "category": "Fashion", "rating": 4.3, "reviewCount": 345},
    {"name": "Caprese Sling Bag", "price": 899, "originalPrice": 1499, "image": "https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=400&h=400&fit=crop", "category": "Fashion", "rating": 4.1, "reviewCount": 567},
    {"name": "Allen Solly Polo T-Shirt", "price": 699, "originalPrice": 999, "image": "https://images.unsplash.com/photo-1625910513413-5fc4e5e6727b?w=400&h=400&fit=crop", "category": "Fashion", "rating": 4.2, "reviewCount": 789},
    {"name": "Wrangler Cargo Pants", "price": 1299, "originalPrice": 1999, "image": "https://images.unsplash.com/photo-1473966968600-fa801b869a1a?w=400&h=400&fit=crop", "category": "Fashion", "rating": 4.0, "reviewCount": 234},
    {"name": "Fossil Leather Wallet", "price": 1499, "originalPrice": 2499, "image": "https://images.unsplash.com/photo-1627123424574-724758594e93?w=400&h=400&fit=crop", "category": "Fashion", "rating": 4.5, "reviewCount": 456},
    {"name": "Titan Raga Watch", "price": 2499, "originalPrice": 3499, "image": "https://images.unsplash.com/photo-1539874754764-5a96559165b0?w=400&h=400&fit=crop", "category": "Fashion", "rating": 4.4, "reviewCount": 567},
    {"name": "Sonata Analog Watch", "price": 699, "originalPrice": 999, "image": "https://images.unsplash.com/photo-1524592094714-0f0654e20314?w=400&h=400&fit=crop", "category": "Fashion", "rating": 4.1, "reviewCount": 890},

    // ==================== HOME (20) - LOWER PRICES ====================
    {"name": "Prestige Pressure Cooker", "price": 1299, "originalPrice": 1999, "image": "https://images.unsplash.com/photo-1584269600519-112d071b35e6?w=400&h=400&fit=crop", "category": "Home", "rating": 4.5, "reviewCount": 2345},
    {"name": "Philips Mixer Grinder", "price": 2499, "originalPrice": 3499, "image": "https://images.unsplash.com/photo-1570222094114-2a01dab5fe9d?w=400&h=400&fit=crop", "category": "Home", "rating": 4.4, "reviewCount": 3456},
    {"name": "Bajaj Induction Cooktop", "price": 1499, "originalPrice": 2499, "image": "https://images.unsplash.com/photo-1556911220-e15b29be8c8f?w=400&h=400&fit=crop", "category": "Home", "rating": 4.2, "reviewCount": 1234},
    {"name": "Havells Air Fryer", "price": 3999, "originalPrice": 5999, "image": "https://images.unsplash.com/photo-1626147116986-4601771470a6?w=400&h=400&fit=crop", "category": "Home", "rating": 4.3, "reviewCount": 567},
    {"name": "Morphy Richards Kettle", "price": 999, "originalPrice": 1499, "image": "https://images.unsplash.com/photo-1544787219-7f47ccb76574?w=400&h=400&fit=crop", "category": "Home", "rating": 4.4, "reviewCount": 890},
    {"name": "Cello Water Bottle Set", "price": 299, "originalPrice": 499, "image": "https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=400&h=400&fit=crop", "category": "Home", "rating": 4.1, "reviewCount": 2341},
    {"name": "Milton Thermosteel Flask", "price": 599, "originalPrice": 899, "image": "https://images.unsplash.com/photo-1610701596007-11502861dcfa?w=400&h=400&fit=crop", "category": "Home", "rating": 4.3, "reviewCount": 1567},
    {"name": "Tupperware Container Set", "price": 499, "originalPrice": 799, "image": "https://images.unsplash.com/photo-1615486511484-92e172cc4fe0?w=400&h=400&fit=crop", "category": "Home", "rating": 4.5, "reviewCount": 3456},
    {"name": "Solimo Cotton Bedsheet", "price": 499, "originalPrice": 799, "image": "https://images.unsplash.com/photo-1631679706909-1844bbd07221?w=400&h=400&fit=crop", "category": "Home", "rating": 4.2, "reviewCount": 1234},
    {"name": "Wakefit Memory Foam Pillow", "price": 399, "originalPrice": 599, "image": "https://images.unsplash.com/photo-1584100936595-c0654b55a2e6?w=400&h=400&fit=crop", "category": "Home", "rating": 4.4, "reviewCount": 5678},
    {"name": "AmazonBasics Towel Set", "price": 499, "originalPrice": 799, "image": "https://images.unsplash.com/photo-1616627547584-bf28cee262db?w=400&h=400&fit=crop", "category": "Home", "rating": 4.1, "reviewCount": 2345},
    {"name": "IKEA Storage Box", "price": 299, "originalPrice": 499, "image": "https://images.unsplash.com/photo-1595428774223-ef52624120d2?w=400&h=400&fit=crop", "category": "Home", "rating": 4.3, "reviewCount": 890},
    {"name": "Godrej Security Safe", "price": 3499, "originalPrice": 4999, "image": "https://images.unsplash.com/photo-1558618666-fcd25c85f82e?w=400&h=400&fit=crop", "category": "Home", "rating": 4.5, "reviewCount": 456},
    {"name": "Eureka Forbes Vacuum", "price": 2499, "originalPrice": 3499, "image": "https://images.unsplash.com/photo-1558317374-067fb5f30001?w=400&h=400&fit=crop", "category": "Home", "rating": 4.2, "reviewCount": 1234},
    {"name": "Kent Water Purifier", "price": 8999, "originalPrice": 11999, "image": "https://images.unsplash.com/photo-1585776245991-cf89dd7fc73a?w=400&h=400&fit=crop", "category": "Home", "rating": 4.4, "reviewCount": 2345},
    {"name": "Lifelong Steam Iron", "price": 499, "originalPrice": 799, "image": "https://images.unsplash.com/photo-1584269600471-2c5bca3956a9?w=400&h=400&fit=crop", "category": "Home", "rating": 4.0, "reviewCount": 3456},
    {"name": "Usha Ceiling Fan", "price": 1499, "originalPrice": 2499, "image": "https://images.unsplash.com/photo-1565814329452-e1efa11c5b89?w=400&h=400&fit=crop", "category": "Home", "rating": 4.3, "reviewCount": 5678},
    {"name": "Orient LED Bulb Pack", "price": 199, "originalPrice": 349, "image": "https://images.unsplash.com/photo-1558618666-fcd25c85f82e?w=400&h=400&fit=crop", "category": "Home", "rating": 4.2, "reviewCount": 8901},
    {"name": "Hindware Bathroom Set", "price": 999, "originalPrice": 1499, "image": "https://images.unsplash.com/photo-1584622050111-993a426fbf0a?w=400&h=400&fit=crop", "category": "Home", "rating": 4.1, "reviewCount": 2345},
    {"name": "Dyson V8 Vacuum", "price": 19999, "originalPrice": 24999, "image": "https://images.unsplash.com/photo-1558317374-067fb5f30001?w=400&h=400&fit=crop", "category": "Home", "rating": 4.6, "reviewCount": 456},

    // ==================== BEAUTY (20) - LOWER PRICES ====================
    {"name": "Lakme CC Cream", "price": 199, "originalPrice": 299, "image": "https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=400&h=400&fit=crop", "category": "Beauty", "rating": 4.3, "reviewCount": 5678},
    {"name": "Maybelline Foundation", "price": 349, "originalPrice": 499, "image": "https://images.unsplash.com/photo-1512496015851-a90fb38ba796?w=400&h=400&fit=crop", "category": "Beauty", "rating": 4.4, "reviewCount": 3456},
    {"name": "L'Oreal Shampoo", "price": 249, "originalPrice": 399, "image": "https://images.unsplash.com/photo-1527799820374-dcf8d9d4a388?w=400&h=400&fit=crop", "category": "Beauty", "rating": 4.5, "reviewCount": 8901},
    {"name": "Dove Body Wash", "price": 199, "originalPrice": 299, "image": "https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=400&h=400&fit=crop", "category": "Beauty", "rating": 4.6, "reviewCount": 12345},
    {"name": "Nivea Moisturizer", "price": 149, "originalPrice": 249, "image": "https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=400&h=400&fit=crop", "category": "Beauty", "rating": 4.4, "reviewCount": 6789},
    {"name": "Garnier Face Wash", "price": 149, "originalPrice": 249, "image": "https://images.unsplash.com/photo-1556228720-195a672e8a03?w=400&h=400&fit=crop", "category": "Beauty", "rating": 4.2, "reviewCount": 4567},
    {"name": "Himalaya Neem Face Pack", "price": 99, "originalPrice": 149, "image": "https://images.unsplash.com/photo-1608248543803-ba4f8c70ae0b?w=400&h=400&fit=crop", "category": "Beauty", "rating": 4.3, "reviewCount": 8901},
    {"name": "Biotique Sunscreen", "price": 199, "originalPrice": 299, "image": "https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=400&h=400&fit=crop", "category": "Beauty", "rating": 4.1, "reviewCount": 2345},
    {"name": "Forest Essentials Serum", "price": 1495, "originalPrice": 1995, "image": "https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=400&h=400&fit=crop", "category": "Beauty", "rating": 4.5, "reviewCount": 567},
    {"name": "Plum Green Tea Toner", "price": 249, "originalPrice": 349, "image": "https://images.unsplash.com/photo-1608248543803-ba4f8c70ae0b?w=400&h=400&fit=crop", "category": "Beauty", "rating": 4.4, "reviewCount": 1234},
    {"name": "Minimalist Vitamin C", "price": 499, "originalPrice": 699, "image": "https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=400&h=400&fit=crop", "category": "Beauty", "rating": 4.3, "reviewCount": 3456},
    {"name": "The Body Shop Body Butter", "price": 695, "originalPrice": 995, "image": "https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=400&h=400&fit=crop", "category": "Beauty", "rating": 4.6, "reviewCount": 2345},
    {"name": "MAC Lipstick Ruby Woo", "price": 1250, "originalPrice": 1550, "image": "https://images.unsplash.com/photo-1586495777744-4413f21062fa?w=400&h=400&fit=crop", "category": "Beauty", "rating": 4.5, "reviewCount": 5678},
    {"name": "Kay Beauty Eyeliner", "price": 349, "originalPrice": 499, "image": "https://images.unsplash.com/photo-1512496015851-a90fb38ba796?w=400&h=400&fit=crop", "category": "Beauty", "rating": 4.2, "reviewCount": 3456},
    {"name": "Sugar Contour De Force", "price": 399, "originalPrice": 599, "image": "https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=400&h=400&fit=crop", "category": "Beauty", "rating": 4.3, "reviewCount": 2345},
    {"name": "Nykaa Nail Enamel", "price": 99, "originalPrice": 149, "image": "https://images.unsplash.com/photo-1604654894610-df63bc536371?w=400&h=400&fit=crop", "category": "Beauty", "rating": 4.1, "reviewCount": 6789},
    {"name": "Beardo Beard Oil", "price": 249, "originalPrice": 349, "image": "https://images.unsplash.com/photo-1621607512214-68297480165f?w=400&h=400&fit=crop", "category": "Beauty", "rating": 4.0, "reviewCount": 4567},
    {"name": "Park Avenue Deo", "price": 149, "originalPrice": 249, "image": "https://images.unsplash.com/photo-1527799820374-dcf8d9d4a388?w=400&h=400&fit=crop", "category": "Beauty", "rating": 4.2, "reviewCount": 8901},
    {"name": "Set Wet Hair Gel", "price": 69, "originalPrice": 99, "image": "https://images.unsplash.com/photo-1527799820374-dcf8d9d4a388?w=400&h=400&fit=crop", "category": "Beauty", "rating": 4.0, "reviewCount": 12345},
    {"name": "Vaseline Lip Care", "price": 35, "originalPrice": 55, "image": "https://images.unsplash.com/photo-1627856014759-2a01dab5fe9d?w=400&h=400&fit=crop", "category": "Beauty", "rating": 4.5, "reviewCount": 23456},

    // ==================== SPORTS (20) - LOWER PRICES ====================
    {"name": "Yonex Badminton Racket", "price": 1499, "originalPrice": 2499, "image": "https://images.unsplash.com/photo-1626224583764-847d8e9d1553?w=400&h=400&fit=crop", "category": "Sports", "rating": 4.5, "reviewCount": 2345},
    {"name": "SG Cricket Bat", "price": 999, "originalPrice": 1499, "image": "https://images.unsplash.com/photo-1531415074968-036ba1b575da?w=400&h=400&fit=crop", "category": "Sports", "rating": 4.4, "reviewCount": 3456},
    {"name": "Nivia Football", "price": 499, "originalPrice": 799, "image": "https://images.unsplash.com/photo-1579952363873-27f3bade9f55?w=400&h=400&fit=crop", "category": "Sports", "rating": 4.3, "reviewCount": 5678},
    {"name": "Strauss Yoga Mat", "price": 349, "originalPrice": 599, "image": "https://images.unsplash.com/photo-1601925260368-ae2f83cf8b7f?w=400&h=400&fit=crop", "category": "Sports", "rating": 4.2, "reviewCount": 8901},
    {"name": "Cosco Basketball", "price": 599, "originalPrice": 899, "image": "https://images.unsplash.com/photo-1519861531473-9200263931a2?w=400&h=400&fit=crop", "category": "Sports", "rating": 4.4, "reviewCount": 2345},
    {"name": "Vector X Gym Gloves", "price": 199, "originalPrice": 349, "image": "https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=400&h=400&fit=crop", "category": "Sports", "rating": 4.1, "reviewCount": 4567},
    {"name": "Boldfit Resistance Band", "price": 249, "originalPrice": 399, "image": "https://images.unsplash.com/photo-1598289431512-b97b0917affc?w=400&h=400&fit=crop", "category": "Sports", "rating": 4.3, "reviewCount": 6789},
    {"name": "Decathlon Trekking Shoes", "price": 1999, "originalPrice": 2999, "image": "https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=400&h=400&fit=crop", "category": "Sports", "rating": 4.5, "reviewCount": 1234},
    {"name": "Lifelong Treadmill", "price": 14999, "originalPrice": 19999, "image": "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400&h=400&fit=crop", "category": "Sports", "rating": 4.2, "reviewCount": 567},
    {"name": "Powermax Exercise Bike", "price": 5999, "originalPrice": 8999, "image": "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=400&h=400&fit=crop", "category": "Sports", "rating": 4.3, "reviewCount": 890},
    {"name": "Sparx Running Shoes", "price": 899, "originalPrice": 1299, "image": "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&h=400&fit=crop", "category": "Sports", "rating": 4.1, "reviewCount": 2345},
    {"name": "Nivia Skipping Rope", "price": 149, "originalPrice": 249, "image": "https://images.unsplash.com/photo-1598289431512-b97b0917affc?w=400&h=400&fit=crop", "category": "Sports", "rating": 4.0, "reviewCount": 5678},
    {"name": "Gymshark Stringer", "price": 999, "originalPrice": 1499, "image": "https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=400&h=400&fit=crop", "category": "Sports", "rating": 4.4, "reviewCount": 1234},
    {"name": "Under Armour Cap", "price": 699, "originalPrice": 999, "image": "https://images.unsplash.com/photo-1588850561407-ed78c282e89b?w=400&h=400&fit=crop", "category": "Sports", "rating": 4.2, "reviewCount": 3456},
    {"name": "Puma Gym Bag", "price": 1299, "originalPrice": 1999, "image": "https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400&h=400&fit=crop", "category": "Sports", "rating": 4.3, "reviewCount": 567},
    {"name": "Wilson Tennis Racket", "price": 2499, "originalPrice": 3499, "image": "https://images.unsplash.com/photo-1626224583764-847d8e9d1553?w=400&h=400&fit=crop", "category": "Sports", "rating": 4.5, "reviewCount": 890},
    {"name": "Speedo Swimming Goggles", "price": 399, "originalPrice": 599, "image": "https://images.unsplash.com/photo-1564859228273-278a27851711?w=400&h=400&fit=crop", "category": "Sports", "rating": 4.3, "reviewCount": 2345},
    {"name": "Strauss Dumbbell Set", "price": 999, "originalPrice": 1499, "image": "https://images.unsplash.com/photo-1638536532686-d610adfc8e5c?w=400&h=400&fit=crop", "category": "Sports", "rating": 4.4, "reviewCount": 4567},
    {"name": "Kore K-PVC 20kg", "price": 1299, "originalPrice": 1999, "image": "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=400&h=400&fit=crop", "category": "Sports", "rating": 4.2, "reviewCount": 6789},
    {"name": "Adidas Football Studs", "price": 1499, "originalPrice": 2499, "image": "https://images.unsplash.com/photo-1579952363873-27f3bade9f55?w=400&h=400&fit=crop", "category": "Sports", "rating": 4.5, "reviewCount": 1234},
  ];

  Future<void> _uploadProducts(BuildContext context) async {
    final firestore = FirebaseFirestore.instance;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Clear existing products first
      final existing = await firestore.collection('Products').get();
      for (var doc in existing.docs) {
        await doc.reference.delete();
      }

      // Upload all 100 products with batch for better performance
      WriteBatch batch = firestore.batch();
      int count = 0;

      for (var product in products) {
        DocumentReference ref = firestore.collection('Products').doc();
        batch.set(ref, {
          ...product,
          'createdAt': FieldValue.serverTimestamp(),
        });
        count++;

        // Firestore batch limit is 500, so commit and start new batch if needed
        if (count % 400 == 0) {
          await batch.commit();
          batch = firestore.batch();
        }
      }

      // Commit remaining
      await batch.commit();

      Navigator.pop(context); // Close loading

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('100 Products uploaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: \$e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_upload,
              size: 80,
              color: Color(0xFF6366F1),
            ),
            const SizedBox(height: 20),
            const Text(
              'Upload Products',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '100 products with unique images & lower prices',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildCategoryCount('Electronics', 20, Colors.blue),
                  _buildCategoryCount('Fashion', 20, Colors.pink),
                  _buildCategoryCount('Home', 20, Colors.orange),
                  _buildCategoryCount('Beauty', 20, Colors.purple),
                  _buildCategoryCount('Sports', 20, Colors.green),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _uploadProducts(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE94560),
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'UPLOAD ALL PRODUCTS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Go Back',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCount(String name, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '\$name: \$count products',
            style: TextStyle(
              color: Colors.grey.shade300,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}