import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_providers.dart';
import '../../../shared/models/support_point.dart';
import '../../authentication/data/demo_session_repository.dart';

final supportPointsRepositoryProvider = Provider<SupportPointsRepository>((ref) {
  return SupportPointsRepository(ref.watch(supabaseClientProvider));
});

final supportPointsProvider = FutureProvider<List<SupportPoint>>((ref) async {
  final demoActive = await ref.watch(demoSessionProvider.future);
  if (demoActive) {
    return const [
      SupportPoint(
        id: 'demo-support-point',
        name: 'Ponto de apoio demonstrativo ficticio',
        category: 'support_center',
        description: 'Dado ficticio para testar a interface.',
        address: 'Endereco ficticio, 100',
        city: 'Cidade Demo',
        state: 'AM',
        latitude: -3.1190,
        longitude: -60.0217,
        isVerified: false,
        openingHours: 'Horario ficticio',
      ),
    ];
  }
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
