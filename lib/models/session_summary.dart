class SessionSummary {
  final String dateTime;
  final int reps;
  final int score;
  final int durationSec;
  final String? notes;

  SessionSummary({
    required this.dateTime,
    required this.reps,
    required this.score,
    required this.durationSec,
    this.notes,
  });

  factory SessionSummary.fromJson(Map<String, dynamic> json) => SessionSummary(
    dateTime: json['dateTime'],
    reps: json['reps'],
    score: json['score'],
    durationSec: json['durationSec'],
    notes: json['notes'],
  );

  Map<String, dynamic> toJson() => {
    'dateTime': dateTime,
    'reps': reps,
    'score': score,
    'durationSec': durationSec,
    if (notes != null) 'notes': notes,
  };
}
