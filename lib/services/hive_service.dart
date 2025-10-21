import 'package:hive_flutter/hive_flutter.dart';
import '../models/word_study_model.dart';
import '../models/passage_model.dart';
import '../utils/constants.dart';

class HiveService {
  static late Box<WordStudy> _wordStudiesBox;
  static late Box<Passage> _passagesBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(WordStudyAdapter());
    Hive.registerAdapter(PassageAdapter());

    // Open boxes
    _wordStudiesBox = await Hive.openBox<WordStudy>(
      AppConstants.wordStudiesBoxName,
    );
    _passagesBox = await Hive.openBox<Passage>(AppConstants.passagesBoxName);
  }

  // WordStudy methods
  static Future<void> saveWordStudy(WordStudy wordStudy) async {
    await _wordStudiesBox.put(wordStudy.id, wordStudy);
  }

  static WordStudy? getWordStudy(String id) {
    return _wordStudiesBox.get(id);
  }

  static List<WordStudy> getAllWordStudies() {
    return _wordStudiesBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static Future<void> deleteWordStudy(String id) async {
    await _wordStudiesBox.delete(id);
  }

  // Passage methods
  static Future<void> savePassages(List<Passage> passages) async {
    await _passagesBox.clear();
    for (final passage in passages) {
      await _passagesBox.put(passage.id, passage);
    }
  }

  static List<Passage> getAllPassages() {
    return _passagesBox.values.toList()
      ..sort((a, b) => a.rollout.compareTo(b.rollout));
  }

  static void close() {
    _wordStudiesBox.close();
    _passagesBox.close();
  }
}
