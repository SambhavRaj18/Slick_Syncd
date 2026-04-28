import 'package:flutter/material.dart';

class WebController extends ChangeNotifier {
  bool _isConnected = true;
  String _sessionId = 'WEB-${DateTime.now().millisecondsSinceEpoch}';

  bool get isConnected => _isConnected;
  String get sessionId => _sessionId;

  void connect() {
    _isConnected = true;
    _sessionId = 'WEB-${DateTime.now().millisecondsSinceEpoch}';
    notifyListeners();
  }

  void disconnect() {
    _isConnected = false;
    notifyListeners();
  }
}
