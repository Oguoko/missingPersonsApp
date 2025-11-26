class Comment {
  final String id;
  final String comment;
  final String userId;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.comment,
    required this.userId,
    required this.createdAt,
  });

  factory Comment.fromMap(String docId, Map<String, dynamic> data) {
    return Comment(
      id: docId,
      comment: data['comment'] ?? '',
      userId: data['user_id'] ?? '',
      createdAt: (data['created_at']).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'comment': comment, 'user_id': userId, 'created_at': createdAt};
  }
}
