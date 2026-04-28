import 'package:flutter/material.dart';

/// Permission helper — stubbed for demo since permission_handler is optional.
/// Replace method bodies with real permission_handler calls when adding the package.
class PermissionsHelper {
  /// Request microphone permission (for voice control).
  static Future<bool> requestMicrophonePermission() async {
    // TODO: integrate permission_handler package for real permission request
    debugPrint('[PermissionsHelper] requestMicrophonePermission called (stubbed)');
    return true;
  }

  /// Request camera permission (for gesture control).
  static Future<bool> requestCameraPermission() async {
    debugPrint('[PermissionsHelper] requestCameraPermission called (stubbed)');
    return true;
  }

  /// Check if both mic and camera are granted.
  static Future<bool> checkAllPermissions() async {
    final mic = await requestMicrophonePermission();
    final cam = await requestCameraPermission();
    return mic && cam;
  }
}
