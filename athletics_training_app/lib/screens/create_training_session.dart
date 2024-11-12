import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../services/training_service.dart';
import '../models/training_session.dart';

class CreateTrainingSession extends StatefulWidget {
  const CreateTrainingSession({super.key});

  @override
  _CreateTrainingSessionState createState() => _CreateTrainingSessionState();
}

class _CreateTrainingSessionState extends State<CreateTrainingSession> {
  final TrainingService _trainingService = TrainingService();
  final Uuid _uuid = Uuid();

  String _selectedType = "Footing";
  final List<Exercise> _exercises = [];
  final TextEditingController _sessionNameController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController();
  final TextEditingController _secondsController = TextEditingController();

  // Liste des types de course
  final List<String> _types = [
    "Récupération",
    "Footing",
    "Vitesse moyenne",
    "Allure soutenue"
  ];

  void _addExercise() {
    int minutes = int.tryParse(_minutesController.text) ?? 0;
    int seconds = int.tryParse(_secondsController.text) ?? 0;
    int totalDuration = (minutes * 60) + seconds;

    if (totalDuration <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veuillez entrer une durée valide.")),
      );
      return;
    }

    final exercise = Exercise(
      description: _selectedType,
      duration: totalDuration,
      recovery: 0, // Valeur par défaut
    );

    setState(() {
      _exercises.add(exercise);
    });

    _minutesController.clear();
    _secondsController.clear();
  }

  void _saveTrainingSession() async {
    if (_sessionNameController.text.isEmpty || _exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Veuillez entrer un nom et ajouter au moins un exercice.")),
      );
      return;
    }

    final sessionId = _uuid.v4();
    final session = TrainingSession(
      name: _sessionNameController.text,
      exercises: _exercises,
      id: sessionId,
    );

    await _trainingService.addTrainingSession(session);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Créer une session d'entraînement")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _sessionNameController,
              decoration: InputDecoration(
                labelText: "Nom de la session",
              ),
            ),
            SizedBox(height: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _minutesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Minutes",
                    suffixText: "min",
                  ),
                ),
                SizedBox(width: 10),
                TextField(
                  controller: _secondsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Secondes",
                    suffixText: "sec",
                  ),
                ),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: _selectedType,
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                    });
                  },
                  items: _types.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addExercise,
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _exercises.length,
                itemBuilder: (context, index) {
                  final exercise = _exercises[index];
                  int minutes = exercise.duration ~/ 60;
                  int seconds = exercise.duration % 60;
                  return ListTile(
                    title: Text(
                        "${exercise.description} - $minutes min $seconds sec"),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _saveTrainingSession,
              child: Text("Enregistrer la session"),
            ),
          ],
        ),
      ),
    );
  }
}
