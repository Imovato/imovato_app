import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/explore/application/explore_controller.dart';
import '../features/auth/presentation/controllers/login_controller.dart';
import '../features/auth/presentation/controllers/register_controller.dart';
import '../features/checkout/application/reservations_controller.dart';
import 'router.dart';
import 'theme/theme.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  late final LoginController _loginController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loginController = LoginController();
    // NÃO restaurar sessão - usuário deve fazer login toda vez
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Quando app for pausado/fechado, limpar a sessão
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _loginController.logout();
      print('🔒 App fechado - sessão limpa');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ExploreController>(
          create: (_) => ExploreController(initialValor: 1000),
        ),
        ChangeNotifierProvider<LoginController>.value(
          value: _loginController,
        ),
        ChangeNotifierProvider<RegisterController>(
          create: (_) => RegisterController(),
        ),
        ChangeNotifierProvider<ReservationsController>(
          create: (_) => ReservationsController(),
        ),
      ],
      child: MaterialApp(
        title: 'Imovato',
        debugShowCheckedModeBanner: false,
        theme: buildLightTheme(),
// darkTheme: buildDarkTheme(),

        themeMode: ThemeMode.system,
        initialRoute: Routes.welcome,
        routes: appRoutes,
        onGenerateRoute: onGenerateRoute,
      ),
    );
  }
}
