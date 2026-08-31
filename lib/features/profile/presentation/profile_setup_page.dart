import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/validators.dart';
import '../data/profile_repository.dart';

class ProfileSetupPage extends ConsumerStatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  ConsumerState<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends ConsumerState<ProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  bool _privacyMode = false;
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await ref.read(profileRepositoryProvider).upsertProfile(
          fullName: _name.text,
          phone: _phone.text,
          privacyMode: _privacyMode ? 'discreet' : 'standard',
        );
    ref.invalidate(currentProfileProvider);
    if (mounted) context.go('/primeiro-contato');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar perfil')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              shrinkWrap: true,
              children: [
                TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Nome completo'), validator: (v) => Validators.required(v, field: 'Nome')),
                const SizedBox(height: 12),
                TextFormField(controller: _phone, decoration: const InputDecoration(labelText: 'Telefone'), validator: Validators.phone),
                SwitchListTile(
                  value: _privacyMode,
                  onChanged: (value) => setState(() => _privacyMode = value),
                  title: const Text('Usar textos discretos nas notificacoes'),
                ),
                const SizedBox(height: 16),
                FilledButton(onPressed: _loading ? null : _submit, child: const Text('Salvar perfil')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
