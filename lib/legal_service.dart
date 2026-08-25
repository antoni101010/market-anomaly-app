import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';
import 'legal_content.dart';

class LegalService {
  static const String _installationKey = 'legal_installation_id';
  static const String _termsAcceptedKey = 'legal_terms_accepted_version';
  static const String _privacySeenKey = 'legal_privacy_seen_version';
  static const String _acceptedAtKey = 'legal_accepted_at';

  static final LegalService instance = LegalService._();
  LegalService._();

  String? _installationId;
  String? _acceptedTermsVersion;
  String? _privacySeenVersion;
  String? _acceptedAt;

  String get installationId => _installationId ?? '';
  String? get acceptedAt => _acceptedAt;

  bool get hasAcceptedCurrent =>
      _acceptedTermsVersion == LegalContent.termsVersion &&
      _privacySeenVersion == LegalContent.privacyVersion;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _installationId = prefs.getString(_installationKey);
    if (_installationId == null || _installationId!.length < 8) {
      final random = Random.secure();
      _installationId =
          '${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}-'
          '${random.nextInt(1 << 31).toRadixString(36)}-'
          '${random.nextInt(1 << 31).toRadixString(36)}';
      await prefs.setString(_installationKey, _installationId!);
    }
    _acceptedTermsVersion = prefs.getString(_termsAcceptedKey);
    _privacySeenVersion = prefs.getString(_privacySeenKey);
    _acceptedAt = prefs.getString(_acceptedAtKey);
  }

  Future<void> acceptCurrent() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().toUtc().toIso8601String();
    await prefs.setString(_termsAcceptedKey, LegalContent.termsVersion);
    await prefs.setString(_privacySeenKey, LegalContent.privacyVersion);
    await prefs.setString(_acceptedAtKey, now);
    _acceptedTermsVersion = LegalContent.termsVersion;
    _privacySeenVersion = LegalContent.privacyVersion;
    _acceptedAt = now;
    await syncAcceptanceBestEffort();
  }

  Future<bool> syncAcceptanceBestEffort() async {
    if (!hasAcceptedCurrent || !ApiClient.instance.isConfigured) return false;
    try {
      await ApiClient.instance.recordLegalAcceptance(
        installationId: installationId,
        termsVersion: LegalContent.termsVersion,
        privacyVersion: LegalContent.privacyVersion,
        appVersion: '2.2.0',
        platform: 'flutter-mobile',
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> deleteInstallationData() async {
    if (ApiClient.instance.isConfigured && installationId.isNotEmpty) {
      await ApiClient.instance.deleteLegalInstallation(installationId);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_termsAcceptedKey);
    await prefs.remove(_privacySeenKey);
    await prefs.remove(_acceptedAtKey);
    _acceptedTermsVersion = null;
    _privacySeenVersion = null;
    _acceptedAt = null;
  }
}
