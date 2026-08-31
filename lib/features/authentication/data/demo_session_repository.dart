import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final demoSessionRepositoryProvider = Provider<DemoSessionRepository>((ref) {
  return DemoSessionRepository();
});

final demoSessionProvider = FutureProvider<bool>((ref) {
  return ref.watch(demoSessionRepositoryProvider).isActive();
});

class DemoSessionRepository {
  static const _key = 'protegeela.demo_session_active';

  Future<bool> isActive() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  Future<void> start() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }

  Future<void> end() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
