class Shelter {
  final String id;
  final String name;
  final String address;
  final double distance;
  final String status;
  final String predictedCongestion;
  final double latitude;
  final double longitude;
  
  // 기존 코드에서 사용하는 필드들 추가
  final String openingDays;
  final int maxCapacity;
  final List<String> facilities;
  final double rating;
  final int likes;
  final String imageUrl;
  final String congestion; // predictedCongestion과 별도로 기존 congestion 지원

  Shelter({
    required this.id,
    required this.name,
    required this.address,
    required this.distance,
    required this.status,
    required this.predictedCongestion,
    required this.latitude,
    required this.longitude,
    // 기본값으로 설정
    this.openingDays = '정보 없음',
    this.maxCapacity = 0,
    this.facilities = const [],
    this.rating = 0.0,
    this.likes = 0,
    this.imageUrl = '',
    this.congestion = '정보 없음',
  });

  factory Shelter.fromJson(Map<String, dynamic> json) {
    return Shelter(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      distance: (json['distance'] ?? 0).toDouble(),
      status: json['status']?.toString() ?? '',
      predictedCongestion: json['predictedCongestion']?.toString() ?? '',
      latitude: json['coordinates']?['lat']?.toDouble() ?? 0.0,
      longitude: json['coordinates']?['lng']?.toDouble() ?? 0.0,
      // API에서 제공하지 않는 필드들은 기본값 사용
      openingDays: json['openingDays']?.toString() ?? '정보 없음',
      maxCapacity: json['maxCapacity'] ?? 0,
      facilities: json['facilities'] != null 
          ? List<String>.from(json['facilities']) 
          : [],
      rating: (json['rating'] ?? 0.0).toDouble(),
      likes: json['likes'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      congestion: json['congestion']?.toString() ?? json['predictedCongestion']?.toString() ?? '정보 없음',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'distance': distance,
      'status': status,
      'predictedCongestion': predictedCongestion,
      'coordinates': {
        'lat': latitude,
        'lng': longitude,
      },
      'openingDays': openingDays,
      'maxCapacity': maxCapacity,
      'facilities': facilities,
      'rating': rating,
      'likes': likes,
      'imageUrl': imageUrl,
      'congestion': congestion,
    };
  }
}
