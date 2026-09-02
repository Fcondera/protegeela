import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_state_view.dart';
import '../../authentication/data/demo_session_repository.dart';
import '../data/trusted_contacts_repository.dart';

class TrustedContactsPage extends ConsumerWidget {
  const TrustedContactsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contacts = ref.watch(trustedContactsProvider);
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Rede de apoio'),
        actions: [
          IconButton(onPressed: () => _showAddContact(context, ref), icon: const Icon(Icons.person_add), tooltip: 'Adicionar contato'),
        ],
      ),
      body: contacts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => AppStateView(title: 'Erro', message: 'Nao foi possivel carregar contatos.', actionLabel: 'Tentar novamente', onAction: () => ref.invalidate(trustedContactsProvider)),
        data: (items) {
          if (items.isEmpty) {
            return AppStateView(
              title: 'Nenhum contato cadastrado',
              message: 'Convide pessoas de confianca. Um contato so fica ativo apos consentimento.',
              actionLabel: 'Adicionar contato',
              onAction: () => _showAddContact(context, ref),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: Icon(item.isPrimary ? Icons.star : Icons.person_outline),
                title: Text(item.name),
                subtitle: Text('${item.relationship} - ${item.invitationStatus}'),
                trailing: IconButton(
                  onPressed: () async {
                    await ref.read(trustedContactsRepositoryProvider).remove(item.id);
                    ref.invalidate(trustedContactsProvider);
                  },
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Remover contato',
                ),
              );
            },
            separatorBuilder: (_, __) => const Divider(),
            itemCount: items.length,
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddContact(context, ref),
        icon: const Icon(Icons.person_add),
        label: const Text('Contato'),
      ),
    );
  }

  Future<void> _showAddContact(BuildContext context, WidgetRef ref) async {
    final formKey = GlobalKey<FormState>();
    final name = TextEditingController();
    final phone = TextEditingController();
    final email = TextEditingController();
    var relationship = 'familia';
    var exact = true;

    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Adicionar contato'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(controller: name, decoration: const InputDecoration(labelText: 'Nome'), validator: (v) => Validators.required(v, field: 'Nome')),
                  const SizedBox(height: 12),
                  TextFormField(controller: phone, decoration: const InputDecoration(labelText: 'Telefone'), validator: Validators.phone),
                  const SizedBox(height: 12),
                  TextFormField(controller: email, decoration: const InputDecoration(labelText: 'E-mail opcional')),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: relationship,
                    decoration: const InputDecoration(labelText: 'Relacao'),
                    items: const [
                      DropdownMenuItem(value: 'familia', child: Text('Familia')),
                      DropdownMenuItem(value: 'amiga', child: Text('Amiga')),
                      DropdownMenuItem(value: 'vizinha', child: Text('Vizinha')),
                      DropdownMenuItem(value: 'outro', child: Text('Outro')),
                    ],
                    onChanged: (value) => setState(() => relationship = value ?? 'outro'),
                  ),
                  SwitchListTile(
                    value: exact,
                    onChanged: (value) => setState(() => exact = value),
                    title: const Text('Permitir localizacao exata durante alerta'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) Navigator.pop(context, true);
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );

    if (saved == true) {
      final demoActive = await ref.read(demoSessionProvider.future);
      if (demoActive) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contato temporario nao e salvo. Crie uma conta para enviar convites reais.')),
          );
        }
        return;
      }
      await ref.read(trustedContactsRepositoryProvider).addContact(
            name: name.text,
            phone: phone.text,
            email: email.text,
            relationship: relationship,
            canViewExactLocation: exact,
          );
      ref.invalidate(trustedContactsProvider);
    }
  }
}
