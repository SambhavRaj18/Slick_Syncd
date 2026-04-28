import 'package:flutter/material.dart';
import 'app_routes.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/devices/screens/device_list_screen.dart';
import '../features/devices/screens/device_detail_screen.dart';
import '../features/devices/screens/add_device_screen.dart';
import '../features/voice_control/voice_screen.dart';
import '../features/gesture_control/gesture_screen.dart';
import '../features/web_control/screens/web_dashboard_screen.dart';
import '../features/automation/screens/automation_screen.dart';
import '../features/settings/screens/settings_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
      case AppRoutes.home:
        return _fade(const HomeScreen());
      case AppRoutes.login:
        return _fade(const LoginScreen());
      case AppRoutes.signup:
        return _fade(const SignupScreen());
      case AppRoutes.devices:
        return _slide(const DeviceListScreen());
      case AppRoutes.deviceDetail:
        final deviceId = settings.arguments as String?;
        return _slide(DeviceDetailScreen(deviceId: deviceId));
      case AppRoutes.addDevice:
        return _slide(const AddDeviceScreen());
      case AppRoutes.voiceControl:
        return _slide(const VoiceScreen());
      case AppRoutes.gestureControl:
        return _slide(const GestureScreen());
      case AppRoutes.webControl:
        return _slide(const WebDashboardScreen());
      case AppRoutes.automation:
        return _slide(const AutomationScreen());
      case AppRoutes.settings:
        return _slide(const SettingsScreen());
      default:
        return _fade(_notFoundPage(settings.name));
    }
  }

  static PageRoute _fade(Widget page) => PageRouteBuilder(
        pageBuilder: (_, _, _) => page,
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      );

  static PageRoute _slide(Widget page) => PageRouteBuilder(
        pageBuilder: (_, _, _) => page,
        transitionsBuilder: (_, anim, _, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      );

  static Widget _notFoundPage(String? name) => Scaffold(
        body: Center(
          child: Text('Page not found: $name'),
        ),
      );
}
