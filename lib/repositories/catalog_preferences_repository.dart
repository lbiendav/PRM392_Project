import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

class CatalogPreferencesRepository {
  Future<List<String>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return List<String>.from(
      prefs.getStringList(AppConstants.keySearchHistory) ?? const [],
    );
  }

  Future<void> addKeyword(String keyword) async {
    final value = keyword.trim();
    if (value.isEmpty) return;
    final history = await getHistory();
    history.removeWhere((item) => item.toLowerCase() == value.toLowerCase());
    history.insert(0, value);
    await _saveHistory(history.take(10).toList());
  }

  Future<void> removeKeyword(String keyword) async {
    final history = await getHistory();
    history.removeWhere((item) => item.toLowerCase() == keyword.toLowerCase());
    await _saveHistory(history);
  }

  Future<void> clearHistory() => _saveHistory([]);

  Future<void> _saveHistory(List<String> history) async {
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setStringList(AppConstants.keySearchHistory, history)) {
      throw StateError('Không lưu được lịch sử tìm kiếm');
    }
  }

  Future<String?> getBranchId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyCatalogBranchId);
  }

  Future<void> setBranchId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString(AppConstants.keyCatalogBranchId, id)) {
      throw StateError('Không lưu được chi nhánh');
    }
  }
}
