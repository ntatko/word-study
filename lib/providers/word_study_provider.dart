import 'package:flutter/material.dart';
import '../models/word_study_model.dart';
import '../services/hive_service.dart';

class WordStudyProvider with ChangeNotifier {
  WordStudy? _currentStudy;
  List<WordStudy> _studies = [];
  bool _isLoading = false;
  String? _error;

  WordStudy? get currentStudy => _currentStudy;
  List<WordStudy> get studies => _studies;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadStudies() async {
    _setLoading(true);
    try {
      _studies = HiveService.getAllWordStudies();
      _error = null;
    } catch (e) {
      _error = 'Failed to load studies: $e';
    } finally {
      _setLoading(false);
    }
  }

  void startNewStudy({
    required String passageReference,
    String? lessonName,
    String? studySource,
  }) {
    _currentStudy = WordStudy(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      passageReference: passageReference,
      selectedWord: '',
      createdAt: DateTime.now(),
      lessonName: lessonName,
      studySource: studySource,
    );
    notifyListeners();
  }

  void updateSelectedWord(String word) {
    if (_currentStudy != null) {
      _currentStudy = _currentStudy!.copyWith(selectedWord: word);
      _autoSaveStudy();
      notifyListeners();
    }
  }

  void updateNotes(String notes) {
    if (_currentStudy != null) {
      _currentStudy = _currentStudy!.copyWith(notes: notes);
      _autoSaveStudy();
      notifyListeners();
    }
  }

  void updateDefinition(String definition, String source) {
    if (_currentStudy != null) {
      _currentStudy = _currentStudy!.copyWith(
        chosenDefinition: definition,
        definitionSource: source,
      );
      _autoSaveStudy();
      notifyListeners();
    }
  }

  void updateBiblicalLanguage(String word, String definition) {
    if (_currentStudy != null) {
      _currentStudy = _currentStudy!.copyWith(
        biblicalLanguageWord: word,
        biblicalLanguageDefinition: definition,
      );
      _autoSaveStudy();
      notifyListeners();
    }
  }

  void updateCrossReferences(List<String> references) {
    if (_currentStudy != null) {
      _currentStudy = _currentStudy!.copyWith(crossReferences: references);
      _autoSaveStudy();
      notifyListeners();
    }
  }

  void updateRefinedDefinition(String definition) {
    if (_currentStudy != null) {
      _currentStudy = _currentStudy!.copyWith(refinedDefinition: definition);
      _autoSaveStudy();
      notifyListeners();
    }
  }

  Future<void> saveCurrentStudy() async {
    if (_currentStudy == null) return;

    _setLoading(true);
    try {
      await HiveService.saveWordStudy(_currentStudy!);
      await loadStudies();
      _currentStudy = null;
      _error = null;
    } catch (e) {
      _error = 'Failed to save study: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteStudy(String id) async {
    _setLoading(true);
    try {
      await HiveService.deleteWordStudy(id);
      await loadStudies();
      _error = null;
    } catch (e) {
      _error = 'Failed to delete study: $e';
    } finally {
      _setLoading(false);
    }
  }

  void resumeStudy(WordStudy study) {
    _currentStudy = study;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> _autoSaveStudy() async {
    if (_currentStudy == null) return;

    try {
      await HiveService.saveWordStudy(_currentStudy!);
    } catch (e) {
      // Silent fail for auto-save - don't show error to user
      // Auto-save failures are not critical enough to show to user
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
