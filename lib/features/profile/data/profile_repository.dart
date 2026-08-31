import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_providers.dart';
import '../../../shared/models/app_profile.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(supabaseClientProvider));
});

final currentProfileProvider = FutureProvider<AppProfile?>((ref) async {
  ref.watch(authStateProvider);
  return ref.watch(profileRepositoryProvider).currentProfile();
});

class ProfileRepository {
  const ProfileRepository(this._client);

  final SupabaseClient _client;

  Future<AppProfile?> currentProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;
    final data = await _client.from('profiles').select().eq('id', userId).maybeSingle();
    return data == null ? null : AppProfile.fromJson(data);
  }

  Future<void> upsertProfile({
    required String fullName,
    required String phone,
    String privacyMode = 'standard',
  }) async {
    final userId = _client.auth.currentUser!.id;
    await _client.from('profiles').upsert({
      'id': userId,
      'full_name': fullName.trim(),
      'phone': phone.trim(),
      'privacy_mode': privacyMode,
    });
  }

  Future<void> updatePrivacyMode(String privacyMode) async {
    final userId = _client.auth.currentUser!.id;
    await _client.from('profiles').update({'privacy_mode': privacyMode}).eq('id', userId);
  }
}
