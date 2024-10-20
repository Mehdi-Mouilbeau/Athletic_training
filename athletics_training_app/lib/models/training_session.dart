import 'package:hive/hive.dart';

part 'training_session.g.dart';

@HiveType(typeId: 0)
class TrainingSession extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  List<Exercise> exercises;

  TrainingSession({required this.name, required this.exercises});
}

@HiveType(typeId: 1)
class Exercise extends HiveObject {
  @HiveField(0)
  String description;

  @HiveField(1)
  int duration;

  @HiveField(2)
  int recovery;

  Exercise(
      {required this.description,
      required this.duration,
      required this.recovery});
}
