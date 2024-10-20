import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import '../models/training_session.dart';

class TrainingSessionPlayer extends StatefulWidget {
  final TrainingSession session;

  const TrainingSessionPlayer({super.key, required this.session});

  @override
  _TrainingSessionPlayerState createState() => _TrainingSessionPlayerState();
}

class _TrainingSessionPlayerState extends State<TrainingSessionPlayer> {
  Timer? _timer;
  int _currentExerciseIndex = 0;
  int _remainingSeconds = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _startExercise();
    _audioPlayer.setVolume(1.0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startExercise() {
    if (_currentExerciseIndex < widget.session.exercises.length) {
      final exercise = widget.session.exercises[_currentExerciseIndex];
      _remainingSeconds = exercise.duration;

      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          _remainingSeconds--;

          if (_remainingSeconds == 1) {
            _playNotificationSound();
          }

          if (_remainingSeconds <= 0) {
            timer.cancel();
            _nextExercise();
          }
        });
      });
    } else {
      _endSession();
    }
  }

  void _nextExercise() {
    _currentExerciseIndex++;
    _startExercise();
  }

  void _endSession() {
    // Logic to handle end of the training session
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Session terminée"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text("OK"),
          )
        ],
      ),
    );
  }

  void _playNotificationSound() async {
    if (_audioPlayer.state == PlayerState.playing) {
      await _audioPlayer.stop();
    }
    await _audioPlayer.play(AssetSource('sounds/notification.mp3'));
  }

  @override
  Widget build(BuildContext context) {
    if (_currentExerciseIndex >= widget.session.exercises.length) {
      return Scaffold(
        body: Center(child: Text("Session terminée")),
      );
    }

    final exercise = widget.session.exercises[_currentExerciseIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text("Entraînement en cours"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Exercice : ${exercise.description}",
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(height: 20),
          Text(
            "Temps restant : $_remainingSeconds sec",
            style: TextStyle(fontSize: 32),
          ),
        ],
      ),
    );
  }
}
