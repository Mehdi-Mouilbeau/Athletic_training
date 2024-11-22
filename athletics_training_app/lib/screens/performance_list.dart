import 'package:athletics_training_app/models/db_helper.dart';
import 'package:flutter/material.dart';

class PerformanceList extends StatefulWidget {
  const PerformanceList({super.key});

  @override
  _PerformanceListState createState() => _PerformanceListState();
}

class _PerformanceListState extends State<PerformanceList> {
  List<Map<String, dynamic>> _performances = [];

  @override
  void initState() {
    super.initState();
    _loadPerformances();
  }

  Future<void> _loadPerformances() async {
    final data = await DBHelper().getPerformances();
    print("Performances récupérées : $data");
    setState(() {
      _performances = data;
    });
  }

  void _deletePerformance(int id) async {
    await DBHelper().deletePerformance(id);
    _loadPerformances();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Performances")),
      body: ListView.builder(
        itemCount: _performances.length,
        itemBuilder: (context, index) {
          final performance = _performances[index];
          return ListTile(
            title: Text(
                "${performance['discipline']} (${performance['category']})"),
            subtitle:
                Text("${performance['performance']} - ${performance['date']}"),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deletePerformance(performance['id']),
            ),
          );
        },
      ),
    );
  }
}
