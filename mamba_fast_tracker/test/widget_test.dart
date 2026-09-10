import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mamba_fast_tracker/main.dart';

void main() {
  testWidgets(
    'Tela de login aparece',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginPage(
            isDarkMode: false,
            onToggleTheme: () {},
          ),
        ),
      );

      expect(
        find.text('Mamba Fast Tracker'),
        findsOneWidget,
      );

      expect(
        find.text('Entrar'),
        findsOneWidget,
      );

      expect(
        find.text('Criar uma conta'),
        findsOneWidget,
      );
    },
  );
}