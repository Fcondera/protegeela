import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme.dart';
import '../../../core/constants/app_constants.dart';

enum EmergencyConfirmationAction { sendNow, cancel, silent }

class EmergencyButton extends StatefulWidget {
  const EmergencyButton({super.key, required this.onConfirmed, this.enabled = true});

  final Future<void> Function({required bool isSilent}) onConfirmed;
  final bool enabled;

  @override
  State<EmergencyButton> createState() => _EmergencyButtonState();
}

class _EmergencyButtonState extends State<EmergencyButton> {
  Timer? _timer;
  double _progress = 0;
  bool _busy = false;

  void _start() {
    if (!widget.enabled || _busy || _timer != null) return;
    HapticFeedback.mediumImpact();
    final started = DateTime.now();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) async {
      final elapsed = DateTime.now().difference(started).inMilliseconds;
      final next = (elapsed / (AppConstants.emergencyHoldSeconds * 1000)).clamp(0.0, 1.0);
      setState(() => _progress = next);
      if (next >= 1) {
        _cancelTimer(keepProgress: true);
        await _confirm();
      }
    });
  }

  void _cancelTimer({bool keepProgress = false}) {
    _timer?.cancel();
    _timer = null;
    if (!keepProgress && mounted) setState(() => _progress = 0);
  }

  Future<void> _confirm() async {
    if (_busy || !mounted) return;
    final action = await showDialog<EmergencyConfirmationAction>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const EmergencyConfirmationDialog(),
    );
    if (action == null || action == EmergencyConfirmationAction.cancel) {
      if (mounted) setState(() => _progress = 0);
      return;
    }
    setState(() => _busy = true);
    try {
      await widget.onConfirmed(isSilent: action == EmergencyConfirmationAction.silent);
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _progress = 0;
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disabled = !widget.enabled || _busy;
    return Semantics(
      button: true,
      label: 'Pedir ajuda. Pressione e segure por 5 segundos.',
      child: FocusableActionDetector(
        shortcuts: const {SingleActivator(LogicalKeyboardKey.enter): ActivateIntent()},
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _start();
              return null;
            },
          ),
        },
        child: Listener(
          onPointerDown: (_) => _start(),
          onPointerUp: (_) => _cancelTimer(),
          onPointerCancel: (_) => _cancelTimer(),
          child: ConstrainedBox(
            constraints: const BoxConstraints.tightFor(width: 260, height: 260),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.square(
                  dimension: 260,
                  child: CircularProgressIndicator(
                    value: _progress == 0 ? null : _progress,
                    strokeWidth: 10,
                    color: disabled ? Colors.grey : AppColors.emergency,
                    backgroundColor: Colors.white,
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: disabled ? Colors.grey.shade500 : AppColors.emergency,
                    shape: BoxShape.circle,
                    boxShadow: const [BoxShadow(blurRadius: 24, color: Color(0x22000000))],
                  ),
                  child: const SizedBox.square(
                    dimension: 220,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.volunteer_activism, color: Colors.white, size: 44),
                          SizedBox(height: 12),
                          Text(
                            'PEDIR AJUDA',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                          ),
                          SizedBox(height: 8),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              'Pressione e segure por 5 segundos',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EmergencyConfirmationDialog extends StatefulWidget {
  const EmergencyConfirmationDialog({super.key});

  @override
  State<EmergencyConfirmationDialog> createState() => _EmergencyConfirmationDialogState();
}

class _EmergencyConfirmationDialogState extends State<EmergencyConfirmationDialog> {
  Timer? _timer;
  int _remaining = AppConstants.confirmationSeconds;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining <= 1) {
        timer.cancel();
        Navigator.of(context).pop(EmergencyConfirmationAction.sendNow);
      } else {
        setState(() => _remaining--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Enviar alerta em $_remaining s'),
      content: const Text(
        'Se voce nao escolher nada, o alerta sera enviado. O app nao substitui policia, emergencia ou atendimento medico.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(EmergencyConfirmationAction.cancel),
          child: const Text('Cancelar'),
        ),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(EmergencyConfirmationAction.silent),
          child: const Text('Ativar silenciosamente'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(EmergencyConfirmationAction.sendNow),
          child: const Text('Enviar alerta agora'),
        ),
      ],
    );
  }
}
