import 'package:flutter/material.dart';
import '../../../core/services/storage_service.dart';

class SettingsController extends ChangeNotifier {
  bool _isDarkMode = true;
  bool _notificationsEnabled = true;

  bool get isDarkMode => _isDarkMode;
  bool get notificationsEnabled => _notificationsEnabled;

  SettingsController() {
    _isDarkMode = StorageService.isDarkMode();
    _notificationsEnabled = StorageService.notificationsEnabled();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await StorageService.setDarkMode(_isDarkMode);
    notifyListeners();
  }

  Future<void> toggleNotifications() async {
    _notificationsEnabled = !_notificationsEnabled;
    await StorageService.setNotificationsEnabled(_notificationsEnabled);
    notifyListeners();
  }
}
