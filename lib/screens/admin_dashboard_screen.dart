// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import '../services/db_service.dart';
//
// class AdminDashboardScreen extends StatefulWidget {
//   const AdminDashboardScreen({super.key});
//
//   @override
//   State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
// }
//
// class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
//   int totalReports = 0;
//   int highRiskCases = 0;
//   String mostCommonSymptom = "N/A";
//
//   Map<String, int> symptomCounts = {};
//   Map<String, int> riskCounts = {
//     "Low": 0,
//     "Moderate": 0,
//     "High": 0,
//   };
//
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     loadDashboardData();
//   }
//
//   // AI-Like Risk Calculation
//   String calculateRisk(String symptoms) {
//     final s = symptoms.toLowerCase();
//     int score = 0;
//
//     if (s.contains("fever")) score += 2;
//     if (s.contains("cough")) score += 2;
//     if (s.contains("headache")) score += 1;
//     if (s.contains("fatigue")) score += 1;
//     if (s.contains("nausea")) score += 1;
//     if (s.contains("vomiting")) score += 2;
//     if (s.contains("chest pain")) score += 5;
//     if (s.contains("breathing")) score += 5;
//     if (s.contains("shortness of breath")) score += 5;
//     if (s.contains("dizziness")) score += 2;
//
//     if (score >= 7) return "High";
//     if (score >= 4) return "Moderate";
//     return "Low";
//   }
//
//
//   // Load Dashboard Data
//   Future<void> loadDashboardData() async {
//     try {
//       final dbHelper = DBService.instance;
//       final reports = await dbHelper.getAllReportsRaw();
//
//       int tempTotalReports = reports.length;
//       int tempHighRisk = 0;
//
//       Map<String, int> tempSymptomCounts = {};
//       Map<String, int> tempRiskCounts = {
//         "Low": 0,
//         "Moderate": 0,
//         "High": 0,
//       };
//
//       for (var report in reports) {
//         String symptomsString = (report['symptoms'] ?? "").toString();
//
//         // Calculate AI-like risk from symptoms
//         String risk = calculateRisk(symptomsString);
//
//         // Count risk levels
//         if (tempRiskCounts.containsKey(risk)) {
//           tempRiskCounts[risk] = tempRiskCounts[risk]! + 1;
//         } else {
//           tempRiskCounts[risk] = 1;
//         }
//
//         if (risk == "High") {
//           tempHighRisk++;
//         }
//
//         // Count symptoms
//         List<String> symptoms = symptomsString.split(',');
//         for (String symptom in symptoms) {
//           symptom = symptom.trim();
//           if (symptom.isNotEmpty) {
//             tempSymptomCounts[symptom] =
//                 (tempSymptomCounts[symptom] ?? 0) + 1;
//           }
//         }
//       }
//
//       String topSymptom = "N/A";
//       if (tempSymptomCounts.isNotEmpty) {
//         topSymptom = tempSymptomCounts.entries
//             .reduce((a, b) => a.value > b.value ? a : b)
//             .key;
//       }
//
//       setState(() {
//         totalReports = tempTotalReports;
//         highRiskCases = tempHighRisk;
//         symptomCounts = tempSymptomCounts;
//         riskCounts = tempRiskCounts;
//         mostCommonSymptom = topSymptom;
//         isLoading = false;
//       });
//     } catch (e) {
//       debugPrint("Dashboard Load Error: $e");
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   // Bar Chart Data
//   List<BarChartGroupData> buildBarChartData() {
//     final entries = symptomCounts.entries.toList()
//       ..sort((a, b) => b.value.compareTo(a.value));
//
//     final topEntries = entries.take(5).toList();
//
//     return List.generate(topEntries.length, (index) {
//       return BarChartGroupData(
//         x: index,
//         barRods: [
//           BarChartRodData(
//             toY: topEntries[index].value.toDouble(),
//             width: 18,
//             borderRadius: BorderRadius.circular(6),
//           ),
//         ],
//       );
//     });
//   }
//
//   // Pie Chart Data
//   List<PieChartSectionData> buildPieChartData() {
//     final total = riskCounts.values.fold(0, (sum, item) => sum + item);
//
//     if (total == 0) {
//       return [
//         PieChartSectionData(
//           value: 1,
//           title: "No Data",
//           radius: 70,
//         ),
//       ];
//     }
//     return [
//       PieChartSectionData(
//         value: riskCounts["Low"]!.toDouble(),
//         title: "Low\n${riskCounts["Low"]}",
//         radius: 70,
//       ),
//       PieChartSectionData(
//         value: riskCounts["Moderate"]!.toDouble(),
//         title: "Moderate\n${riskCounts["Moderate"]}",
//         radius: 70,
//       ),
//       PieChartSectionData(
//         value: riskCounts["High"]!.toDouble(),
//         title: "High\n${riskCounts["High"]}",
//         radius: 70,
//       ),
//     ];
//   }
//   // UI Card
//   Widget buildStatCard(String title, String value, IconData icon) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
//         ),
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.08),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 24,
//             backgroundColor: Colors.white.withValues(alpha: 0.2),
//             child: Icon(icon, color: Colors.white),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     color: Colors.white70,
//                     fontSize: 13,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   value,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
//
//   // Section Wrapper
//   Widget buildSectionCard({required String title, required Widget child}) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 20),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(22),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.06),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           )
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 18),
//           child,
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final symptomEntries = symptomCounts.entries.toList()
//       ..sort((a, b) => b.value.compareTo(a.value));
//
//     final topEntries = symptomEntries.take(5).toList();
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7FB),
//       appBar: AppBar(
//         title: const Text("Admin Dashboard"),
//         centerTitle: true,
//         elevation: 0,
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : RefreshIndicator(
//         onRefresh: loadDashboardData,
//         child: SingleChildScrollView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             children: [
//
//               GridView.count(
//                 crossAxisCount: 2,
//                 shrinkWrap: true,
//                 crossAxisSpacing: 12,
//                 mainAxisSpacing: 12,
//                 physics: const NeverScrollableScrollPhysics(),
//                 childAspectRatio: 1.4,
//                 children: [
//                   buildStatCard(
//                     "Total Reports",
//                     totalReports.toString(),
//                     Icons.description_outlined,
//                   ),
//                   buildStatCard(
//                     "High Risk Cases",
//                     highRiskCases.toString(),
//                     Icons.warning_amber_rounded,
//                   ),
//                   buildStatCard(
//                     "Top Symptom",
//                     mostCommonSymptom,
//                     Icons.monitor_heart_outlined,
//                   ),
//                   buildStatCard(
//                     "Low Risk",
//                     riskCounts["Low"].toString(),
//                     Icons.health_and_safety_outlined,
//                   ),
//                 ],
//               ),
//
//               const SizedBox(height: 20),
//
//
//               // BAR CHART
//               buildSectionCard(
//                 title: "Most Common Symptoms",
//                 child: SizedBox(
//                   height: 260,
//                   child: topEntries.isEmpty
//                       ? const Center(child: Text("No symptom data found"))
//                       : BarChart(
//                     BarChartData(
//                       alignment: BarChartAlignment.spaceAround,
//                       maxY: (topEntries
//                           .map((e) => e.value)
//                           .reduce((a, b) => a > b ? a : b) +
//                           2)
//                           .toDouble(),
//                       borderData: FlBorderData(show: false),
//                       gridData: const FlGridData(show: true),
//                       titlesData: FlTitlesData(
//                         topTitles: const AxisTitles(
//                           sideTitles: SideTitles(showTitles: false),
//                         ),
//                         rightTitles: const AxisTitles(
//                           sideTitles: SideTitles(showTitles: false),
//                         ),
//                         leftTitles: const AxisTitles(
//                           sideTitles: SideTitles(
//                             showTitles: true,
//                             reservedSize: 30,
//                           ),
//                         ),
//                         bottomTitles: AxisTitles(
//                           sideTitles: SideTitles(
//                             showTitles: true,
//                             getTitlesWidget: (value, meta) {
//                               int index = value.toInt();
//                               if (index >= 0 &&
//                                   index < topEntries.length) {
//                                 return Padding(
//                                   padding:
//                                   const EdgeInsets.only(top: 8),
//                                   child: Text(
//                                     topEntries[index].key,
//                                     style: const TextStyle(
//                                       fontSize: 11,
//                                     ),
//                                   ),
//                                 );
//                               }
//                               return const SizedBox();
//                             },
//                           ),
//                         ),
//                       ),
//                       barGroups: buildBarChartData(),
//                     ),
//                   ),
//                 ),
//               ),
//
//               // PIE CHART
//               buildSectionCard(
//                 title: "Risk Distribution",
//                 child: SizedBox(
//                   height: 280,
//                   child: PieChart(
//                     PieChartData(
//                       sectionsSpace: 4,
//                       centerSpaceRadius: 45,
//                       sections: buildPieChartData(),
//                     ),
//                   ),
//                 ),
//               ),
//
//               // TOP SYMPTOM LIST
//               buildSectionCard(
//                 title: "Top Symptom Details",
//                 child: topEntries.isEmpty
//                     ? const Text("No data available")
//                     : Column(
//                   children: topEntries.map((entry) {
//                     return ListTile(
//                       contentPadding: EdgeInsets.zero,
//                       leading: const Icon(Icons.bubble_chart),
//                       title: Text(entry.key),
//                       trailing: Text(
//                         "${entry.value} reports",
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/db_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int totalReports = 0;
  int highRiskCases = 0;
  String mostCommonSymptom = "N/A";

  Map<String, int> symptomCounts = {};
  Map<String, int> riskCounts = {
    "Low": 0,
    "Moderate": 0,
    "High": 0,
  };

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  String calculateRisk(String symptoms) {
    final s = symptoms.toLowerCase();
    int score = 0;

    if (s.contains("fever")) score += 2;
    if (s.contains("cough")) score += 2;
    if (s.contains("headache")) score += 1;
    if (s.contains("fatigue")) score += 1;
    if (s.contains("nausea")) score += 1;
    if (s.contains("vomiting")) score += 2;
    if (s.contains("chest pain")) score += 5;
    if (s.contains("breathing")) score += 5;
    if (s.contains("shortness of breath")) score += 5;
    if (s.contains("dizziness")) score += 2;

    if (score >= 7) return "High";
    if (score >= 4) return "Moderate";
    return "Low";
  }

  Future<void> loadDashboardData() async {
    try {
      final dbHelper = DBService.instance;
      final reports = await dbHelper.getAllReportsRaw();

      int tempTotalReports = reports.length;
      int tempHighRisk = 0;

      Map<String, int> tempSymptomCounts = {};
      Map<String, int> tempRiskCounts = {
        "Low": 0,
        "Moderate": 0,
        "High": 0,
      };

      for (var report in reports) {
        String symptomsString = (report['symptoms'] ?? "").toString();
        String risk = calculateRisk(symptomsString);

        tempRiskCounts[risk] = (tempRiskCounts[risk] ?? 0) + 1;
        if (risk == "High") tempHighRisk++;

        for (String symptom in symptomsString.split(',')) {
          symptom = symptom.trim();
          if (symptom.isNotEmpty) {
            tempSymptomCounts[symptom] =
                (tempSymptomCounts[symptom] ?? 0) + 1;
          }
        }
      }

      String topSymptom = tempSymptomCounts.isNotEmpty
          ? tempSymptomCounts.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key
          : "N/A";

      setState(() {
        totalReports = tempTotalReports;
        highRiskCases = tempHighRisk;
        symptomCounts = tempSymptomCounts;
        riskCounts = tempRiskCounts;
        mostCommonSymptom = topSymptom;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Dashboard Load Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  List<BarChartGroupData> buildBarChartData() {
    final entries = symptomCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topEntries = entries.take(5).toList();

    return List.generate(topEntries.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: topEntries[index].value.toDouble(),
            width: 18,
            borderRadius: BorderRadius.circular(6),
            color: const Color(0xFF43A047), // matching primary green
          ),
        ],
      );
    });
  }

  List<PieChartSectionData> buildPieChartData() {
    final total = riskCounts.values.fold(0, (sum, item) => sum + item);
    if (total == 0) {
      return [
        PieChartSectionData(
          value: 1,
          title: "No Data",
          radius: 70,
          color: Colors.grey[300],
        ),
      ];
    }

    return [
      PieChartSectionData(
        value: riskCounts["Low"]!.toDouble(),
        title: "Low\n${riskCounts["Low"]}",
        radius: 70,
        color: const Color(0xFF81C784), // light green
      ),
      PieChartSectionData(
        value: riskCounts["Moderate"]!.toDouble(),
        title: "Moderate\n${riskCounts["Moderate"]}",
        radius: 70,
        color: const Color(0xFF43A047), // medium green
      ),
      PieChartSectionData(
        value: riskCounts["High"]!.toDouble(),
        title: "High\n${riskCounts["High"]}",
        radius: 70,
        color: const Color(0xFF2E7D32), // dark green
      ),
    ];
  }

  Widget buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF43A047), Color(0xFF66BB6A)], // health theme green
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildSectionCard({required String title, required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final symptomEntries = symptomCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topEntries = symptomEntries.take(5).toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.green[50],
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1B5E20) : const Color(0xFF2E7D32),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.4,
                children: [
                  buildStatCard(
                    "Total Reports",
                    totalReports.toString(),
                    Icons.description_outlined,
                  ),
                  buildStatCard(
                    "High Risk Cases",
                    highRiskCases.toString(),
                    Icons.warning_amber_rounded,
                  ),
                  buildStatCard(
                    "Top Symptom",
                    mostCommonSymptom,
                    Icons.monitor_heart_outlined,
                  ),
                  buildStatCard(
                    "Low Risk",
                    riskCounts["Low"].toString(),
                    Icons.health_and_safety_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              buildSectionCard(
                title: "Most Common Symptoms",
                child: SizedBox(
                  height: 260,
                  child: topEntries.isEmpty
                      ? const Center(child: Text("No symptom data found"))
                      : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: (topEntries
                          .map((e) => e.value)
                          .reduce((a, b) => a > b ? a : b) +
                          2)
                          .toDouble(),
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: true),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              int index = value.toInt();
                              if (index >= 0 && index < topEntries.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    topEntries[index].key,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? Colors.white70 : Colors.black87,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                      ),
                      barGroups: buildBarChartData(),
                    ),
                  ),
                ),
              ),
              buildSectionCard(
                title: "Risk Distribution",
                child: SizedBox(
                  height: 280,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 45,
                      sections: buildPieChartData(),
                    ),
                  ),
                ),
              ),
              buildSectionCard(
                title: "Top Symptom Details",
                child: topEntries.isEmpty
                    ? const Text("No data available")
                    : Column(
                  children: topEntries.map((entry) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.bubble_chart),
                      title: Text(
                        entry.key,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      trailing: Text(
                        "${entry.value} reports",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}