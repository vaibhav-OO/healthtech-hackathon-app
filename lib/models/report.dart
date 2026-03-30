class ReportModel {
  final int? id;
  final int userId;
  final String symptoms;
  final String disease;
  final String advice;
  final String date;

  ReportModel({
    this.id,
    required this.userId,
    required this.symptoms,
    required this.disease,
    required this.advice,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'symptoms': symptoms,
      'disease': disease,
      'advice': advice,
      'date': date,
    };
  }

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      id: map['id'],
      userId: map['userId'],
      symptoms: map['symptoms'],
      disease: map['disease'],
      advice: map['advice'],
      date: map['date'],
    );
  }
}