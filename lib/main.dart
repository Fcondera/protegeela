import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/config/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Local .env is optional. Open source users can prefer --dart-define.
  }

  final config = AppConfig.fromEnvironment();
  await Supabase.initialize(url: config.supabaseUrl, anonKey: config.supabaseAnonKey);

  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(config),
      ],
      child: const ProtegeElaApp(),
    ),
  );
}
