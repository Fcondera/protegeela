import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_state_view.dart';
import '../../authentication/data/demo_session_repository.dart';
import '../../authentication/data/auth_repository.dart';
import '../data/profile_preferences.dart';
import '../data/profile_repository.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _requirePin = false;
  bool _hidePreview = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final prefs = ref.read(profilePreferencesProvider);
      final requirePin = await prefs.requirePinForSensitiveInfo();
      final hidePreview = await prefs.hideAlertPreview();
      if (mounted) {
        setState(() {
          _requirePin = requirePin;
          _hidePreview = hidePreview;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentProfileProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const AppStateView(title: 'Erro', message: 'Nao foi possivel carregar seu perfil.'),
        data: (value) {
          if (value == null) {
            return AppStateView(title: 'Perfil incompleto', message: 'Crie seu perfil para continuar.', actionLabel: 'Criar perfil', onAction: () => context.go('/criar-perfil'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(leading: const Icon(Icons.person_outline), title: Text(value.fullName), subtitle: Text(value.phone)),
              SwitchListTile(
                value: value.privacyMode == 'discreet',
                onChanged: (enabled) async {
                  final demoActive = await ref.read(demoSessionProvider.future);
                  if (!demoActive) {
                    await ref.read(profileRepositoryProvider).updatePrivacyMode(enabled ? 'discreet' : 'standard');
                    ref.invalidate(currentProfileProvider);
                  }
                },
                title: const Text('Textos discretos nas notificacoes'),
              ),
              SwitchListTile(
                value: _requirePin,
                onChanged: (enabled) async {
                  await ref.read(profilePreferencesProvider).setRequirePinForSensitiveInfo(enabled);
                  setState(() => _requirePin = enabled);
                },
                title: const Text('Exigir PIN para informacoes sensiveis'),
              ),
              SwitchListTile(
                value: _hidePreview,
                onChanged: (enabled) async {
                  await ref.read(profilePreferencesProvider).setHideAlertPreview(enabled);
                  setState(() => _hidePreview = enabled);
                },
                title: const Text('Ocultar previa do alerta'),
              ),
              const Divider(),
              ListTile(leading: const Icon(Icons.admin_panel_settings_outlined), title: const Text('Painel administrativo'), enabled: value.isAdmin, onTap: value.isAdmin ? () => context.go('/admin') : null),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sair'),
                onTap: () async {
                  final demoActive = await ref.read(demoSessionProvider.future);
                  if (demoActive) {
                    await ref.read(demoSessionRepositoryProvider).end();
                    ref.invalidate(demoSessionProvider);
                  } else {
                    await ref.read(authRepositoryProvider).signOut();
                  }
                  if (context.mounted) context.go('/login');
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
