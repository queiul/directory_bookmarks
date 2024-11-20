class BookmarkData {
  final String path;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  BookmarkData({
    required this.path,
    DateTime? createdAt,
    this.metadata,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata ?? {},
    };
  }

  factory BookmarkData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return BookmarkData(path: '');
    
    return BookmarkData(
      path: json['path'] as String? ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : null,
      metadata: (json['metadata'] as Map<Object?, Object?>?)?.cast<String, dynamic>(),
    );
  }

  @override
  String toString() => 'BookmarkData(path: $path, createdAt: $createdAt, metadata: $metadata)';
}
