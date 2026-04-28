import 'package:first_game/features/devices/device_controller.dart';
import 'package:flutter/material.dart';

class HomeController extends ChangeNotifier {
  final DeviceController _deviceController;

  HomeController(this._deviceController);

  String get greetingMessage {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  int get totalDevices => _deviceController.devices.length;
  int get activeDevices => _deviceController.onlineCount;
  List<String> get rooms => _deviceController.rooms;
}
