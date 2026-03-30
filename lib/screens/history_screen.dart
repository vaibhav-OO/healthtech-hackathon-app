import 'package:flutter/material.dart';
import '../services/db_service.dart';
import '../models/report.dart';
import '../models/user.dart';

class HistoryScreen extends StatefulWidget {
  final UserModel user;

  const HistoryScreen({super.key, required this.user});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<ReportModel> reports = [];
  bool loading = true;

  // Personal Health History Insights
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
      lastDisease =
      fetchedReports.isNotEmpty ? fetchedReports.first.disease : "N/A";
      mostCommonSymptom = commonSymptom;
      loading = false;
    });
  }

  Widget buildInsightCard(String title, String value, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Colors.grey[850] : Colors.white;

    return Expanded(
      child: Card(
        color: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Icon(icon, size: 30, color: const Color(0xFF43A047)),
              const SizedBox(height: 10),
              Text(
                value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? Colors.grey[900] : Colors.green[50];
    final appBarColor = isDark ? const Color(0xFF1B5E20) : const Color(0xFF2E7D32);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Health History"),
        centerTitle: true,
        backgroundColor: appBarColor,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : reports.isEmpty
          ? Center(
        child: Text(
          "No reports yet",
          style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                buildInsightCard(
                    "Total Checks", "$totalReports", Icons.analytics),
                const SizedBox(width: 12),
                buildInsightCard(
                    "Last Condition", lastDisease, Icons.medical_information),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                buildInsightCard(
                    "Top Symptom", mostCommonSymptom, Icons.monitor_heart),
                const SizedBox(width: 12),
                buildInsightCard("User", widget.user.email, Icons.person),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Previous Reports",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : Colors.black87),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final report = reports[index];
                  return Card(
                    color: isDark ? Colors.grey[850] : Colors.white,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Icon(Icons.health_and_safety,
                          color: const Color(0xFF43A047)),
                      title: Text(
                        report.disease,
                        style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87),
                      ),
                      subtitle: Text(
                        "Date: ${report.date}\nSymptoms: ${report.symptoms}",
                        style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54),
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

