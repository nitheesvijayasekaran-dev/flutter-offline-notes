class RemoteNote {
  final String? id;
  final String title;
  final String body;
  final DateTime updatedAt;
  final bool isDeleted;

  const RemoteNote({
    this.id,
    required this.title,
    required this.body,
    required this.updatedAt,
    required this.isDeleted,
  });

  factory RemoteNote.fromJson(Map<String, dynamic> json) => RemoteNote(
    id: json['id'],
    title: json['title'],
    body: json['body'],
    updatedAt: DateTime.parse(json['updatedAt']),
    isDeleted: json['isDeleted'],
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'title': title,
    'body': body,
    'updatedAt': updatedAt.toIso8601String(),
    'isDeleted': isDeleted,
  };
}
