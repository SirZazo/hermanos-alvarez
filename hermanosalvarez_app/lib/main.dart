import 'package:flutter/material.dart';

import 'app/app.dart';
import 'features/cookies/data/cookie_consent_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await CookieConsentService.instance.initialize();

  runApp(const HermanosAlvarezApp());
}