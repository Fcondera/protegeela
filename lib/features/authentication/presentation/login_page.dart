import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/demo_session_repository.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  Future<void> _startDemoSession(BuildContext context, WidgetRef ref) async {
    await ref.read(demoSessionRepositoryProvider).start();
    ref.invalidate(demoSessionProvider);
    if (context.mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () => _startDemoSession(context, ref),
                    icon: const Icon(Icons.login_rounded),
                    label: const Text('Entrar temporariamente'),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
