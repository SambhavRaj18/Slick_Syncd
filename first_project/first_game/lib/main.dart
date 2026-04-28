import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:provider/provider.dart' as legacy;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/repository_providers.dart';
import 'routes/app_routes.dart';
import 'routes/route_generator.dart';

// Controllers
import 'features/auth/auth_controller.dart';
import 'features/devices/device_controller.dart';
import 'features/home/home_controller.dart';
import 'features/voice_control/voice_controller.dart';
import 'features/gesture_control/gesture_controller.dart';
import 'features/web_control/web_controller.dart';
import 'features/automation/automation_controller.dart';
import 'features/settings/settings_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await StorageService.init();

  runApp(
    const ProviderScope(
      child: SmartHomeApp(),
    ),
  );
}

class SmartHomeApp extends ConsumerWidget {
  const SmartHomeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authRepository = ref.watch(authRepositoryProvider);
    final deviceRepository = ref.watch(deviceRepositoryProvider);

    return legacy.MultiProvider(
      providers: [
        legacy.ChangeNotifierProvider(create: (_) => AuthController(authRepository)),
        legacy.ChangeNotifierProvider(create: (_) => DeviceController(deviceRepository)),
        legacy.ChangeNotifierProvider(create: (ctx) => HomeController(
          legacy.Provider.of<DeviceController>(ctx, listen: false)
        )),
        legacy.ChangeNotifierProvider(create: (_) => VoiceController()),
        legacy.ChangeNotifierProvider(create: (_) => GestureController()),
        legacy.ChangeNotifierProvider(create: (_) => WebController()),
        legacy.ChangeNotifierProvider(create: (_) => AutomationController()),
        legacy.ChangeNotifierProvider(create: (_) => SettingsController()),
      ],
      child: MaterialApp(
        title: 'Smart Home AI',
        debugShowCheckedModeBanner: false,
        // Always Light — the whole app is light-blue/white
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.login,
        onGenerateRoute: RouteGenerator.generateRoute,
      ),
    );
  }
}