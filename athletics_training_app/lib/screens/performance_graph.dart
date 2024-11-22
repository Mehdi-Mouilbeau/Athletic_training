import 'package:flutter/material.dart';
import 'package:athletics_training_app/models/db_helper.dart';
import 'package:athletics_training_app/widget/performance_chart.dart';

class PerformanceGraphPage extends StatefulWidget {
  const PerformanceGraphPage({super.key});

  @override
  _PerformanceGraphPageState createState() => _PerformanceGraphPageState();
}

class _PerformanceGraphPageState extends State<PerformanceGraphPage> {
  List<Map<String, dynamic>> _performances = [];

  @override
  void initState() {
    super.initState();
    _loadPerformances();
  }

  // Function to load performances from the database
  Future<void> _loadPerformances() async {
    try {
      final data = await DBHelper().getPerformances();
      print("Performances récupérées : $data");
      setState(() {
        _performances = data;
      });
    } catch (e) {
      print("Error loading performances: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Graphique des performances")),
      body: _performances.isEmpty
          ? const Center(child: Text("Aucune performance enregistrée."))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: PerformanceChart(performances: _performances),
            ),
    );
  }
}
