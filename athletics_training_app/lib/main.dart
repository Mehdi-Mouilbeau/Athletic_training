import 'package:athletics_training_app/screens/athletics_performance.dart';
import 'package:athletics_training_app/screens/performance_graph.dart';
import 'package:athletics_training_app/screens/performance_list.dart';
import 'package:athletics_training_app/services/notification_service.dart';
import 'package:athletics_training_app/screens/create_training_session.dart';
import 'package:athletics_training_app/models/training_session.dart';
import 'package:athletics_training_app/services/training_service.dart';
import 'package:athletics_training_app/widget/show_notification_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/training_session_player.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TrainingSessionAdapter());
  Hive.registerAdapter(ExerciseAdapter());
  await Hive.openBox<TrainingSession>('training_sessions');

  // Initialize the notification service
  await NotificationService().initNotifications();

  runApp(const MyApp());
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
        '/': (context) => const HomePage(),
        '/training': (context) => const TrainingApp(),
        '/exercises': (context) => const CreateTrainingSession(),
        '/performance-list': (context) => const PerformanceList(),
        '/performance-graph': (context) => const PerformanceGraphPage(),
        '/performance-entry': (context) => const AthleticsPerformance(),
      },
    );
  }
}

// Accueil de l'application avec le menu Drawer
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
        centerTitle: true,
      ),
      drawer: const AppDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
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

// Drawer centralisé pour navigation
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(context),
          _buildDrawerItem(
            context,
            icon: Icons.home,
            title: "Accueil",
            route: '/',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.fitness_center,
            title: "Entraînement",
            route: '/exercises',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.directions_run,
            title: "Sessions d'entraînement",
            route: '/training',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.bar_chart,
            title: "Graphiques des performances",
            route: '/performance-graph',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.list_alt,
            title: "Liste des performances",
            route: '/performance-list',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.add,
            title: "Enregistrer Performance",
            route: '/performance-entry',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return DrawerHeader(
      decoration: const BoxDecoration(color: Colors.blue),
      child: Center(
        child: IconButton(
          icon: Image.asset(
            "assets/icons/playstore.png",
            width: 100,
            height: 100,
          ),
          onPressed: () {
            Navigator.pop(context); // Ferme le Drawer sans changer la page
          },
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context,
      {required IconData icon, required String title, required String route}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // Ferme le Drawer avant de naviguer
        Navigator.pushNamed(context, route);
      },
    );
  }
}

// Affichage des sessions d'entraînement
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
        title: const Text("Sessions d'entraînement"),
        centerTitle: true,
      ),
      drawer: const AppDrawer(),
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
