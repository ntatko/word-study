import 'package:flutter/foundation.dart';
import '../models/word_study_model.dart';
import '../services/hive_service.dart';

class HiveWordStudyProvider extends ChangeNotifier {
  WordStudy? _currentStudy;
  List<WordStudy> _studies = [];
  bool _isLoading = false;
  String? _error;

  WordStudy? get currentStudy => _currentStudy;
  List<WordStudy> get studies => _studies;
  bool get isLoading => _isLoading;
  String? get error => _error;

  HiveWordStudyProvider() {
    loadStudies();
  }

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

  void startNewStudy(
    String passageReference, {
    String? lessonName,
    String? studySource,
  }) {
    final study = WordStudy(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      passageReference: passageReference,
      selectedWord: '',
      createdAt: DateTime.now(),
      lessonName: lessonName,
      studySource: studySource,
    );

    _currentStudy = study;
    notifyListeners();
  }

  void resumeStudy(WordStudy study) {
    _currentStudy = study;
    notifyListeners();
  }

  // Auto-save methods that update the Hive object directly
  void updateSelectedWord(String word) {
    if (_currentStudy != null) {
      _currentStudy!.selectedWord = word;
      _currentStudy!.save(); // Auto-save to Hive
      notifyListeners();
    }
  }

  void updateNotes(String notes) {
    if (_currentStudy != null) {
      _currentStudy!.notes = notes;
      _currentStudy!.save(); // Auto-save to Hive
      notifyListeners();
    }
  }

  void updateDefinition(String definition, String source) {
    if (_currentStudy != null) {
      _currentStudy!.chosenDefinition = definition;
      _currentStudy!.definitionSource = source;
      _currentStudy!.save(); // Auto-save to Hive
      notifyListeners();
    }
  }

  void updateBiblicalLanguage(String word, String definition) {
    if (_currentStudy != null) {
      _currentStudy!.biblicalLanguageWord = word;
      _currentStudy!.biblicalLanguageDefinition = definition;
      _currentStudy!.save(); // Auto-save to Hive
      notifyListeners();
    }
  }

  void updateCrossReferences(List<String> references) {
    if (_currentStudy != null) {
      _currentStudy!.crossReferences = references;
      _currentStudy!.save(); // Auto-save to Hive
      notifyListeners();
    }
  }

  void updateRefinedDefinition(String definition) {
    if (_currentStudy != null) {
      _currentStudy!.refinedDefinition = definition;
      _currentStudy!.save(); // Auto-save to Hive
      notifyListeners();
    }
  }

  void updateContextThoughts(String thoughts) {
    if (_currentStudy != null) {
      _currentStudy!.contextThoughts = thoughts;
      _currentStudy!.save(); // Auto-save to Hive
      notifyListeners();
    }
  }

  void updateCrossReferencePassages(List<String> passages) {
    if (_currentStudy != null) {
      _currentStudy!.crossReferencePassages = passages;
      _currentStudy!.save(); // Auto-save to Hive
      notifyListeners();
    }
  }

  void updateCrossReferenceNotes(String notes) {
    if (_currentStudy != null) {
      _currentStudy!.crossReferenceNotes = notes;
      _currentStudy!.save(); // Auto-save to Hive
      notifyListeners();
    }
  }

  void updateOutsideSources(String sources) {
    if (_currentStudy != null) {
      _currentStudy!.outsideSources = sources;
      _currentStudy!.save(); // Auto-save to Hive
      notifyListeners();
    }
  }

  void updateSummary(String summary) {
    if (_currentStudy != null) {
      _currentStudy!.summary = summary;
      _currentStudy!.save(); // Auto-save to Hive
      notifyListeners();
    }
  }

  void updatePersonalResponse(String response) {
    if (_currentStudy != null) {
      _currentStudy!.personalResponse = response;
      _currentStudy!.save(); // Auto-save to Hive
      notifyListeners();
    }
  }

  Future<void> saveCurrentStudy() async {
    if (_currentStudy != null) {
      try {
        await HiveService.saveWordStudy(_currentStudy!);
        await loadStudies();
        _error = null;
      } catch (e) {
        _error = 'Failed to save study: $e';
      }
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

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Helper methods for step navigation
  int getCurrentStep(WordStudy study) {
    if (study.selectedWord.isEmpty) return 1;
    if (study.contextThoughts == null) return 2;
    if (study.crossReferences == null || study.crossReferences!.isEmpty) {
      return 3;
    }
    if (study.outsideSources == null) return 4;
    return 5; // Final notes step
  }

  bool isStudyCompleted(WordStudy study) {
    return study.selectedWord.isNotEmpty &&
        study.contextThoughts != null &&
        study.crossReferences != null &&
        study.crossReferences!.isNotEmpty &&
        study.outsideSources != null &&
        study.summary != null &&
        study.personalResponse != null;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
