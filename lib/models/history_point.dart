class HistoryPoint {
  final DateTime date;
  final double rate;

  HistoryPoint({required this.date, required this.rate});

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'rate': rate,
  };

  factory HistoryPoint.fromJson(Map<String, dynamic> json) {
    return HistoryPoint(
      date: DateTime.parse(json['date']),
      rate: (json['rate'] as num).toDouble(),
    );
  }
}
