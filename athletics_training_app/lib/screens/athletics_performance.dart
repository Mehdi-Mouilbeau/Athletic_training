import 'dart:convert';
import 'package:athletics_training_app/models/db_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AthleticsPerformance extends StatefulWidget {
  const AthleticsPerformance({super.key});

  @override
  _AthleticsPerformanceState createState() => _AthleticsPerformanceState();
}

class _AthleticsPerformanceState extends State<AthleticsPerformance> {
  Map<String, dynamic> _athleticsData = {};
  String? _selectedDiscipline;
  String? _selectedCategory;
  String? _selectedAgeCategory;
  String? _selectedAgeRange;
  final TextEditingController _performanceController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAthleticsData();
  }

  Future<void> _loadAthleticsData() async {
    final String response =
        await rootBundle.loadString('assets/athletics_data.json');
    final data = json.decode(response);
    setState(() {
      _athleticsData = data["Athletisme"];
    });
  }

  void _savePerformance() async {
    if (_selectedDiscipline == null ||
        _selectedCategory == null ||
        _performanceController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _selectedAgeCategory == null ||
        _selectedAgeRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs.")),
      );
      return;
    }

    // Format the date before saving
    String formattedDate = _formatDate(_dateController.text);

    final performance = {
      "discipline": _selectedDiscipline,
      "category": _selectedCategory,
      "age_category": _selectedAgeCategory,
      "age_range": _selectedAgeRange,
      "performance": _performanceController.text,
      "date": formattedDate, // Use the formatted date
    };

    // Save the performance using DBHelper
    await DBHelper().insertPerformance(performance);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Performance enregistrée avec succès !")),
    );

    // Reset the form fields
    setState(() {
      _selectedDiscipline = null;
      _selectedCategory = null;
      _selectedAgeCategory = null;
      _selectedAgeRange = null;
    });
    _performanceController.clear();
    _dateController.clear();
  }

  String _formatDate(String inputDate) {
    try {
      // Try to parse and format the date
      DateTime date = DateFormat("dd-MM-yyyy").parse(inputDate);
      return DateFormat("dd-MM-yyyy")
          .format(date); // Format the date as 'dd-MM-yyyy'
    } catch (e) {
      print("Error formatting date: $e");
      return ""; // Return an empty string if the date is invalid
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extraction des catégories d'âge principales
    List<String> ageCategories = [];
    _athleticsData["Categories_Age"]?.forEach((key, value) {
      ageCategories.add(key);
    });

    // Extraction des sous-catégories d'âge basées sur la catégorie sélectionnée
    Map<String, dynamic>? selectedAgeCategoryData;
    if (_selectedAgeCategory != null) {
      selectedAgeCategoryData =
          _athleticsData["Categories_Age"]?[_selectedAgeCategory];
    }

    // Extraction des sous-catégories (ex: "M0", "M1")
    List<String> ageRanges = [];
    if (selectedAgeCategoryData != null) {
      selectedAgeCategoryData.forEach((key, value) {
        ageRanges.add(key);
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Enregistrer une performance")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // DropdownButton pour la sélection d'une discipline
              DropdownButton<String>(
                isExpanded: true,
                hint: const Text("Sélectionnez une discipline"),
                value: _selectedDiscipline,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedDiscipline = newValue;
                    _selectedCategory = null; // Réinitialise la sous-discipline
                  });
                },
                items: _athleticsData["Courses"]
                    ?.keys
                    .map<DropdownMenuItem<String>>((discipline) {
                  return DropdownMenuItem<String>(
                    value: discipline,
                    child: Text(discipline),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // DropdownButton pour la sélection d'une sous-discipline (catégorie)
              if (_selectedDiscipline != null)
                DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text("Sélectionnez une catégorie"),
                  value: _selectedCategory,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  },
                  items: _athleticsData["Courses"]![_selectedDiscipline]
                      ?.map<DropdownMenuItem<String>>((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 16),

              // DropdownButton pour la catégorie principale d'âge
              DropdownButton<String>(
                isExpanded: true,
                hint: const Text("Sélectionnez une catégorie d'âge"),
                value: _selectedAgeCategory,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedAgeCategory = newValue;
                    _selectedAgeRange = null; // Réinitialise la sous-catégorie
                  });
                },
                items:
                    ageCategories.map<DropdownMenuItem<String>>((ageCategory) {
                  return DropdownMenuItem<String>(
                    value: ageCategory,
                    child: Text(ageCategory),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // DropdownButton pour la sous-catégorie d'âge
              if (_selectedAgeCategory != null)
                DropdownButton<String>(
                  isExpanded: true,
                  hint: Text("Sélectionnez une tranche d'âge"),
                  value: _selectedAgeRange,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedAgeRange = newValue;
                    });
                  },
                  items: selectedAgeCategoryData?.entries
                      .map<DropdownMenuItem<String>>((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text("${entry.key}: ${entry.value}"),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 16),

              // Champ pour entrer la performance
              TextField(
                controller: _performanceController,
                decoration: const InputDecoration(
                  labelText: "Performance (ex: 10.25 sec)",
                ),
              ),
              const SizedBox(height: 16),

              // Champ pour entrer la date
              TextField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: "Date (ex: 21-05-1982)",
                ),
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 20),

              // Bouton pour enregistrer la performance
              ElevatedButton(
                onPressed: _savePerformance,
                child: const Text("Enregistrer"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
