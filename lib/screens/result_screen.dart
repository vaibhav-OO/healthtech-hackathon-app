// import 'package:flutter/material.dart';
// import '../models/disease.dart';
// import '../services/db_service.dart';
// import '../models/user.dart';
//
//
// class ResultScreen extends StatelessWidget {
//   final List<MapEntry<Disease, int>> results;
//   final List<String> selectedSymptoms;
//   final UserModel user;
//
//   const ResultScreen({
//       super.key,
//       required this.results,
//       required this.selectedSymptoms,
//       required this.user
//     });
//
//   @override
//   Widget build(BuildContext context) {
//     final top = results.first;
//
//     return Scaffold(
//       appBar: AppBar(title: const Text("Prediction Result")),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//                 "Most Likely Condition",
//                 style: TextStyle(
//                     fontSize: 20
//                 )
//             ),
//             const SizedBox(height: 10),
//             Text(
//               top.key.name,
//               style: const TextStyle(
//                   fontSize: 30,
//                   fontWeight: FontWeight.bold
//               ),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               "${top.value}% match",
//               style: const TextStyle(
//                   fontSize: 22,
//                   color: Colors.teal
//               ),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//                 "Advice",
//                 style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold
//                 )
//             ),
//             const SizedBox(height: 8),
//             Text(
//                 top.key.advice,
//                 style: const TextStyle(fontSize: 18)
//             ),
//             const SizedBox(height: 24),
//             const Text(
//                 "Other Possibilities",
//                 style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold
//                 )
//             ),
//             const SizedBox(height: 8),
//             ...results.take(3).map((e) => Text("${e.key.name} — ${e.value}%")),
//             const Spacer(),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () async {
//
//                   // await FirestoreService().saveReport(
//                   //   symptoms: selectedSymptoms,
//                   //   result: top.key.name,
//                   //   percent: top.value,
//                   // );
//
//                   await DBService.instance.saveReport(
//                     userId: user.id!,
//                     symptoms: selectedSymptoms.join(", "),
//                     result:  top.key.name,
//                     percent:  top.value,
//                   );
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text("Report saved successfully")
//                     ),
//                   );
//                 },
//                 child: const Text("Save Report"),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'package:aisymtoms/data/disease_data.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import '../models/user.dart';
import '../models/report.dart';
import '../services/db_service.dart';

class ResultScreen extends StatefulWidget {
  final Map<String, String> results;
  final List<String> selectedSymptoms;
  final UserModel user;

  const ResultScreen({
    super.key,
    required this.results,
    required this.selectedSymptoms,
    required this.user,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool saved = false;

  @override
  void initState() {
    super.initState();
    saveResult();
  }

  //Save report in database
  Future<void> saveResult() async {
    await Future.delayed(const Duration(seconds: 1));
    await DBService.instance.saveReport(
      ReportModel(
        userId: widget.user.id ?? 0,
        symptoms: widget.selectedSymptoms.join(", "),
        disease: widget.results["disease"] ?? "Unknown",
        advice: widget.results["advice"] ?? "No advice available",
        date: DateTime.now().toString(),
      ),
    );

    if (mounted) {
      setState(() {
        saved = true;
      });
    }
  }

  //Share function code
  void shareReport() async{
    final disease = widget.results["disease"] ?? "Unknown";
    final advice = widget.results["advice"] ?? "No advice available";
    final risk = widget.results["risk"] ?? "Low";
    final reportText = """ 
    AI Symptom - Health Report
    
    User: ${widget.user.email}
    Symptoms: ${widget.selectedSymptoms.join(",")}
    Predicted Condition: $disease
    Risk Level: $risk 
    Advice: $advice 
    Date: ${DateTime.now().toString()} 
    Disclaimer: This app is for educational 
    screening only and does not replace professional 
    medical diagnosis.  Share.share(reportText);
    """;

    Share.share(reportText);
  }

  Color getRiskColor(String risk) {
    switch (risk) {
      case "HIGH":
        return Colors.red;
      case "MEDIUM":
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  //Nearby hospital code
  Future<void> openHospitalMap() async {
    final Uri url = Uri.parse(
      "https://www.google.com/maps/search/hospital+near+me",
    );

    try {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open map")),
      );
    }
  }

  //All widgets are cover in this function * UI
  @override
  Widget build(BuildContext context) {
    final disease = widget.results["disease"] ?? "Unknown";
    final advice = widget.results["advice"] ?? "No advice available";
    final risk = widget.results["risk"] ?? "LOW";
    final isEmergency = widget.results["emergency"] == "true";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Prediction Result"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.health_and_safety, size: 90, color: Colors.teal),
            const SizedBox(height: 20),

            // Risk Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: getRiskColor(risk).withOpacity(0.15),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: getRiskColor(risk), width: 2),
              ),
              child: Text(
                "Risk Level: $risk",
                style: TextStyle(
                  color: getRiskColor(risk),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Disease Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: const Icon(Icons.medical_information, size: 32),
                title: const Text("Predicted Condition"),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    disease,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Advice Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: const Icon(Icons.tips_and_updates, size: 32),
                title: const Text("Health Advice"),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(advice),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Symptoms Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: const Icon(Icons.list_alt, size: 32),
                title: const Text("Selected Symptoms"),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(widget.selectedSymptoms.join(", ")),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Emergency Warning
            if (isEmergency)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          "Emergency Warning",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Your symptoms may require urgent medical attention. Please contact a doctor or visit a nearby hospital immediately.",
                    ),
                  ],
                ),
              ),

            if (isEmergency) const SizedBox(height: 20),

            // Nearby Hospital Button
            if (isEmergency || risk == "HIGH")
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: openHospitalMap,
                  icon: const Icon(Icons.local_hospital),
                  label: const Text("Find Nearby Hospitals"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // Save Status
            Text(
              saved ? "Report saved successfully" : "Saving report...",
              style: TextStyle(
                color: saved ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),
            //Share button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: shareReport,
                label: const Text(
                    "share Health report"
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),


            const SizedBox(height: 25),

            // Disclaimer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                "Disclaimer: This app is for educational screening purposes only and does not replace professional medical diagnosis or treatment.",
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}