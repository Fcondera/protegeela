class SafetyContent {
  const SafetyContent({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.category,
    required this.isPublished,
  });

  final String id;
  final String title;
  final String summary;
  final String content;
  final String category;
  final bool isPublished;

  factory SafetyContent.fromJson(Map<String, dynamic> json) => SafetyContent(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        summary: json['summary'] as String? ?? '',
        content: json['content'] as String? ?? '',
        category: json['category'] as String? ?? 'general',
        isPublished: json['is_published'] as bool? ?? false,
      );
}
