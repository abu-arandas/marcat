// lib/main.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bootstrap5/flutter_bootstrap5.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/constants/supabase_constants.dart';
import 'core/constants/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/initial_binding.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env in debug mode only — production values are injected via CI.
  if (kDebugMode) {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      debugPrint('[main] .env not found — ensure it exists for local dev.');
    }
  }

  await Supabase.initialize(
    url: SupabaseConstants.url,
    anonKey: SupabaseConstants.anonKey,
  );

  runApp(const MarcatApp());
}

// ─────────────────────────────────────────────────────────────────────────────
// MarcatApp
// ─────────────────────────────────────────────────────────────────────────────

class MarcatApp extends StatelessWidget {
  const MarcatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterBootstrap5(
      builder: (context) => GetMaterialApp(
        title: 'Marcat',
        debugShowCheckedModeBanner: false,
        // ── Theme ──────────────────────────────────────────────────────────
        theme: AppTheme.light,
        themeMode: ThemeMode.light,
        // ── Routing ────────────────────────────────────────────────────────
        initialBinding: InitialBinding(),
        initialRoute: AppRoutes.home,
        getPages: AppPages.pages,
      ),
    );
  }
}
