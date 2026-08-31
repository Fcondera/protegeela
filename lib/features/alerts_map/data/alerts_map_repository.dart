import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_providers.dart';

final alertsMapRepositoryProvider = Provider<AlertsMapRepository>((ref) {
  return AlertsMapRepository(ref.watch(supabaseClientProvider));
});

class PublicAlertMarker {
  const PublicAlertMarker({
    required this.id,
    required this.alertType,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.startedAt,
  });

  final String id;
  final String alertType;
  final String status;
  final double latitude;
  final double longitude;
  final int radiusMeters;
  final DateTime startedAt;

  factory PublicAlertMarker.fromJson(Map<String, dynamic> json) => PublicAlertMarker(
        id: json['id'] as String,
        alertType: json['alert_type'] as String,
        status: json['status'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        radiusMeters: (json['radius_meters'] as num?)?.toInt() ?? 500,
        startedAt: DateTime.parse(json['started_at'] as String),
      );
}

class AlertsMapRepository {
  const AlertsMapRepository(this._client);

  final SupabaseClient _client;

  Future<List<PublicAlertMarker>> publicAlertsInBounds({
    required double south,
    required double west,
    required double north,
    required double east,
  }) async {
    final response = await _client.functions.invoke(
      'get-public-alerts-in-bounds',
      body: {'south': south, 'west': west, 'north': north, 'east': east, 'limit': 100},
    );
    final list = response.data as List<dynamic>;
    return [for (final item in list) PublicAlertMarker.fromJson(item as Map<String, dynamic>)];
  }
}
