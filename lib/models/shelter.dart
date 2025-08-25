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

  // 상태 포맷팅 헬퍼 함수
  static String _formatStatus(String status) {
    final upperStatus = status.toUpperCase();
    if (upperStatus.contains('ACTIVE')) {
      return '이용가능';
    } else if (upperStatus.contains('INACTIVE')) {
      return '이용불가';
    } else if (upperStatus.contains('MAINTENANCE')) {
      return '점검중';
    } else if (upperStatus.contains('CLOSED')) {
      return '폐쇄';
    } else {
      return status;
    }
  }

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
    // 이미지 URL 정리 (줄바꿈과 공백 제거)
    String imageUrl = json['imageUrl']?.toString() ?? '';
    if (imageUrl.isNotEmpty) {
      // 모든 줄바꿈, 캐리지 리턴, 탭, 연속된 공백 제거
      imageUrl = imageUrl
          .replaceAll('\n', '')
          .replaceAll('\r', '')
          .replaceAll('\t', '')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      
      print('🖼️ 원본 이미지 URL: ${json['imageUrl']}');
      print('🖼️ 정리된 이미지 URL: $imageUrl');
      print('️ URL 유효성 검사: ${Uri.tryParse(imageUrl) != null ? "유효함" : "유효하지 않음"}');
    }
    
    // 상태 한글 변환
    String originalStatus = json['status']?.toString() ?? '';
    String formattedStatus = _formatStatus(originalStatus);
    
    return Shelter(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      distance: (json['distance'] ?? 0).toDouble(),
      status: formattedStatus, // 한글로 변환된 상태 사용
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
      imageUrl: imageUrl, // 정리된 이미지 URL 사용
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
