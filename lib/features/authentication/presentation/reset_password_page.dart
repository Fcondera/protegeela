import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/validators.dart';
import '../data/auth_repository.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _sent = false;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).resetPassword(_email.text);
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _sent = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar senha')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              shrinkWrap: true,
              children: [
                const Text('Informe seu e-mail. Se houver uma conta associada, enviaremos instrucoes de recuperacao.'),
                const SizedBox(height: 16),
                TextFormField(controller: _email, decoration: const InputDecoration(labelText: 'E-mail'), validator: Validators.email),
                const SizedBox(height: 16),
                FilledButton(onPressed: _loading ? null : _submit, child: Text(_loading ? 'Enviando...' : 'Enviar instrucoes')),
                if (_sent) const Padding(padding: EdgeInsets.only(top: 16), child: Text('Verifique sua caixa de entrada.')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
