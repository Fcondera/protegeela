import '../../../shared/models/emergency_alert.dart';

class EmergencyState {
  const EmergencyState({
    this.activeAlert,
    this.isSending = false,
    this.clientRequestId,
    this.lastMessage,
  });

  final EmergencyAlert? activeAlert;
  final bool isSending;
  final String? clientRequestId;
  final String? lastMessage;

  EmergencyState copyWith({
    EmergencyAlert? activeAlert,
    bool? isSending,
    String? clientRequestId,
    String? lastMessage,
    bool clearActiveAlert = false,
  }) {
    return EmergencyState(
      activeAlert: clearActiveAlert ? null : activeAlert ?? this.activeAlert,
      isSending: isSending ?? this.isSending,
      clientRequestId: clientRequestId ?? this.clientRequestId,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }
}
