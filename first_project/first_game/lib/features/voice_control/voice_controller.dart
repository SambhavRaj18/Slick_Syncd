import 'package:flutter/material.dart';
import 'models/voice_command_model.dart';
import 'services/voice_service.dart';

class VoiceController extends ChangeNotifier {
  final VoiceService _service = VoiceService();

  bool _isListening = false;
  bool _isProcessing = false;
  String _currentText = '';
  String? _errorMessage;
  final List<VoiceCommand> _history = [];

  bool get isListening => _isListening;
  bool get isProcessing => _isProcessing;
  String get currentText => _currentText;
  String? get errorMessage => _errorMessage;
  List<VoiceCommand> get history => List.unmodifiable(_history.reversed.toList());

  Future<void> startListening() async {
    _isListening = true;
    _currentText = '';
    _errorMessage = null;
    notifyListeners();

    try {
      await for (final word in _service.simulateSpeechRecognition()) {
        _currentText += (_currentText.isEmpty ? '' : ' ') + word;
        notifyListeners();
      }
      await _processCommand(_currentText);
    } catch (e) {
      _errorMessage = 'Voice recognition failed.';
    }

    _isListening = false;
    notifyListeners();
  }

  Future<void> _processCommand(String text) async {
    if (text.isEmpty) return;
    _isProcessing = true;
    notifyListeners();
    final result = await _service.processCommand(text);
    _history.add(result);
    _isProcessing = false;
    _currentText = '';
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }
}
