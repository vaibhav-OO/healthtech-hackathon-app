import '../data/disease_data.dart';
import '../models/disease.dart';

List<MapEntry<Disease, int>> checkDisease(List<String> selected) {
  Map<Disease, int> scores = {};

  for (var disease in diseases) {
    int match = 0;

    for (var symptom in selected) {
      if (disease.symptoms.contains(symptom)) {
        match++;
      }
    }

    int percent = disease.symptoms.isEmpty
        ? 0
        : (match * 100 ~/ disease.symptoms.length);

    scores[disease] = percent;
  }

  var sorted = scores.entries.toList()
  ..sort((a,b) => b.value.compareTo(a.value));

  return sorted;


}