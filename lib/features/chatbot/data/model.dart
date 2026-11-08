class ModelMessage {
  final bool isPrompt;
  final String sendMessage;
  final DateTime time;
  final String? messageId; // Added for unique identification

  ModelMessage({
    required this.isPrompt,
    required this.sendMessage,
    required this.time,
    this.messageId,
  });
}