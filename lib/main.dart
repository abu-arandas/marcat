import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bootstrap5/flutter_bootstrap5.dart';
import 'package:get/get.dart';

import 'config/theme.dart';

import 'controllers/auth.dart';
import 'controllers/product.dart';
import 'controllers/cart.dart';
import 'controllers/order.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => FlutterBootstrap5(
        builder: (context) => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Marcat',
          theme: AppTheme.theme,
          initialBinding: BindingsBuilder(() {
            Get.put(AuthController());
            Get.put(ProductController());
            Get.put(CartController());
            Get.put(OrderController());
          }),
        ),
      );
}
