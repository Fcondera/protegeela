import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protegeela/features/emergency/presentation/emergency_button.dart';

void main() {
  testWidgets('shows confirmation after holding for five seconds and allows cancellation', (tester) async {
    var sent = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmergencyButton(
            onConfirmed: ({required bool isSilent}) async {
              sent = true;
            },
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(tester.getCenter(find.byType(EmergencyButton)));
    await tester.pump(const Duration(milliseconds: 5100));

    expect(find.textContaining('Enviar alerta'), findsWidgets);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    await gesture.up();

    expect(sent, isFalse);
  });
}
