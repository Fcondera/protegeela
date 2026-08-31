import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final profilePreferencesProvider = Provider<ProfilePreferences>((ref) => ProfilePreferences());

class ProfilePreferences {
  static const _requirePinKey = 'protegeela.require_pin_for_sensitive_info';
  static const _hideAlertPreviewKey = 'protegeela.hide_alert_preview';

  Future<bool> requirePinForSensitiveInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_requirePinKey) ?? false;
  }

  Future<bool> hideAlertPreview() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hideAlertPreviewKey) ?? true;
  }

  Future<void> setRequirePinForSensitiveInfo(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_requirePinKey, value);
  }

  Future<void> setHideAlertPreview(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hideAlertPreviewKey, value);
  }
}
