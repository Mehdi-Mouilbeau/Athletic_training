import 'package:hive/hive.dart';
import '../models/training_session.dart';

class TrainingService {
  final Box<TrainingSession> _trainingBox =
      Hive.box<TrainingSession>('training_sessions');

  // Ajouter une session d'entraînement
  Future<void> addTrainingSession(TrainingSession session) async {
    await _trainingBox.add(session);
  }

  // Récupérer toutes les sessions
  List<TrainingSession> getAllSessions() {
    return _trainingBox.values.toList();
  }

  // Supprimer une session
  Future<void> deleteSession(int index) async {
    await _trainingBox.deleteAt(index);
  }
  
  Future<void> deleteTrainingSession(TrainingSession session) async {
    final key = session.key as int;
    await _trainingBox.delete(key);
  }

  // Mettre à jour une session
  Future<void> updateSession(int index, TrainingSession updatedSession) async {
    await _trainingBox.putAt(index, updatedSession);
  }
}
