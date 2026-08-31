import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('migration enables RLS and exact location protection', () {
    final sql = File('supabase/migrations/0001_initial_schema.sql').readAsStringSync();

    for (final table in [
      'profiles',
      'trusted_contacts',
      'emergency_alerts',
      'alert_locations',
      'alert_recipients',
      'tracking_links',
      'support_points',
      'safety_contents',
      'emergency_services',
      'audit_logs',
    ]) {
      expect(sql, contains('alter table public.$table enable row level security'));
    }

    expect(sql, contains('user_can_view_exact_alert'));
    expect(sql, contains('get_public_alerts_in_bounds'));
    expect(sql, contains('prevent_frontend_admin_escalation'));
  });
}
