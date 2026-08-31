import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

final emergencyCallServiceProvider = Provider<EmergencyCallService>((ref) {
  return EmergencyCallService();
});

class EmergencyCallService {
  Future<bool> call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (!await canLaunchUrl(uri)) return false;
    return launchUrl(uri);
  }
}
