import 'package:flutter/material.dart';
import '../services/training_service.dart';
import '../models/training_session.dart';

class CreateTrainingSession extends StatefulWidget {
  const CreateTrainingSession({super.key});

  @override
  _CreateTrainingSessionState createState() => _CreateTrainingSessionState();
}

class _CreateTrainingSessionState extends State<CreateTrainingSession> {
  final TrainingService _trainingService = TrainingService();

  String _selectedDuration = "30"; // Durée par défaut
  String _selectedType = "Footing"; // Type par défaut

  final List<Exercise> _exercises = [];
  final TextEditingController _sessionNameController = TextEditingController();

  // Liste des options pour la durée
  final List<String> _durations = [
    "5",
    "10",
    "15",
    "20",
    "25",
    "30",
    "35",
    "40",
    "45",
    "50",
    "55",
    "60"
  ];

  // Liste des types de course
  final List<String> _types = [
    "Récupération",
    "Footing",
    "Vitesse moyenne",
    "Allure soutenue"
  ];

  void _addExercise() {
    final exercise = Exercise(
      description: _selectedType,
      duration: int.parse(_selectedDuration),
      recovery: 0, // Par défaut, vous pouvez ajouter un autre menu pour cela
    );

    setState(() {
      _exercises.add(exercise);
    });
  }

  void _saveTrainingSession() async {
    if (_sessionNameController.text.isEmpty || _exercises.isEmpty) {
      // Afficher un message d'erreur si le nom ou les exercices sont manquants
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Veuillez entrer un nom et ajouter au moins un exercice.")),
      );
      return;
    }

    final session = TrainingSession(
      name: _sessionNameController.text,
      exercises: _exercises,
    );

    await _trainingService.addTrainingSession(session);

    // Naviguer vers la page précédente après avoir enregistré la session
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
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedDuration,
                    onChanged: (value) {
                      setState(() {
                        _selectedDuration = value!;
                      });
                    },
                    items: _durations.map((duration) {
                      return DropdownMenuItem(
                        value: duration,
                        child: Text("$duration sec"),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<String>(
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
                  return ListTile(
                    title: Text(
                        "${exercise.description} - ${exercise.duration} sec"),
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
