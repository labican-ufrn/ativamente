import 'package:flutter/foundation.dart';

class AppEnvironment {
  static const bool _useEmulatorsFlag = bool.fromEnvironment(
    'USE_FIREBASE_EMULATORS',
  );

  static const String _emulatorHostOverride = String.fromEnvironment(
    'FIREBASE_EMULATOR_HOST',
  );

  static bool get useEmulators => kDebugMode && _useEmulatorsFlag;

  static String get emulatorHost {
    if (_emulatorHostOverride.isNotEmpty) return _emulatorHostOverride;
    return kIsWeb ? 'localhost' : '10.0.2.2';
  }

  static const int authPort = 9099;

  static const int firestorePort = 8080;
}
