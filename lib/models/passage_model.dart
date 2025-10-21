import 'package:hive/hive.dart';

part 'passage_model.g.dart';

@HiveType(typeId: 1)
class Passage extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String passage;

  @HiveField(2)
  String study;

  @HiveField(3)
  String lesson;

  @HiveField(4)
  DateTime rollout;

  Passage({
    required this.id,
    required this.passage,
    required this.study,
    required this.lesson,
    required this.rollout,
  });

  factory Passage.fromJson(Map<String, dynamic> json) {
    return Passage(
      id: json['id'] as int,
      passage: json['passage'] as String,
      study: json['study'] as String,
      lesson: json['lesson'] as String,
      rollout: DateTime.parse(json['rollout'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'passage': passage,
      'study': study,
      'lesson': lesson,
      'rollout': rollout.toIso8601String(),
    };
  }
}
