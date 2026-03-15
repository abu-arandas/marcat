// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bootstrap5/flutter_bootstrap5.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'core/constants/supabase_constants.dart';
import 'core/constants/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/initial_binding.dart';
import 'controllers/locale_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: SupabaseConstants.url,
    anonKey: SupabaseConstants.anonKey,
  );

  runApp(const MarcatApp());
}

class MarcatApp extends StatelessWidget {
  const MarcatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterBootstrap5(
      builder: (context) => GetBuilder<LocaleController>(
        builder: (localeCtrl) => GetMaterialApp(
          title: 'Marcat',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          themeMode: ThemeMode.light,

          // ── Localisation ────────────────────────────────────────────────
          locale: localeCtrl.locale,
          fallbackLocale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
            Locale('ar'), // Arabic (RTL)
          ],

          // ── Routing & DI ────────────────────────────────────────────────
          initialBinding: InitialBinding(),
          initialRoute: AppRoutes.home,
          getPages: AppPages.pages,
        ),
      ),
    );
  }
}
