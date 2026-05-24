import 'package:flutter_test/flutter_test.dart';

import 'package:cixio/main.dart';

void main() {
  testWidgets('Navigates between login and registration',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsWidgets);
    expect(find.text('Welcome back'), findsOneWidget);

    await tester.tap(find.text('Create a new account'));
    await tester.pumpAndSettle();

    expect(find.text('Create account'), findsWidgets);
    expect(find.text('Get started'), findsOneWidget);

    await tester.tap(find.text('Already have an account? Login'));
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsWidgets);
    expect(find.text('Welcome back'), findsOneWidget);
  });
}
