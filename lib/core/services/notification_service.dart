import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return LocalNotificationFallbackService();
});

abstract class NotificationService {
  Future<void> notifyAlertCreated(String alertId);
  Future<void> notifyLocationUpdated(String alertId);
  Future<void> notifyAlertClosed(String alertId);
}

class LocalNotificationFallbackService implements NotificationService {
  LocalNotificationFallbackService();

  final List<String> events = [];

  @override
  Future<void> notifyAlertCreated(String alertId) async {
    events.add('alert_created:$alertId');
  }

  @override
  Future<void> notifyAlertClosed(String alertId) async {
    events.add('alert_closed:$alertId');
  }

  @override
  Future<void> notifyLocationUpdated(String alertId) async {
    events.add('location_updated:$alertId');
  }
}
