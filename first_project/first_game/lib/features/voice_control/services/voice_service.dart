import 'dart:async';
import 'package:dio/dio.dart';
import '../../../core/services/api_client.dart';
import '../models/voice_command_model.dart';

class VoiceService {
  final ApiClient _apiClient = ApiClient();

  Future<VoiceCommand> processCommand(String text) async {
    try {
      final response = await _apiClient.post('/command', data: {'command': text});
      
      String responseText = 'Command sent to Slick Sync...';
      if (response.statusCode == 200) {
        responseText = 'Command executed: $text';
      }

      return VoiceCommand(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        response: responseText,
        timestamp: DateTime.now(),
        status: VoiceCommandStatus.executed,
      );
    } catch (e) {
      return VoiceCommand(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        response: 'Error: ${e.toString()}',
        timestamp: DateTime.now(),
        status: VoiceCommandStatus.failed,
      );
    }
  }

  Stream<String> simulateSpeechRecognition() async* {
    final words = ['Hello', 'Don', 'turn', 'on', 'rock'];
    for (final w in words) {
      await Future.delayed(const Duration(milliseconds: 300));
      yield w;
    }
  }
}
