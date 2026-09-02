import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protegeela/features/authentication/presentation/login_page.dart';

void main() {
  testWidgets('shows only the temporary prototype login button', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginPage(),
        ),
      ),
    );

    expect(find.text('Entrar temporariamente'), findsOneWidget);
    expect(find.text('Acesse sua conta'), findsNothing);
    expect(find.byType(TextFormField), findsNothing);
    expect(find.text('Criar conta'), findsNothing);
    expect(find.text('Esqueci minha senha'), findsNothing);
  });
}
