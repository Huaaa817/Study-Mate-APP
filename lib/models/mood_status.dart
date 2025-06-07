class MoodStatus {
  final int value;         // 當日 mood 值 (0~4)
  final String updatedDate; // yyyy-MM-dd 格式的日期
  final int baseMood;      // 昨天結束時的 mood 值，預設 2

  MoodStatus({
    required this.value,
    required this.updatedDate,
    this.baseMood = 2,
  });

  factory MoodStatus.fromJson(Map<String, dynamic> json) {
    return MoodStatus(
      value: json['value'] ?? 2,
      updatedDate: json['updatedDate'] ?? '',
      baseMood: json['baseMood'] ?? 2,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'updatedDate': updatedDate,
      'baseMood': baseMood,
    };
  }
}
