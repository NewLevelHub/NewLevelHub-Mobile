import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newlevelhub_mobile/core/theme/app_theme.dart';
import 'package:newlevelhub_mobile/core/widgets/app_button.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: child),
    );
  }

  testWidgets('AppButton shows loading indicator and is disabled', (tester) async {
    var pressed = false;

    await tester.pumpWidget(
      wrap(
        AppButton(
          label: 'Submit',
          isLoading: true,
          onPressed: () => pressed = true,
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Submit'), findsNothing);

    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(pressed, isFalse);
  });

  testWidgets('AppButton primary calls onPressed', (tester) async {
    var pressed = false;

    await tester.pumpWidget(
      wrap(
        AppButton(
          label: 'Submit',
          onPressed: () => pressed = true,
        ),
      ),
    );

    await tester.tap(find.text('Submit'));
    await tester.pump();

    expect(pressed, isTrue);
  });

  testWidgets('AppButton secondary uses OutlinedButton', (tester) async {
    await tester.pumpWidget(
      wrap(
        const AppButton(
          label: 'Cancel',
          variant: AppButtonVariant.secondary,
        ),
      ),
    );

    expect(find.byType(OutlinedButton), findsOneWidget);
  });

  testWidgets('AppButton text uses TextButton', (tester) async {
    await tester.pumpWidget(
      wrap(
        const AppButton(
          label: 'Link',
          variant: AppButtonVariant.text,
          expanded: false,
        ),
      ),
    );

    expect(find.byType(TextButton), findsOneWidget);
  });
}
