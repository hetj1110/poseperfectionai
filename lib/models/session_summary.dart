class SessionSummary {
  final String dateTime;
  final int reps;
  final int durationSec;

  SessionSummary({
    required this.dateTime,
    required this.reps,
    required this.durationSec,
  });

  Map<String, dynamic> toJson() => {
    'dateTime': dateTime,
    'reps': reps,
    'durationSec': durationSec,
  };

  static SessionSummary fromJson(Map<String, dynamic> json) => SessionSummary(
    dateTime: json['dateTime'],
    reps: json['reps'],
    durationSec: json['durationSec'],
  );
}
