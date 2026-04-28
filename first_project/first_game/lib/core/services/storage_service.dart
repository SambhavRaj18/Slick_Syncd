import 'package:hive_flutter/hive_flutter.dart';

/// Professional storage service using Hive for local persistence.
class StorageService {
  static late Box _box;
  static const String _boxName = 'settings_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  // ─── Auth Token ─────────────────────────────────────────────────────────────
  static String? getToken() => _box.get('auth_token') as String?;
  static Future<void> setToken(String token) async => _box.put('auth_token', token);
  static Future<void> clearToken() async => _box.delete('auth_token');

  // ─── User Info ───────────────────────────────────────────────────────────────
  static String? getUserName() => _box.get('user_name') as String?;
  static Future<void> setUserName(String name) async => _box.put('user_name', name);

  static String? getUserEmail() => _box.get('user_email') as String?;
  static Future<void> setUserEmail(String email) async => _box.put('user_email', email);

  // ─── Theme ───────────────────────────────────────────────────────────────────
  static bool isDarkMode() => (_box.get('dark_mode') as bool?) ?? true;
  static Future<void> setDarkMode(bool value) async => _box.put('dark_mode', value);

  // ─── Notifications ───────────────────────────────────────────────────────────
  static bool notificationsEnabled() => (_box.get('notifications_enabled') as bool?) ?? true;
  static Future<void> setNotificationsEnabled(bool value) async =>
      _box.put('notifications_enabled', value);

  // ─── Session ─────────────────────────────────────────────────────────────────
  static bool isLoggedIn() => getToken() != null;
  static Future<void> clearAll() async => _box.clear();
}
