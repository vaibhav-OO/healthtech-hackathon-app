// import 'package:flutter/material.dart';
// import '../data/symptoms.dart';
// import '../engine/checker.dart';
// import '../models/user.dart';
// import 'result_screen.dart';
//
// class HomeScreen extends StatefulWidget{
//   final UserModel user;
//   final VoidCallback toggleTheme;
//
//   const HomeScreen({
//     super.key,
//     required this.user,
//     required this.toggleTheme
//   });
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
//
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   List<String> selected = [];
//
//   final Map<String, IconData> symptomIcons = {
//     "Fever": Icons.thermostat,
//     "cough": Icons.sick,
//     "Fatigue": Icons.battery_alert,
//     "Headache": Icons.psychology,
//     "Nausea": Icons.sick_outlined,
//     "Loss Smell": Icons.face,
//     "Sneezing": Icons.air,
//     "Runny Nose": Icons.face_2_rounded,
//     "Sore Throat": Icons.record_voice_over,
//     "Body Pain": Icons.accessibility_new,
//     "Diarrhea": Icons.water_drop,
//     "Rash": Icons.bug_report,
//     "Dizziness": Icons.sync_problem,
//     "Chest Pain": Icons.favorite,
//     "Breathing Issue": Icons.air_outlined,
//   };
//
//   @override
//   Widget build(BuildContext context) {
//     return  Scaffold(
//       appBar: AppBar(title: const Text("Select Symptoms"),),
//       body: Column(
//         children: [
//           Expanded(child: ListView.builder(
//               itemCount: symptomsList.length,
//               itemBuilder: (context, index)
//               {
//                 final symptom = symptomsList[index];
//                 return CheckboxListTile(
//                   secondary: Icon(
//                     symptomIcons[symptom] ?? Icons.health_and_safety,
//                   ),
//                   title: Text(symptom),
//                   value: selected.contains(symptom),
//                   onChanged: (value){
//                     setState(() {
//                       if (selected.contains(symptom)){
//                         selected.remove(symptom);
//                       }
//                       else {
//                         selected.add(symptom);
//                       }
//                     });
//                   },
//                 );
//               }
//           )
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16),
//           child: Container(
//             width: double.infinity,
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                   colors: [Colors.teal, Colors.green],
//               ),
//               borderRadius: BorderRadius.circular(12),
//             ),
//
//             child: MaterialButton(onPressed: () async {
//               if (selected.isEmpty)
//                 {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text("please select at least one symptom"),
//                     ),
//                   );
//                   return;
//                 }
//               showDialog(
//                 context: context,
//                 barrierDismissible: false,
//                 builder: (_) => const Center(child: CircularProgressIndicator(),
//                 ),
//               );
//
//               await Future.delayed(const Duration(seconds: 1));
//
//               final result = checkDisease(selected);
//
//               Navigator.pop(context);
//
//               Navigator.push(
//                 context,
//                   MaterialPageRoute(
//                       builder: (_) => ResultScreen(
//                           results: result,
//                           selectedSymptoms: selected,
//                           user: widget.user,
//                       ),
//                   ),
//               );
//             },
//               child: const Text("Check Condition",
//                 style: TextStyle(
//                     color: Colors.white, fontSize: 16
//                 ),
//               ),
//             ),
//           ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import '../data/symptoms.dart';
import '../engine/checker.dart';
import '../models/user.dart';
import '../widgets/gradient_button.dart';
import '../main.dart';
import 'result_screen.dart';
import 'profile_screen.dart';
import 'history_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class HomeScreen extends StatefulWidget {
  final UserModel user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> selected = [];
  late stt.SpeechToText speech;
  bool isListening = false;
  String spokenText = "";

  final Map<String, IconData> symptomIcons = {
    "Fever": Icons.thermostat,
    "Cough": Icons.sick,
    "Fatigue": Icons.battery_alert,
    "Headache": Icons.psychology,
    "Nausea": Icons.sick_outlined,
    "Loss Smell": Icons.face,
    "Sneezing": Icons.air,
    "Runny Nose": Icons.face_2,
    "Sore Throat": Icons.record_voice_over,
    "Body Pain": Icons.accessibility_new,
    "Diarrhea": Icons.water_drop,
    "Rash": Icons.bug_report,
    "Dizziness": Icons.sync_problem,
    "Chest Pain": Icons.favorite,
    "Breathing Issue": Icons.air_outlined,
  };

  @override
  void initState() {
    super.initState();
    speech = stt.SpeechToText();
  }

  void checkSymptoms() async {
    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one symptom")),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    await Future.delayed(const Duration(seconds: 2));

    final results = checkDisease(selected);

    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          results: results,
          selectedSymptoms: selected,
          user: widget.user,
        ),
      ),
    );
  }

  void autoSelectSymptoms(String text) {
    final detected = <String>[];

    for (var symptom in symptomsList) {
      if (text.contains(symptom.toLowerCase())) {
        detected.add(symptom);
      }
    }

    setState(() {
      selected = detected;
    });
  }

  Future<void> startListening() async {
    bool available = await speech.initialize(
      onStatus: (status) => print("Status: $status"),
      onError: (error) => print("Error: $error"),
    );

    if (available) {
      setState(() => isListening = true);

      speech.listen(
        onResult: (result) {
          setState(() {
            spokenText = result.recognizedWords.toLowerCase();
          });

          if (result.finalResult) {
            autoSelectSymptoms(spokenText);
            stopListening();
          }
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Speech recognition not available")),
      );
    }
  }

  void stopListening() {
    speech.stop();
    setState(() => isListening = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Symptom Checker"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(user: widget.user),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              MyApp.of(context)?.toggleTheme();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Text(
            "Welcome, ${widget.user.email}",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              "Select your symptoms below or speak them",
              style: TextStyle(fontSize: 18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (isListening) {
                    stopListening();
                  } else {
                    startListening();
                  }
                },
                icon: Icon(isListening ? Icons.mic : Icons.mic_none),
                label: Text(isListening ? "Listening..." : "Speak Symptoms"),
              ),
            ),
          ),
          if (spokenText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Detected: $spokenText",
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: symptomsList.length,
              itemBuilder: (context, index) {
                final symptom = symptomsList[index];
                return CheckboxListTile(
                  secondary:
                  Icon(symptomIcons[symptom] ?? Icons.health_and_safety),
                  title: Text(symptom),
                  value: selected.contains(symptom),
                  onChanged: (value) {
                    setState(() {
                      if (selected.contains(symptom)) {
                        selected.remove(symptom);
                      } else {
                        selected.add(symptom);
                      }
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GradientButton(
                  text: "Check Symptoms",
                  onPressed: checkSymptoms,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HistoryScreen(user: widget.user),
                      ),
                    );
                  },
                  child: const Text("View History"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


