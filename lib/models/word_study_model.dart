import 'package:hive/hive.dart';

part 'word_study_model.g.dart';

@HiveType(typeId: 0)
class WordStudy extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String passageReference;

  @HiveField(2)
  String selectedWord;

  @HiveField(3)
  String? chosenDefinition;

  @HiveField(4)
  String? definitionSource;

  @HiveField(5)
  String? biblicalLanguageWord;

  @HiveField(6)
  String? biblicalLanguageDefinition;

  @HiveField(7)
  List<String>? crossReferences;

  @HiveField(8)
  String? notes;

  @HiveField(9)
  String? refinedDefinition;

  @HiveField(10)
  DateTime createdAt;

  @HiveField(11)
  String? lessonName;

  @HiveField(12)
  String? studySource;

  WordStudy({
    required this.id,
    required this.passageReference,
    required this.selectedWord,
    this.chosenDefinition,
    this.definitionSource,
    this.biblicalLanguageWord,
    this.biblicalLanguageDefinition,
    this.crossReferences,
    this.notes,
    this.refinedDefinition,
    required this.createdAt,
    this.lessonName,
    this.studySource,
  });

  WordStudy copyWith({
    String? id,
    String? passageReference,
    String? selectedWord,
    String? chosenDefinition,
    String? definitionSource,
    String? biblicalLanguageWord,
    String? biblicalLanguageDefinition,
    List<String>? crossReferences,
    String? notes,
    String? refinedDefinition,
    DateTime? createdAt,
    String? lessonName,
    String? studySource,
  }) {
    return WordStudy(
      id: id ?? this.id,
      passageReference: passageReference ?? this.passageReference,
      selectedWord: selectedWord ?? this.selectedWord,
      chosenDefinition: chosenDefinition ?? this.chosenDefinition,
      definitionSource: definitionSource ?? this.definitionSource,
      biblicalLanguageWord: biblicalLanguageWord ?? this.biblicalLanguageWord,
      biblicalLanguageDefinition:
          biblicalLanguageDefinition ?? this.biblicalLanguageDefinition,
      crossReferences: crossReferences ?? this.crossReferences,
      notes: notes ?? this.notes,
      refinedDefinition: refinedDefinition ?? this.refinedDefinition,
      createdAt: createdAt ?? this.createdAt,
      lessonName: lessonName ?? this.lessonName,
      studySource: studySource ?? this.studySource,
    );
  }
}
