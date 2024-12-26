class Post {
  int? id;
  final String title;
  final String description;
  final String imageUrl;
  final DateTime createdAt;

  Post({
    this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.createdAt,
  });

  // Convert Dart object to Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Convert database Map to Dart object
  factory Post.fromJson(Map<String, dynamic> map) {
    return Post(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      imageUrl: map['image_url'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
