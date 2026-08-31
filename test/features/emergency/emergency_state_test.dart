import 'package:flutter_test/flutter_test.dart';
import 'package:protegeela/features/emergency/domain/emergency_state.dart';
import 'package:protegeela/shared/models/emergency_alert.dart';

void main() {
  test('copyWith can clear active alert after close', () {
    final alert = EmergencyAlert(
      id: 'a1',
      userId: 'u1',
      alertType: 'immediate_danger',
      status: 'active',
      isSilent: false,
      locationStatus: 'captured',
      startedAt: DateTime.utc(2026),
      publicVisibility: true,
    );

    final state = EmergencyState(activeAlert: alert);

    expect(state.copyWith(clearActiveAlert: true).activeAlert, isNull);
  });
}
