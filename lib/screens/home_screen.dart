import 'package:flutter/material.dart';
import '../data/symptoms.dart';
import '../engine/checker.dart';
import '../models/user.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget{
  final UserModel user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

}

class _HomeScreenState extends State<HomeScreen> {
  List<String> selected = [];

  final Map<String, IconData> symptomIcons = {
    "Fever": Icons.thermostat,
    "cough": Icons.sick,
    "Fatigue": Icons.battery_alert,
    "Headache": Icons.psychology,
    "Nausea": Icons.sick_outlined,
    "Loss Smell": Icons.face,
    "Sneezing": Icons.air,
    "Runny Nose": Icons.face_2_rounded,
    "Sore Throat": Icons.record_voice_over,
    "Body Pain": Icons.accessibility_new,
    "Diarrhea": Icons.water_drop,
    "Rash": Icons.bug_report,
    "Dizziness": Icons.sync_problem,
    "Chest Pain": Icons.favorite,
    "Breathing Issue": Icons.air_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(title: const Text("Select Symptoms"),),
      body: Column(
        children: [
          Expanded(child: ListView.builder(
              itemCount: symptomsList.length,
              itemBuilder: (context, index)
              {
                final symptom = symptomsList[index];
                return CheckboxListTile(
                  secondary: Icon(
                    symptomIcons[symptom] ?? Icons.health_and_safety,
                  ),
                  title: Text(symptom),
                  value: selected.contains(symptom),
                  onChanged: (value){
                    setState(() {
                      if (selected.contains(symptom)){
                        selected.remove(symptom);
                      }
                      else {
                        selected.add(symptom);
                      }
                    });
                  },
                );
              }
          )
          ),
          Padding(
            padding: const EdgeInsets.all(16),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Colors.teal, Colors.green],
              ),
              borderRadius: BorderRadius.circular(12),
            ),

            child: MaterialButton(onPressed: () async {
              if (selected.isEmpty)
                {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("please select at least one symptom"),
                    ),
                  );
                  return;
                }
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(child: CircularProgressIndicator(),
                ),
              );

              await Future.delayed(const Duration(seconds: 1));

              final result = checkDisease(selected);

              Navigator.pop(context);

              Navigator.push(
                context,
                  MaterialPageRoute(
                      builder: (_) => ResultScreen(
                          results: result,
                          selectedSymptoms: selected,
                          user: widget.user,
                      ),
                  ),
              );



            },
              child: const Text("Check Condition",
                style: TextStyle(
                    color: Colors.white, fontSize: 16
                ),
              ),
            ),
          ),

          ),
        ],
      ),
    );
  }

}