import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/training_service.dart';
import '../models/training_session.dart';
import '../screens/training_session_player.dart';
import '../widget/create_training_session.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TrainingSessionAdapter());
  Hive.registerAdapter(ExerciseAdapter());
  await Hive.openBox<TrainingSession>('training_sessions');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TrainingApp(),
    );
  }
}

class TrainingApp extends StatefulWidget {
  const TrainingApp({super.key});

  @override
  _TrainingAppState createState() => _TrainingAppState();
}

class _TrainingAppState extends State<TrainingApp> {
  final TrainingService _trainingService = TrainingService();

  @override
  Widget build(BuildContext context) {
    List<TrainingSession> sessions = _trainingService.getAllSessions();

    return Scaffold(
      appBar: AppBar(title: Text("Sessions d'entraînement")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CreateTrainingSession()),
              ).then((_) {
                setState(() {});
              });
            },
            child: Text("Créer une nouvelle session"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                return ListTile(
                  title: Text(session.name),
                  subtitle: Text("${session.exercises.length} exercices"),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await _trainingService.deleteTrainingSession(session);
                      setState(() {});
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TrainingSessionPlayer(session: session),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
