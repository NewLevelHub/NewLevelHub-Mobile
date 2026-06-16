import 'package:flutter_test/flutter_test.dart';

import 'package:newlevelhub_mobile/app.dart';

void main() {
  testWidgets('Placeholder screen is shown', (WidgetTester tester) async {
    await tester.pumpWidget(const NewLevelHubApp());

    expect(find.text('New Level Hub'), findsWidgets);
    expect(find.text('Мобильное приложение в разработке'), findsOneWidget);
  });
}
