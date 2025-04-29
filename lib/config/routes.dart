import 'exports.dart';

class Routes {
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String products = '/products';

  static Map<String, Widget Function(BuildContext)> routes =
      <String, WidgetBuilder>{
    home: (context) => HomeScreen(),
    login: (context) => LoginScreen(),
    register: (context) => RegisterScreen(),
    products: (context) => ProductListScreen(),
  };
}
