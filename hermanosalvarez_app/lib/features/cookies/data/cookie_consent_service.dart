import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CookieConsentService {
  CookieConsentService._();

  static final CookieConsentService instance = CookieConsentService._();

  static const String _externalServicesKey =
      'cookie_external_services_allowed';

  static const String _consentVersionKey =
      'cookie_consent_version';

  static const int _currentConsentVersion = 1;

  /// null  -> todavía no ha elegido
  /// false -> rechazado
  /// true  -> aceptado
  final ValueNotifier<bool?> externalServicesAllowed =
      ValueNotifier<bool?>(null);

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    final savedVersion = prefs.getInt(_consentVersionKey);

    if (savedVersion != _currentConsentVersion ||
        !prefs.containsKey(_externalServicesKey)) {
      externalServicesAllowed.value = null;
      return;
    }

    externalServicesAllowed.value =
        prefs.getBool(_externalServicesKey) ?? false;
  }

  Future<void> acceptAll() async {
    await _saveConsent(true);
  }

  Future<void> rejectAll() async {
    await _saveConsent(false);
  }

  Future<void> setExternalServicesAllowed(bool allowed) async {
    await _saveConsent(allowed);
  }

  Future<void> _saveConsent(bool allowed) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      _externalServicesKey,
      allowed,
    );

    await prefs.setInt(
      _consentVersionKey,
      _currentConsentVersion,
    );

    externalServicesAllowed.value = allowed;
  }
}