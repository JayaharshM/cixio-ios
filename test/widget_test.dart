import 'package:flutter_test/flutter_test.dart';

import 'package:cixio/main.dart';

void main() {
  testWidgets('Navigates between login and registration',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Sign in to continue'), findsOneWidget);

    await tester.ensureVisible(find.text('Sign up'));
    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Create Account'));
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('SmartHub'), findsOneWidget);

    await tester.ensureVisible(find.text('Log in'));
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Sign in to continue'), findsOneWidget);
  });
}
