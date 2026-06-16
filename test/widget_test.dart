import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:newlevelhub_mobile/app.dart';

void main() {
  testWidgets('app starts on splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const NewLevelHubApp(runConnectivityProbeOnStart: false),
    );
    await tester.pump();

    expect(find.text('New Level Hub'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
