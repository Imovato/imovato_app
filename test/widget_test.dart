import 'package:flutter_test/flutter_test.dart';
import 'package:imovato_app/app/app.dart';

void main() {
  testWidgets('opens the welcome screen', (tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(find.text('Olá, boas vindas!'), findsOneWidget);
    expect(find.text('Quero Alugar'), findsOneWidget);
  });
}
