import 'package:flutter/material.dart';
import '../features/onboarding/presentation/pages/welcome_page.dart';

class Routes {
  static const welcome = '/';
  static const loginMorador = '/login-morador';
  static const alugar = '/alugar';
}

final Map<String, WidgetBuilder> appRoutes = {
  Routes.welcome: (_) => const WelcomePage(),
  // Provisório até você criar as telas reais:
  Routes.loginMorador: (_) => const _StubPage(title: 'Login Morador'),
  Routes.alugar: (_) => const _StubPage(title: 'Explorar Imóveis'),
};

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
