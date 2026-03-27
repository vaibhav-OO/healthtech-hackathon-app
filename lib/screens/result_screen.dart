import 'package:flutter/material.dart';
import '../models/disease.dart';
import '../services/db_service.dart';
import '../models/user.dart';



class ResultScreen extends StatelessWidget {
  final List<MapEntry<Disease, int>> results;
  final List<String> selectedSymptoms;
  final UserModel user;

  const ResultScreen({
      super.key,
      required this.results,
      required this.selectedSymptoms,
      required this.user
    });

  @override
  Widget build(BuildContext context) {
    final top = results.first;

    return Scaffold(
      appBar: AppBar(title: const Text("Prediction Result")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Most Likely Condition", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Text(
              top.key.name,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "${top.value}% match",
              style: const TextStyle(fontSize: 22, color: Colors.teal),
            ),
            const SizedBox(height: 20),
            const Text("Advice", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
                top.key.advice,
                style: const TextStyle(fontSize: 18)
            ),
            const SizedBox(height: 24),
            const Text(
                "Other Possibilities",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                )
            ),
            const SizedBox(height: 8),
            ...results.take(3).map((e) => Text("${e.key.name} — ${e.value}%")),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {

                  // await FirestoreService().saveReport(
                  //   symptoms: selectedSymptoms,
                  //   result: top.key.name,
                  //   percent: top.value,
                  // );

                  await DBService.instance.saveReport(
                    userId: user.id!,
                    symptoms: selectedSymptoms.join(", "),
                    result:  top.key.name,
                    percent:  top.value,
                  );


                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Report saved successfully")
                    ),
                  );
                },
                child: const Text("Save Report"),
              ),
            )
          ],
        ),
      ),
    );
  }
}