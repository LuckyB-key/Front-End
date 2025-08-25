class Review {
  final String id;
  final String userId;
  final String userNickname;
  final String text;
  final int rating;
  final List<String> photoUrls;
  final String createdAt;

  Review({
    required this.id,
    required this.userId,
    required this.userNickname,
    required this.text,
    required this.rating,
    required this.photoUrls,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      userNickname: json['userNickname']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      rating: json['rating'] ?? 0,
      photoUrls: json['photoUrls'] != null 
          ? List<String>.from(json['photoUrls']) 
          : [],
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userNickname': userNickname,
      'text': text,
      'rating': rating,
      'photoUrls': photoUrls,
      'createdAt': createdAt,
    };
  }
}