import 'package:flutter/material.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/explore/presentation/pages/explore_page.dart';
import '../features/onboarding/presentation/pages/welcome_page.dart';

class Routes {
  static const welcome = '/';
  static const loginMorador = '/login';
  static const alugar = '/alugar';
}

final Map<String, WidgetBuilder> appRoutes = {
  Routes.welcome: (_) => const WelcomePage(),
  Routes.loginMorador: (_) => const LoginPage(),
  Routes.alugar: (_) => const ExplorePage(),
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
