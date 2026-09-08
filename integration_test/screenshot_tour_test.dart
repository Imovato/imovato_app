import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import 'package:imovato_app/app/app_shell.dart';
import 'package:imovato_app/app/theme/theme.dart';
import 'package:imovato_app/features/auth/presentation/controllers/login_controller.dart';
import 'package:imovato_app/features/auth/presentation/controllers/register_controller.dart';
import 'package:imovato_app/features/auth/presentation/pages/login_page.dart';
import 'package:imovato_app/features/checkout/application/reservations_controller.dart';
import 'package:imovato_app/features/explore/application/explore_controller.dart';
import 'package:imovato_app/features/onboarding/presentation/pages/welcome_page.dart';
import 'package:imovato_app/features/search/domain/property.dart';
import 'package:imovato_app/features/search/presentation/pages/property_details_page.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('screenshot tour', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await binding.convertFlutterSurfaceToImage();
    await tester.pump();
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await _capture(tester, binding, 'welcome', const WelcomePage());
    await _capture(tester, binding, 'home', const AppShell());
    await _capture(
        tester, binding, 'listings', const AppShell(initialIndex: 1));
    await _capture(tester, binding, 'property_details',
        PropertyDetailsPage(property: _mockProperty));
    await _capture(
        tester, binding, 'favorites', const AppShell(initialIndex: 2));
    await _capture(tester, binding, 'profile', const AppShell(initialIndex: 3));
    await _capture(tester, binding, 'login', const LoginPage());
  });
}

Future<void> _capture(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding,
  String name,
  Widget screen,
) async {
  await tester.pumpWidget(_ScreenshotApp(screen: screen));
  await tester.pumpAndSettle(const Duration(milliseconds: 250));
  await binding.takeScreenshot(name);
}

class _ScreenshotApp extends StatelessWidget {
  const _ScreenshotApp({required this.screen});

  final Widget screen;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ExploreController(initialResults: [_mockProperty]),
        ),
        ChangeNotifierProvider(create: (_) => LoginController()),
        ChangeNotifierProvider(create: (_) => RegisterController()),
        ChangeNotifierProvider(create: (_) => ReservationsController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildLightTheme(),
        home: screen,
      ),
    );
  }
}

const _mockProperty = Property(
  id: 'screenshot-property-001',
  title: 'Apartamento ensolarado próximo à universidade',
  address: 'Rua das Palmeiras',
  streetNumber: '120',
  neighborhood: 'Centro',
  city: 'Alegrete',
  state: 'RS',
  description: 'Espaço confortável e prático para sua rotina de estudos.',
  price: 1250,
  imagesUrls: [],
  maxOccupancy: 2,
  bedrooms: 1,
  bathrooms: 1,
  accommodationType: 'apartamento',
  petFriendly: true,
);
