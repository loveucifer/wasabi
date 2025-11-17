import 'package:flutter/foundation.dart';
import 'package:wasabi/services/secure_storage_service.dart';

class ApiKeyProvider with ChangeNotifier {
  final SecureStorageService _storage = SecureStorageService.instance;

  String? _apiKey;
  bool _isLoading = false;
  String? _error;

  String? get apiKey => _apiKey;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasApiKey => _apiKey != null && _apiKey!.isNotEmpty;

  Future<void> loadApiKey() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _apiKey = await _storage.getApiKey();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveApiKey(String key) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _storage.saveApiKey(key);
      _apiKey = key;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteApiKey() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _storage.deleteApiKey();
      _apiKey = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
