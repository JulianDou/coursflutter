import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _performanceModeKey = 'performance_mode';

  Future<bool> getPerformanceMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_performanceModeKey) ?? false;
  }

  Future<void> setPerformanceMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_performanceModeKey, enabled);
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
