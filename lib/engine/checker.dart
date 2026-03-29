import '../data/disease_data.dart';
import '../models/disease.dart';

// List<MapEntry<Disease, int>> checkDisease(List<String> selected) {
//   Map<Disease, int> scores = {};
//
//   for (var disease in diseases) {
//     int match = 0;
//
//     for (var symptom in selected) {
//       if (disease.symptoms.contains(symptom)) {
//         match++;
//       }
//     }
//
//     int percent = disease.symptoms.isEmpty
//         ? 0
//         : (match * 100 ~/ disease.symptoms.length);
//
//     scores[disease] = percent;
//   }
//
//   var sorted = scores.entries.toList()
//   ..sort((a,b) => b.value.compareTo(a.value));
//
//   return sorted;
//
//
// }


Map<String, String> checkDisease(List<String> symptoms) {
  final s = symptoms.map((e) => e.toLowerCase()).toList();

  // HIGH RISK / EMERGENCY
  if (s.contains("chest pain") || s.contains("breathing issue")) {
    return {
      "disease": "Urgent Health Warning",
      "advice": "Seek medical help immediately.",
      "risk": "HIGH",
      "emergency": "true",
    };
  }

  // MEDIUM-HIGH
  if (s.contains("loss smell") && s.contains("fever")) {
    return {
      "disease": "Possible COVID-like Symptoms",
      "advice": "Isolate, hydrate, and consult a doctor if symptoms worsen.",
      "risk": "MEDIUM",
      "emergency": "false",
    };
  }

  // MEDIUM
  if (s.contains("fever") && s.contains("cough") && s.contains("fatigue")) {
    return {
      "disease": "Flu / Viral Infection",
      "advice": "Drink fluids, rest well, and monitor your temperature.",
      "risk": "MEDIUM",
      "emergency": "false",
    };
  }

  // LOW
  if (s.contains("sneezing") && s.contains("runny nose")) {
    return {
      "disease": "Common Cold / Allergy",
      "advice": "Take rest and avoid allergens if possible.",
      "risk": "LOW",
      "emergency": "false",
    };
  }

  // DEFAULT
  return {
    "disease": "General Mild Condition",
    "advice": "Monitor symptoms and rest. Consult a doctor if symptoms persist.",
    "risk": "LOW",
    "emergency": "false",
  };
}