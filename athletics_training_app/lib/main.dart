import 'package:athletics_training_app/services/notification_service.dart';
import 'package:athletics_training_app/services/training_service.dart';
import 'package:athletics_training_app/widget/create_training_session.dart';
import 'package:athletics_training_app/widget/show_notification_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/training_session.dart';
import 'screens/training_session_player.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TrainingSessionAdapter());
  Hive.registerAdapter(ExerciseAdapter());
  await Hive.openBox<TrainingSession>('training_sessions');

  // Initialize the notification service
  await NotificationService().initNotifications();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Athletics Training App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => TrainingApp(),
        '/training': (context) => const TrainingApp(),
        '/exercises': (context) => const CreateTrainingSession(),
      },
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
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    List<TrainingSession> sessions = _trainingService.getAllSessions();

    return Scaffold(
      appBar: AppBar(title: const Text("Sessions d'entraînement")),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Center(
                child: IconButton(
                  icon: Image.asset(
                    "assets/icons/playstore.png",
                    width: 300,
                    height: 300,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.directions_run),
              title: Text("Entrainement"),
              onTap: () {
                Navigator.pushNamed(context, '/exercises');
              },
            ),
            ListTile(
              leading: Icon(Icons.fitness_center),
              title: Text("Exercices"),
              onTap: () {
                Navigator.pushNamed(context, '/training');
              },
            ),
          ],
        ),
      ),
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
            child: const Text("Créer une nouvelle session"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                return ListTile(
                  title: Text(session.name),
                  subtitle: Text("${session.exercises.length} exercices"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon:
                            const Icon(Icons.notifications, color: Colors.blue),
                        onPressed: () {
                          showNotificationDialog(context, session);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await _trainingService.deleteTrainingSession(session);
                          setState(() {});
                        },
                      ),
                    ],
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