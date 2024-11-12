import 'package:athletics_training_app/screens/home_page.dart';
import 'package:athletics_training_app/services/notification_service.dart';
import 'package:athletics_training_app/services/training_service.dart';
import 'package:athletics_training_app/screens/create_training_session.dart';
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
        '/': (context) => HomePage(),
        '/training': (context) => const TrainingApp(),
        '/exercises': (context) => const CreateTrainingSession(),
      },
    );
  }
}

// HomePage avec le Drawer pour le menu burger
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accueil'),
        centerTitle: true,
      ),
      drawer: AppDrawer(), // Drawer centralisé dans AppDrawer
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bienvenue dans votre application d\'entraînement sportif!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'Préparez, programmez et suivez vos séances facilement.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Drawer centralisé pour éviter la répétition dans chaque page
class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Center(
              child: IconButton(
                icon: Image.asset(
                  "assets/icons/playstore.png",
                  width: 100,
                  height: 100,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text("Accueil"),
            onTap: () {
              Navigator.pushNamed(context, '/');
            },
          ),
          ListTile(
            leading: Icon(Icons.fitness_center),
            title: Text("Entrainement"),
            onTap: () {
              Navigator.pushNamed(context, '/exercises');
            },
          ),
          ListTile(
            leading: Icon(Icons.directions_run),
            title: Text("Sessions d'entraînement"),
            onTap: () {
              Navigator.pushNamed(context, '/training');
            },
          ),
        ],
      ),
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
      appBar: AppBar(
        title: Text("Sessions d'entraînement"),
        centerTitle: true,
      ),
      drawer: AppDrawer(), // Drawer ici aussi pour le menu burger
      body: Column(
        children: [
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
                          setState(() {}); // Rafraîchit la liste des sessions
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
