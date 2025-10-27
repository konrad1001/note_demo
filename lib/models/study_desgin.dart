class StudyTopic {
  final String title;
  final String summary;
  final List<String> studyPlan;

  const StudyTopic({
    required this.title,
    required this.summary,
    required this.studyPlan,
  });

  factory StudyTopic.fromJson(Map<String, dynamic> json) {
    return StudyTopic(
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      studyPlan: (json['study_plan'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'summary': summary,
    'study_plan': studyPlan,
  };

  StudyTopic copyWith({
    String? title,
    String? summary,
    List<String>? studyPlan,
  }) {
    return StudyTopic(
      title: title ?? this.title,
      summary: summary ?? this.summary,
      studyPlan: studyPlan ?? this.studyPlan,
    );
  }

  @override
  String toString() =>
      'StudyTopic(title: $title, summary: $summary, studyPlan: $studyPlan)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudyTopic &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          summary == other.summary &&
          studyPlan.join(',') == other.studyPlan.join(',');

  @override
  int get hashCode => title.hashCode ^ summary.hashCode ^ studyPlan.hashCode;
}
