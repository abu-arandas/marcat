import 'config/exports.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => FlutterBootstrap5(
      builder: (ctx) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Marcat',
            theme: AppTheme.theme,
            routes: Routes.routes,
            initialRoute: Routes.home,
          ));
}
