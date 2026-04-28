enum VoiceCommandStatus { pending, processing, executed, failed }

class VoiceCommand {
  final String id;
  final String text;
  final String response;
  final DateTime timestamp;
  final VoiceCommandStatus status;

  const VoiceCommand({
    required this.id,
    required this.text,
    required this.response,
    required this.timestamp,
    required this.status,
  });
}
