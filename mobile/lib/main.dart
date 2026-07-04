import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (details) {
        FlutterError.presentError(details);
      };

      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      try {
        await dotenv.load(fileName: '.env');
      } catch (_) {
        // .env file might not be bundled in some build configs; use defaults
      }

      runApp(
        const ProviderScope(
          child: MannaApartmentApp(),
        ),
      );
    },
    (error, stack) {
      // Log uncaught errors instead of crashing
      debugPrint('Uncaught error: $error');
      debugPrint('Stack: $stack');
    },
  );
}
