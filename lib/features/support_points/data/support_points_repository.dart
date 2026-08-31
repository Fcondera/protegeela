import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_providers.dart';
import '../../../shared/models/support_point.dart';

final supportPointsRepositoryProvider = Provider<SupportPointsRepository>((ref) {
  return SupportPointsRepository(ref.watch(supabaseClientProvider));
});

final supportPointsProvider = FutureProvider<List<SupportPoint>>((ref) async {
  return ref.watch(supportPointsRepositoryProvider).list();
});

class SupportPointsRepository {
  const SupportPointsRepository(this._client);

  final SupabaseClient _client;

  Future<List<SupportPoint>> list() async {
    final rows = await _client.from('support_points').select().order('is_verified', ascending: false);
    return [for (final row in rows) SupportPoint.fromJson(row)];
  }
}
