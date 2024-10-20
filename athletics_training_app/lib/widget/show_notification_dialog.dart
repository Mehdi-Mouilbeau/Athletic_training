import 'package:flutter/material.dart';
import '../models/training_session.dart';
import '../services/notification_service.dart';

Future<void> showNotificationDialog(
    BuildContext context, TrainingSession session) async {
  final TextEditingController timeController = TextEditingController();
  final TextEditingController durationController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Programmer Notification"),
        content: SingleChildScrollView(
          // Add SingleChildScrollView for better scrolling behavior
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: timeController,
                decoration: InputDecoration(labelText: 'Heure (HH:MM)'),
                keyboardType:
                    TextInputType.datetime, // Specify input type for better UX
              ),
              TextField(
                controller: durationController,
                decoration: InputDecoration(labelText: 'Durée (en secondes)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (timeController.text.isNotEmpty) {
                var timeParts = timeController.text.split(":");
                if (timeParts.length == 2) {
                  try {
                    int hours = int.parse(timeParts[0]);
                    int minutes = int.parse(timeParts[1]);

                    if (hours < 0 ||
                        hours > 23 ||
                        minutes < 0 ||
                        minutes > 59) {
                      throw FormatException();
                    }

                    DateTime scheduledTime = DateTime.now().add(
                      Duration(hours: hours, minutes: minutes),
                    );

                    await NotificationService().scheduleNotification(
                      session.id as int, 
                      'Rappel d\'entraînement',
                      'Il est temps de commencer votre session : ${session.name}',
                      scheduledTime,
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text("Veuillez entrer une heure valide")),
                    );
                  }
                }
              }

              if (durationController.text.isNotEmpty) {
                try {
                  int seconds = int.parse(durationController.text);
                  if (seconds < 0) throw FormatException();

                  await NotificationService().scheduleNotificationWithDuration(
                    session.id as int,
                    'Rappel d\'entraînement',
                    'Il est temps de commencer votre session : ${session.name}',
                    Duration(seconds: seconds),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Veuillez entrer une durée valide")),
                  );
                }
              }

              Navigator.of(context).pop(); // Close the dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Notification programmée")),
              );
            },
            child: Text("Programmer"),
          ),
        ],
      );
    },
  );
}
