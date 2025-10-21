import 'package:flutter/material.dart';
import '../models/passage_model.dart';
import '../services/passages_api_service.dart';
import '../services/hive_service.dart';

class PassagesProvider with ChangeNotifier {
  List<Passage> _passages = [];
  bool _isLoading = false;
  String? _error;

  List<Passage> get passages => _passages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPassages({bool forceRefresh = false}) async {
    _setLoading(true);
    try {
      // Try to load from cache first
      if (!forceRefresh) {
        _passages = HiveService.getAllPassages();
        if (_passages.isNotEmpty) {
          _error = null;
          _setLoading(false);
          return;
        }
      }

      // Fetch from API
      final fetchedPassages = await PassagesApiService.fetchPassages();

      // Save to cache
      await HiveService.savePassages(fetchedPassages);

      _passages = fetchedPassages;
      _error = null;
    } catch (e) {
      _error = 'Failed to load passages: $e';
      // Try to load from cache as fallback
      _passages = HiveService.getAllPassages();
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
