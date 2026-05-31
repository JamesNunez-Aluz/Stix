/// Status of an idea: still sitting in a jar, or already pulled + tried.
class IdeaStatus {
  static const inJar = 'in_jar';
  static const tried = 'tried';
}

/// A single saved idea — usually a link shared in from social media, plus the
/// user's own title/note. Once pulled and confirmed, it becomes `tried` and
/// gains a rating + thoughts.
class Idea {
  final int? id;
  final int jarId;
  final String status;
  final String? sourceUrl;
  final String? sourcePlatform; // tiktok / instagram / youtube / web ...
  final String? thumbnailUrl; // OG preview image, if the link exposes one
  final String title;
  final String? note;
  final int? rating; // 1..5, set when tried
  final String? thoughts; // set when tried
  final String? photoPath; // local path to the polaroid photo, if any
  final int createdAt;
  final int? triedAt;

  const Idea({
    this.id,
    required this.jarId,
    this.status = IdeaStatus.inJar,
    this.sourceUrl,
    this.sourcePlatform,
    this.thumbnailUrl,
    required this.title,
    this.note,
    this.rating,
    this.thoughts,
    this.photoPath,
    required this.createdAt,
    this.triedAt,
  });

  bool get isTried => status == IdeaStatus.tried;
  bool get hasLink => sourceUrl != null && sourceUrl!.trim().isNotEmpty;
  bool get hasThumbnail =>
      thumbnailUrl != null && thumbnailUrl!.trim().isNotEmpty;
  bool get hasPhoto => photoPath != null && photoPath!.trim().isNotEmpty;

  Idea copyWith({
    int? id,
    int? jarId,
    String? status,
    String? sourceUrl,
    String? sourcePlatform,
    String? thumbnailUrl,
    String? title,
    String? note,
    int? rating,
    String? thoughts,
    String? photoPath,
    int? createdAt,
    int? triedAt,
  }) {
    return Idea(
      id: id ?? this.id,
      jarId: jarId ?? this.jarId,
      status: status ?? this.status,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      sourcePlatform: sourcePlatform ?? this.sourcePlatform,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      title: title ?? this.title,
      note: note ?? this.note,
      rating: rating ?? this.rating,
      thoughts: thoughts ?? this.thoughts,
      photoPath: photoPath ?? this.photoPath,
      createdAt: createdAt ?? this.createdAt,
      triedAt: triedAt ?? this.triedAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'jarId': jarId,
      'status': status,
      'sourceUrl': sourceUrl,
      'sourcePlatform': sourcePlatform,
      'thumbnailUrl': thumbnailUrl,
      'title': title,
      'note': note,
      'rating': rating,
      'thoughts': thoughts,
      'photoPath': photoPath,
      'createdAt': createdAt,
      'triedAt': triedAt,
    };
  }

  factory Idea.fromMap(Map<String, Object?> map) {
    return Idea(
      id: map['id'] as int?,
      jarId: map['jarId'] as int,
      status: map['status'] as String? ?? IdeaStatus.inJar,
      sourceUrl: map['sourceUrl'] as String?,
      sourcePlatform: map['sourcePlatform'] as String?,
      thumbnailUrl: map['thumbnailUrl'] as String?,
      title: map['title'] as String,
      note: map['note'] as String?,
      rating: map['rating'] as int?,
      thoughts: map['thoughts'] as String?,
      photoPath: map['photoPath'] as String?,
      createdAt: map['createdAt'] as int,
      triedAt: map['triedAt'] as int?,
    );
  }
}
