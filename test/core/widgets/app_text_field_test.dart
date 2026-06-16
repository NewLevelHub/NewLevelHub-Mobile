import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newlevelhub_mobile/core/theme/app_theme.dart';
import 'package:newlevelhub_mobile/core/widgets/app_text_field.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: Padding(padding: const EdgeInsets.all(16), child: child)),
    );
  }

  testWidgets('AppTextField displays label and errorText', (tester) async {
    await tester.pumpWidget(
      wrap(
        const AppTextField(
          label: 'Email',
          hint: 'name@example.com',
          errorText: 'Введите корректный email',
        ),
      ),
    );

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Введите корректный email'), findsOneWidget);
  });

  testWidgets('AppTextField toggles password visibility', (tester) async {
    await tester.pumpWidget(
      wrap(
        const AppTextField(
          label: 'Пароль',
          obscureText: true,
        ),
      ),
    );

    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pump();

    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
  });
}
