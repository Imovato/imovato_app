import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/explore/application/explore_controller.dart';
import 'router.dart';
import 'theme/theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ExploreController>(
          create: (_) => ExploreController(initialValor: 1000),
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
