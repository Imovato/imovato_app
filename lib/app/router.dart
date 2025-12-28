import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:imovato_app/features/auth/presentation/pages/register_page.dart';
import 'package:imovato_app/features/checkout/presentation/pages/checkout_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/controllers/login_controller.dart';
import '../features/explore/presentation/pages/explore_page.dart';
import '../features/onboarding/presentation/pages/welcome_page.dart';
import '../features/search/domain/property.dart';
import '../features/search/presentation/pages/listings_page.dart';
import '../features/search/presentation/pages/property_details_page.dart';

class Routes {
  static const welcome = '/';
  static const loginMorador = '/login';
  static const alugar = '/alugar';
  static const cadastro = '/cadastro';
  static const buscar = '/buscar';
  static const propertyDetails = '/imovel-detalhes';
  static const checkout = '/checkout';
}

final Map<String, WidgetBuilder> appRoutes = {
  Routes.welcome: (_) => const WelcomePage(),
  Routes.alugar: (_) => const ExplorePage(),
  Routes.buscar: (_) => const ListingsPage(),

};

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  // Proteção de rotas de autenticação
  if (settings.name == Routes.loginMorador || settings.name == Routes.cadastro) {
    return MaterialPageRoute(
      builder: (context) {
        final isLoggedIn = context.read<LoginController>().isLoggedIn;
        if (isLoggedIn) {
          return const ExplorePage();
        }
        return settings.name == Routes.loginMorador ? const LoginPage() : const RegisterPage();
      },
    );
  }

  if (settings.name == Routes.propertyDetails) {
    final prop = settings.arguments as Property;
    return MaterialPageRoute(builder: (_) => PropertyDetailsPage(property: prop));

  }
  if (settings.name == Routes.checkout) {
    final prop = settings.arguments as Property;
    return MaterialPageRoute(builder: (_) => CheckoutPage(property: prop));
  }
  return null;
}

class _StubPage extends StatelessWidget {
  final String title;
  const _StubPage({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(child: Text('Em construção')),
    );
  }
}
