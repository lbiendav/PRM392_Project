import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class SharedPrefsService {
  static SharedPrefsService? _instance;
  static SharedPreferences? _preferences;

  SharedPrefsService._();

  static Future<SharedPrefsService> getInstance() async {
    _instance ??= SharedPrefsService._();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // --- Onboarding ---
  bool get hasSeenOnboarding =>
      _preferences?.getBool(AppConstants.keyHasSeenOnboarding) ?? false;

  Future<bool> setHasSeenOnboarding(bool value) async {
    return await _preferences?.setBool(AppConstants.keyHasSeenOnboarding, value) ??
        false;
  }

  // --- Remember Me & Credentials ---
  bool get isRememberMe =>
      _preferences?.getBool(AppConstants.keyRememberMe) ?? false;

  Future<bool> setRememberMe(bool value) async {
    return await _preferences?.setBool(AppConstants.keyRememberMe, value) ??
        false;
  }

  String get savedEmail =>
      _preferences?.getString(AppConstants.keySavedEmail) ?? '';

  Future<bool> setSavedEmail(String email) async {
    return await _preferences?.setString(AppConstants.keySavedEmail, email) ??
        false;
  }

  String get savedPassword =>
      _preferences?.getString(AppConstants.keySavedPassword) ?? '';

  Future<bool> setSavedPassword(String password) async {
    return await _preferences?.setString(
          AppConstants.keySavedPassword,
          password,
        ) ??
        false;
  }

  Future<void> saveCredentials({
    required String email,
    required String password,
  }) async {
    await setRememberMe(true);
    await setSavedEmail(email);
    await setSavedPassword(password);
  }

  Future<void> clearSavedCredentials() async {
    await setRememberMe(false);
    await _preferences?.remove(AppConstants.keySavedEmail);
    await _preferences?.remove(AppConstants.keySavedPassword);
  }

  // --- Theme Mode ---
  String get themeMode =>
      _preferences?.getString(AppConstants.keyThemeMode) ?? 'light';

  Future<bool> setThemeMode(String mode) async {
    return await _preferences?.setString(AppConstants.keyThemeMode, mode) ??
        false;
  }

  // --- Search History ---
  List<String> get searchHistory =>
      _preferences?.getStringList(AppConstants.keySearchHistory) ?? [];

  Future<bool> addSearchKeyword(String keyword) async {
    final list = searchHistory;
    final trimmed = keyword.trim();
    if (trimmed.isEmpty) return false;
    list.remove(trimmed);
    list.insert(0, trimmed);
    if (list.length > 10) {
      list.removeRange(10, list.length);
    }
    return await _preferences?.setStringList(
          AppConstants.keySearchHistory,
          list,
        ) ??
        false;
  }

  Future<bool> clearSearchHistory() async {
    return await _preferences?.remove(AppConstants.keySearchHistory) ?? false;
  }
}
