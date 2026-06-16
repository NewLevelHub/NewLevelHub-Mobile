import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newlevelhub_mobile/core/theme/app_theme.dart';
import 'package:newlevelhub_mobile/core/widgets/app_error_view.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: child),
    );
  }

  testWidgets('AppErrorView shows message and retry button', (tester) async {
    var retried = false;

    await tester.pumpWidget(
      wrap(
        AppErrorView(
          message: 'Ошибка сети',
          onRetry: () => retried = true,
        ),
      ),
    );

    expect(find.text('Ошибка сети'), findsOneWidget);
    expect(find.text('Повторить'), findsOneWidget);

    await tester.tap(find.text('Повторить'));
    await tester.pump();

    expect(retried, isTrue);
  });
}
