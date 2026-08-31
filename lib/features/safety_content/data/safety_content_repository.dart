import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_providers.dart';
import '../../../shared/models/safety_content.dart';

final safetyContentRepositoryProvider = Provider<SafetyContentRepository>((ref) {
  return SafetyContentRepository(ref.watch(supabaseClientProvider));
});

final safetyContentsProvider = FutureProvider<List<SafetyContent>>((ref) async {
  return ref.watch(safetyContentRepositoryProvider).published();
});

class SafetyContentRepository {
  const SafetyContentRepository(this._client);

  final SupabaseClient _client;

  Future<List<SafetyContent>> published() async {
    final rows = await _client.from('safety_contents').select().eq('is_published', true).order('title');
    return [for (final row in rows) SafetyContent.fromJson(row)];
  }
}
