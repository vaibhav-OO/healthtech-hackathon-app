import 'package:flutter/material.dart';
import '../services/db_service.dart';
import '../models/report.dart';
import '../models/user.dart';

class HistoryScreen extends StatefulWidget {
  final UserModel user;

  const HistoryScreen(
      {
        super.key,
        required this.user
      }
      );

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<ReportModel> reports = [];
  bool loading = true;

  //Personal Health History Insights
  int totalReports = 0;
  String lastDisease = "N/A";
  String mostCommonSymptom = "N/A";

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  void fetchReports() async {
    final fetchedReports =
    await DBService.instance.getReportsForUser(widget.user.id ?? 0);

    String commonSymptom = "N/A";

    if (fetchedReports.isNotEmpty) {
      final symptomCount = <String, int>{};

      for (var report in fetchedReports) {
        final symptoms = report.symptoms.split(", ");
        for (var symptom in symptoms) {
          symptomCount[symptom] = (symptomCount[symptom] ?? 0) + 1;
        }
      }

      commonSymptom = symptomCount.entries.reduce((a, b) {
        return a.value > b.value ? a : b;
      }).key;
    }

    setState(() {
      reports = fetchedReports;
      totalReports = fetchedReports.length;
      lastDisease = fetchedReports.isNotEmpty ? fetchedReports.first.disease : "N/A";
      mostCommonSymptom = commonSymptom;
      loading = false;
    });
  }

  Widget buildInsightCard(String title, String value, IconData icon) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Icon(icon, size: 30, color: Colors.teal),
              const SizedBox(height: 10),
              Text(
                value,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Health History")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : reports.isEmpty
          ? const Center(child: Text("No reports yet"))
          : Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                buildInsightCard("Total Checks", "$totalReports", Icons.analytics),
                buildInsightCard("Last Condition", lastDisease, Icons.medical_information),
              ],
            ),
            Row(
              children: [
                buildInsightCard("Top Symptom", mostCommonSymptom, Icons.monitor_heart),
                buildInsightCard("User", widget.user.email, Icons.person),
              ],
            ),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Previous Reports",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final report = reports[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: const Icon(Icons.health_and_safety),
                      title: Text(report.disease),
                      subtitle: Text(
                        "Date: ${report.date}\nSymptoms: ${report.symptoms}",
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}