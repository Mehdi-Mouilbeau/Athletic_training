import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class PerformanceChart extends StatelessWidget {
  final List<Map<String, dynamic>> performances;

  const PerformanceChart({super.key, required this.performances});

  @override
  Widget build(BuildContext context) {
    final spots = performances.asMap().entries.map((entry) {
      final performance = entry.value;
      // Format the date string to a DateTime object
      final date = _parseDate(performance['date']);
      final time = double.tryParse(performance['performance']) ?? 0;

      // Return FlSpot with DateTime's milliseconds as X-axis value and performance as Y-axis value
      return FlSpot(date, time);
    }).toList();

    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(show: true),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 3,
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }

  // Helper function to parse the date string into DateTime object
  double _parseDate(String date) {
    try {
      // Parse the date from dd-MM-yyyy format to DateTime
      DateTime parsedDate = DateFormat("dd-MM-yyyy").parse(date);
      // Return the DateTime as millisecondsSinceEpoch (a numeric value for the X-axis)
      return parsedDate.millisecondsSinceEpoch.toDouble();
    } catch (e) {
      print("Error parsing date: $e");
      return 0; // Default to zero if there's an error
    }
  }
}
