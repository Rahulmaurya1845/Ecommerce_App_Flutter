import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login.dart';
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/addresses_screen.dart';
import 'screens/payment_methods_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/wishlist_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/help_support_screen.dart';
import 'screens/coupons_screen.dart';
import 'screens/signup.dart';
import 'screens/forgot_password.dart';
import 'screens/search_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/category_products_screen.dart';
import 'screens/product_details_screen.dart';
import 'admin/admin_dashboard.dart';
import 'admin/admin_products_screen.dart';
import 'admin/admin_orders_screen.dart';
import 'admin/admin_users_screen.dart';
import 'admin/admin_add_product_screen.dart';
import 'admin/upload_products_screen.dart';
import 'admin/upload_banners_screen.dart';
import 'service/cart_provider.dart';
import 'service/address_provider.dart';
import 'service/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => CartProvider()),
        ChangeNotifierProvider(create: (ctx) => AddressProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Luxe Store',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF0F0F0F),
          primaryColor: const Color(0xFF6366F1),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF6366F1),
            secondary: Color(0xFF8B5CF6),
            surface: Color(0xFF1A1A2E),
            error: Color(0xFFEF4444),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0F0F0F),
            elevation: 0,
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF1A1A2E),
            selectedItemColor: Color(0xFF6366F1),
            unselectedItemColor: Colors.grey,
          ),
        ),
        routes: {
          '/login': (context) => Login(),
          '/signup': (context) => SignUp(),
          '/forgot_password': (context) => ForgotPassword(),
          '/home': (context) => const HomeScreen(),
          '/cart': (context) => const CartScreen(),
          '/checkout': (context) => const CheckoutScreen(),
          '/orders': (context) => const OrdersScreen(),
          '/addresses': (context) => const AddressesScreen(),
          '/payment_methods': (context) => const PaymentMethodsScreen(),
          '/notifications': (context) => const NotificationsScreen(),
          '/wishlist': (context) => const WishlistScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/help_support': (context) => const HelpSupportScreen(),
          '/coupons': (context) => const CouponsScreen(),
          '/search': (context) => const SearchScreen(),
          '/categories': (context) => const CategoriesScreen(),
          '/admin_dashboard': (context) => const AdminDashboard(),
          '/admin_products': (context) => const AdminProductsScreen(),
          '/admin_orders': (context) => const AdminOrdersScreen(),
          '/admin_users': (context) => const AdminUsersScreen(),
          '/admin_add_product': (context) => const AdminAddProductScreen(),
          '/upload_products': (context) => const UploadProductsScreen(),
          '/upload_banners': (context) => const UploadBannersScreen(),
        },
        home: const SplashScreen(),
      ),
    );
  }
}