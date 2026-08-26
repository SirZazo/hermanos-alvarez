import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app/app.dart';
import 'features/cookies/data/cookie_consent_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  usePathUrlStrategy();

  await CookieConsentService.instance.initialize();

  runApp(const HermanosAlvarezApp());
}
