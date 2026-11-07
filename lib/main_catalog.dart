import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/catalog_theme.dart';
import 'firebase_options.dart';
import 'models/product_model.dart';
import 'views/home_catalog/home_screen.dart';
import 'views/product_cart/cart_summary_sheet.dart';
import 'views/product_cart/product_detail_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: CatalogApp()));
}

class CatalogApp extends StatelessWidget {
  const CatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CoffeeCraft',
      debugShowCheckedModeBanner: false,
      theme: buildCatalogTheme(),
      darkTheme: buildCatalogTheme(Brightness.dark),
      home: Builder(
        builder: (context) => HomeScreen(
          onOpenProduct: (ProductModel product) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ProductDetailScreen(product: product),
              ),
            );
          },
          onOpenCart: () {
            showModalBottomSheet<void>(
              context: context,
              builder: (_) => const CartSummarySheet(),
            );
          },
        ),
      ),
    );
  }
}
