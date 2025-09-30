import 'package:flutter/material.dart';
import 'router.dart';
import 'theme/theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Imovato',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      // darkTheme: buildDarkTheme(),
      themeMode: ThemeMode.system,
      initialRoute: Routes.welcome,
      routes: appRoutes,
    );
  }
}
