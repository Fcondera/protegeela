import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_providers.dart';
import '../../../shared/models/trusted_contact.dart';
import '../../authentication/data/demo_session_repository.dart';

final trustedContactsRepositoryProvider = Provider<TrustedContactsRepository>((ref) {
  return TrustedContactsRepository(ref.watch(supabaseClientProvider));
});

final trustedContactsProvider = FutureProvider<List<TrustedContact>>((ref) async {
  final demoActive = await ref.watch(demoSessionProvider.future);
  if (demoActive) {
    return const [
      TrustedContact(
        id: 'demo-contact',
        ownerUserId: 'demo-user',
        name: 'Contato demonstrativo',
        phone: '(00) 00000-0000',
        relationship: 'demo',
        invitationStatus: 'accepted',
        canViewExactLocation: true,
        isPrimary: true,
      ),
    ];
  }
  ref.watch(authStateProvider);
  return ref.watch(trustedContactsRepositoryProvider).listMine();
});

class TrustedContactsRepository {
  const TrustedContactsRepository(this._client);

  final SupabaseClient _client;

  Future<List<TrustedContact>> listMine() async {
    final rows = await _client
        .from('trusted_contacts')
        .select()
        .order('is_primary', ascending: false)
        .order('created_at', ascending: false);
    return [for (final row in rows) TrustedContact.fromJson(row)];
  }

  Future<void> addContact({
    required String name,
    required String phone,
    String? email,
    required String relationship,
    required bool canViewExactLocation,
  }) async {
    final userId = _client.auth.currentUser!.id;
    await _client.from('trusted_contacts').insert({
      'owner_user_id': userId,
      'name': name.trim(),
      'phone': phone.trim(),
      'email': email?.trim().isEmpty ?? true ? null : email!.trim(),
      'relationship': relationship,
      'invitation_status': 'pending',
      'can_view_exact_location': canViewExactLocation,
    });
  }

  Future<void> remove(String id) async {
    await _client.from('trusted_contacts').delete().eq('id', id);
  }
}
